import { GlassIconButton } from '../../components/common/GlassIconButton'
import { AppTheme } from '../../theme/AppTheme'
import { ImageRepository } from '../../service/ImageRepository'
import { WaterFlowDataSource } from '../../datasource/WaterFlowDataSource'
import { ImageItem } from '../../model/ImageItem'
import { ACGCard } from './ACGCard'
import { ImageActions } from './ImageActions'
import { SourceConfig, SourceType } from '../../model/SourceConfig'
import hilog from '@ohos.hilog'
import { common } from '@kit.AbilityKit'

class GallerySourceState {
  items: ImageItem[] = []
  page: number = 1
  hasMore: boolean = true
  offsetY: number = 0
}

@Component
export struct GalleryView {
  @Prop bottomInset: number = 0
  @Prop isDark: boolean = false
  @Prop @Watch('onActiveChanged') isActive: boolean = false
  onNavigationVisibility: (visible: boolean) => void = () => {}
  @StorageLink('imageFitMode') fitMode: string = 'contain'
  private repo: ImageRepository = ImageRepository.getInstance()
  private ds: WaterFlowDataSource = new WaterFlowDataSource()
  private scroller: Scroller = new Scroller()
  private sourceStates: Map<SourceType, GallerySourceState> = new Map<SourceType, GallerySourceState>()
  private requestVersion: number = 0
  private filterRevision: number = this.repo.getFilterRevision()
  private scrollDirection: number = 0
  private scrollDistance: number = 0
  @State galleryWidth: number = 0
  @State page: number = 1
  @State loading: boolean = false
  @State refreshing: boolean = false
  @State currentSource: SourceType = SourceType.PICSUM
  @State enabledSources: SourceConfig[] = []
  @State loadError: boolean = false
  @State hasMore: boolean = true
  @State isHeaderVisible: boolean = true
  @State detailOpen: boolean = false
  @State detailItems: ImageItem[] = []
  @State detailIndex: number = 0
  @State detailControls: boolean = true
  @State imageScale: number = 1
  private baseScale: number = 1
  @State imageOffsetX: number = 0
  @State imageOffsetY: number = 0
  private baseOffsetX: number = 0
  private baseOffsetY: number = 0
  @State detailFailed: boolean = false
  @State detailRetry: number = 0
  @State savingImage: boolean = false

  onActiveChanged(): void {
    if (this.isActive) {
      this.isHeaderVisible = true
      this.onNavigationVisibility(true)
      this.refreshTabs()
    }
  }
  aboutToAppear(): void { this.refreshTabs() }

  refreshTabs(): void {
    if (this.filterRevision !== this.repo.getFilterRevision()) {
      this.filterRevision = this.repo.getFilterRevision()
      this.requestVersion++
      this.sourceStates.clear()
      this.ds.clear()
      this.detailOpen = false
      this.detailItems = []
      this.loading = false
      this.refreshing = false
      this.loadError = false
      this.page = 1
      this.hasMore = true
    }
    this.enabledSources = this.repo.getEnabledConfigs()
    if (this.enabledSources.length === 0) {
      this.requestVersion++
      this.loading = false
      this.ds.clear()
      return
    }
    if (!this.enabledSources.some((item: SourceConfig): boolean => item.type === this.currentSource)) {
      this.switchSource(this.enabledSources[0].type)
    } else if (this.ds.isEmpty() && !this.loading) {
      this.refresh()
    }
  }

  sourceOptions(): SelectOption[] {
    return this.enabledSources.map((item: SourceConfig): SelectOption => ({ value: item.name }))
  }
  sourceName(): string {
    const config = this.enabledSources.find((item: SourceConfig): boolean => item.type === this.currentSource)
    return config ? config.name : '选择图源'
  }
  saveSource(): void {
    const state = new GallerySourceState()
    state.items = this.ds.getAll().slice()
    state.page = this.page
    state.hasMore = this.hasMore
    state.offsetY = this.scroller.currentOffset().yOffset
    this.sourceStates.set(this.currentSource, state)
  }
  switchSource(next: SourceType): void {
    if (next === this.currentSource && !this.ds.isEmpty()) return
    this.saveSource()
    this.requestVersion++
    this.currentSource = next
    this.loading = false
    this.refreshing = false
    this.loadError = false
    const cached = this.sourceStates.get(next)
    if (cached && cached.items.length > 0) {
      this.ds.replace(cached.items)
      this.page = cached.page
      this.hasMore = cached.hasMore
      setTimeout(() => {
        if (this.currentSource === next) this.scroller.scrollTo({ xOffset: 0, yOffset: cached.offsetY })
      }, 100)
    } else {
      this.ds.clear()
      this.refresh()
    }
  }
  async load(requestPage: number, version: number): Promise<void> {
    this.loading = true
    this.loadError = false
    try {
      const list = await this.repo.load(this.currentSource, requestPage)
      if (version !== this.requestVersion) return
      if (requestPage === 1) this.ds.replace(list)
      else this.ds.append(list)
      this.page = requestPage
      this.hasMore = list.length > 0
    } catch (err) {
      if (version === this.requestVersion) {
        this.loadError = true
        hilog.error(0xFF00, 'GalleryView', 'Load failed: %{public}s', JSON.stringify(err))
      }
    } finally {
      if (version === this.requestVersion) { this.loading = false; this.refreshing = false }
    }
  }
  async refresh(): Promise<void> {
    const version = ++this.requestVersion
    this.page = 1
    this.hasMore = true
    this.scroller.scrollToIndex(0)
    await this.load(1, version)
  }
  async loadMore(): Promise<void> {
    if (!this.loading && this.hasMore && !this.loadError && this.enabledSources.length > 0) {
      await this.load(this.page + 1, this.requestVersion)
    }
  }
  openDetail(item: ImageItem): void {
    this.detailItems = this.ds.getAll().slice()
    this.detailIndex = Math.max(0, this.detailItems.findIndex((entry: ImageItem): boolean => entry.id === item.id))
    this.detailControls = true
    this.imageScale = 1
    this.imageOffsetX = 0
    this.imageOffsetY = 0
    this.detailFailed = false
    this.detailOpen = true
  }

  async shareImage(): Promise<void> {
    if (this.detailItems.length === 0) return
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      await ImageActions.share(context, this.detailItems[this.detailIndex])
    } catch (err) {
      this.getUIContext().getPromptAction().showToast({ message: '无法打开分享面板' })
    }
  }

  async openOriginal(): Promise<void> {
    if (this.detailItems.length === 0) return
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      await ImageActions.openOriginal(context, this.detailItems[this.detailIndex])
    } catch (err) {
      this.getUIContext().getPromptAction().showToast({ message: '无法打开原图链接' })
    }
  }

  async saveImage(): Promise<void> {
    if (this.savingImage || this.detailItems.length === 0) return
    this.savingImage = true
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      if (await ImageActions.save(context, this.detailItems[this.detailIndex])) {
        this.getUIContext().getPromptAction().showToast({ message: '图片已保存' })
      }
    } catch (err) {
      this.getUIContext().getPromptAction().showToast({ message: '保存失败，请重试' })
    } finally {
      this.savingImage = false
    }
  }

  @Builder
  galleryFooter() {
    Column().width('100%').height(this.bottomInset)
  }

  @Builder
  detailBuilder() {
    Stack({ alignContent: Alignment.Center }) {
      Swiper() {
        ForEach(this.detailItems, (item: ImageItem) => {
          Stack({ alignContent: Alignment.Center }) {
            Image(item.imageUrl)
              .id(`${item.id}_detail_${this.detailRetry}`)
              .width('100%').height('100%')
              .objectFit(this.fitMode === 'cover' ? ImageFit.Cover : ImageFit.Contain)
              .scale({ x: this.imageScale, y: this.imageScale })
              .translate({ x: this.imageOffsetX, y: this.imageOffsetY })
              .onError(() => { this.detailFailed = true })
              .onComplete(() => { this.detailFailed = false })
              .gesture(GestureGroup(GestureMode.Parallel,
                PinchGesture().onActionStart(() => { this.baseScale = this.imageScale })
                  .onActionUpdate((event: GestureEvent) => {
                    this.imageScale = Math.max(1, Math.min(4, this.baseScale * event.scale))
                  }),
                PanGesture().onActionStart(() => {
                  this.baseOffsetX = this.imageOffsetX
                  this.baseOffsetY = this.imageOffsetY
                }).onActionUpdate((event: GestureEvent) => {
                  if (this.imageScale > 1 || this.fitMode === 'cover') {
                    this.imageOffsetX = this.baseOffsetX + event.offsetX
                    this.imageOffsetY = this.baseOffsetY + event.offsetY
                  }
                }).onActionEnd((event: GestureEvent) => {
                  if (this.imageScale === 1 && this.fitMode === 'contain' && event.offsetY > 100) this.detailOpen = false
                }),
                TapGesture({ count: 2 }).onAction(() => {
                  this.imageScale = this.imageScale > 1 ? 1 : 2
                  this.imageOffsetX = 0; this.imageOffsetY = 0
                })
              ))
              .onClick(() => { this.detailControls = !this.detailControls })
            if (this.detailFailed) {
              Column({ space: 8 }) {
                Text('原图加载失败').fontSize(14).fontColor(AppTheme.color(this.isDark).textPrimary)
                GlassIconButton({ icon: $r('app.media.icon_refresh'), label: '重试加载原图', isDark: this.isDark,
                  onAction: () => { this.detailFailed = false; this.detailRetry++ } })
              }
            }
          }.width('100%').height('100%').clip(true)
        }, (item: ImageItem) => item.id)
      }
      .index(this.detailIndex).indicator(false).loop(false)
      .disableSwipe(this.imageScale > 1)
      .onChange((index: number) => {
        this.detailIndex = index; this.imageScale = 1; this.imageOffsetX = 0; this.imageOffsetY = 0; this.detailFailed = false
      })
      if (this.detailControls && this.detailItems.length > 0) {
        Column() {
          Row() {
            GlassIconButton({ icon: $r('app.media.icon_back'), label: '返回', isDark: this.isDark,
              onAction: () => { this.detailOpen = false } })
            Blank()
            Text(`${this.detailIndex + 1} / ${this.detailItems.length}`)
              .fontColor(AppTheme.color(this.isDark).overlayTitle)
          }.width('100%').padding(16)
          Blank()
          Column({ space: 10 }) {
            Text(this.detailItems[this.detailIndex].title || this.detailItems[this.detailIndex].source)
              .fontSize(15).fontWeight(FontWeight.Medium).maxLines(2)
              .fontColor(AppTheme.color(this.isDark).overlayText)
            Text(`来源 · ${this.detailItems[this.detailIndex].source}`)
              .fontSize(12).fontColor(AppTheme.color(this.isDark).overlayMutedText)
            Row({ space: 12 }) {
              GlassIconButton({ icon: $r('app.media.icon_open'), label: '查看原图', isDark: this.isDark,
                onAction: () => { this.openOriginal() } })
              GlassIconButton({ icon: $r('app.media.icon_fit'),
                label: this.fitMode === 'contain' ? '切换为铺满' : '切换为适应', isDark: this.isDark,
                onAction: () => {
                  this.fitMode = this.fitMode === 'contain' ? 'cover' : 'contain'
                  this.imageScale = 1; this.imageOffsetX = 0; this.imageOffsetY = 0
                } })
              GlassIconButton({ icon: $r('app.media.icon_save'), label: this.savingImage ? '保存中' : '保存图片',
                isDark: this.isDark, busy: this.savingImage, onAction: () => { this.saveImage() } })
              GlassIconButton({ icon: $r('app.media.icon_share'), label: '分享链接', isDark: this.isDark,
                onAction: () => { this.shareImage() } })
            }.width('100%')
          }
          .width('100%').padding(18)
          .backgroundColor(AppTheme.color(this.isDark).glassSurface)
          .backgroundBlurStyle(BlurStyle.Thin)
          .borderRadius({ topLeft: 24, topRight: 24 })
          .border({ width: 1, color: AppTheme.color(this.isDark).glassBorder })
        }.width('100%').height('100%').hitTestBehavior(HitTestMode.Transparent)
      }
    }
    .width('100%').height('100%')
    .backgroundColor(AppTheme.color(this.isDark).background)
  }

  build() {
    Column() {
      Row() {
        Text('AnimeLens').fontSize(24).fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.color(this.isDark).galleryTitle)
        Blank()
        if (this.enabledSources.length > 0) {
          Select(this.sourceOptions())
            .value(this.sourceName())
            .fontColor(AppTheme.color(this.isDark).textPrimary)
            .optionFontColor(AppTheme.color(this.isDark).textPrimary)
            .menuBackgroundColor(AppTheme.color(this.isDark).menuBackground)
            .menuBackgroundBlurStyle(BlurStyle.NONE)
            .selectedOptionBgColor(AppTheme.color(this.isDark).menuSelection)
            .selectedOptionFontColor(AppTheme.color(this.isDark).textPrimary)
            .backgroundColor(AppTheme.color(this.isDark).glassControl)
            .backgroundBlurStyle(BlurStyle.Thin).borderRadius(20)
            .border({ width: 1, color: AppTheme.color(this.isDark).glassBorder })
            .onSelect((index: number) => {
              if (index >= 0 && index < this.enabledSources.length) this.switchSource(this.enabledSources[index].type)
            })
        }
      }
      .width('100%').height(this.isHeaderVisible ? 60 : 0)
      .opacity(this.isHeaderVisible ? 1 : 0)
      .padding({ left: 16, right: 16 }).clip(true)
      .backgroundColor(AppTheme.color(this.isDark).background)
      .animation({ duration: 220, curve: Curve.EaseInOut })
      Refresh({ refreshing: $$this.refreshing }) {
        WaterFlow({ scroller: this.scroller, footer: this.galleryFooter }) {
          LazyForEach(this.ds, (item: ImageItem) => {
            FlowItem() { ACGCard({ item: item, isDark: this.isDark, onOpen: (selected: ImageItem) => this.openDetail(selected) }) }
          }, (item: ImageItem) => `${item.source}_${item.id}`)
        }
        .columnsTemplate(this.galleryWidth >= 840 ? '1fr 1fr 1fr 1fr' : (this.galleryWidth >= 600 ? '1fr 1fr 1fr' : '1fr 1fr'))
        .columnsGap(8).rowsGap(8).padding({ left: 16, right: 16 })
        .onAreaChange((oldArea: Area, newArea: Area) => {
          this.galleryWidth = Number(newArea.width)
        })
        .onReachEnd(() => { this.loadMore() })
        .onScrollFrameBegin((offset: number, state: ScrollState) => {
          if (state !== ScrollState.Idle && Math.abs(offset) > 0.1) {
            const direction = offset > 0 ? 1 : -1
            if (direction !== this.scrollDirection) { this.scrollDirection = direction; this.scrollDistance = 0 }
            this.scrollDistance += Math.abs(offset)
            if (this.scrollDistance >= 24) {
              const visible = direction < 0
              if (this.isHeaderVisible !== visible) {
                this.getUIContext().animateTo({ duration: 220, curve: Curve.EaseInOut }, () => {
                  this.isHeaderVisible = visible
                  this.onNavigationVisibility(visible)
                })
              }
              this.scrollDistance = 0
            }
          }
          return { offsetRemain: offset }
        })
      }
      .layoutWeight(1).width('100%')
      .onRefreshing(() => { this.refresh() })
      if ((this.loading && !this.refreshing) || this.loadError || this.enabledSources.length === 0 || (!this.hasMore && this.ds.isEmpty())) {
        Row() {
          if (this.loading && !this.refreshing) { LoadingProgress().width(20).height(20); Text(' 加载中…') }
          else if (this.enabledSources.length === 0) { Text('请在设置中启用图源') }
          else if (this.loadError) {
            Text('加载失败').fontColor(AppTheme.color(this.isDark).textPrimary)
            GlassIconButton({ icon: $r('app.media.icon_refresh'), label: '重试加载图片', isDark: this.isDark,
              onAction: () => { this.load(this.ds.isEmpty() ? 1 : this.page + 1, this.requestVersion) } })
          }
          else { Text('暂无图片') }
        }.width('100%').height(48).justifyContent(FlexAlign.Center)
          .margin({ bottom: this.bottomInset })
      }
    }
    .width('100%').height('100%')
    .backgroundColor(AppTheme.color(this.isDark).background)
    .bindContentCover(this.detailOpen, this.detailBuilder(), {
      modalTransition: ModalTransition.ALPHA,
      onDisappear: () => { this.detailOpen = false }
    })
  }
}
