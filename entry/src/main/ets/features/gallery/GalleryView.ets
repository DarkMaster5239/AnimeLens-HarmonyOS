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
                Text('原图加载失败').fontSize(14).fontColor(Color.White)
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
          // Top Control Bar
          Row() {
            GlassIconButton({
              icon: $r('app.media.icon_back'),
              label: '返回',
              isDark: true,
              onAction: () => { this.detailOpen = false }
            })
            Blank()
            Row({ space: 4 }) {
              Text(`${this.detailIndex + 1}`)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text(`/ ${this.detailItems.length}`)
                .fontSize(12)
                .fontColor('rgba(255, 255, 255, 0.6)')
            }
            .padding({ left: 14, right: 14, top: 7, bottom: 7 })
            .backgroundColor('rgba(11, 15, 25, 0.65)')
            .backgroundBlurStyle(BlurStyle.Thin)
            .borderRadius(16)
            .border({ width: 0.8, color: 'rgba(255, 255, 255, 0.15)' })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })

          Blank()

          // Bottom Floating Island Card
          Column({ space: 12 }) {
            Row() {
              Column({ space: 3 }) {
                Text(this.detailItems[this.detailIndex].title || this.detailItems[this.detailIndex].source)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontColor(AppTheme.color(this.isDark).overlayTitle)

                Row({ space: 6 }) {
                  Text(this.detailItems[this.detailIndex].source.toUpperCase())
                    .fontSize(11)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(AppTheme.color(this.isDark).overlayAccentText)

                  if (this.detailItems[this.detailIndex].width > 0 && this.detailItems[this.detailIndex].height > 0) {
                    Text(`· ${this.detailItems[this.detailIndex].width} × ${this.detailItems[this.detailIndex].height}`)
                      .fontSize(11)
                      .fontColor(AppTheme.color(this.isDark).overlayMutedText)
                  }
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            Row({ space: 10 }) {
              // Primary Action: Save Wallpapers
              Button({ type: ButtonType.Normal }) {
                Row({ space: 6 }) {
                  if (this.savingImage) {
                    LoadingProgress().width(18).height(18).color(Color.White)
                    Text('保存中…').fontSize(13).fontWeight(FontWeight.Medium).fontColor(Color.White)
                  } else {
                    Image($r('app.media.icon_save')).width(18).height(18).fillColor(Color.White)
                    Text('保存壁纸').fontSize(13).fontWeight(FontWeight.Bold).fontColor(Color.White)
                  }
                }
              }
              .layoutWeight(1)
              .height(44)
              .borderRadius(22)
              .backgroundColor(AppTheme.color(this.isDark).primaryButton)
              .linearGradient({ direction: GradientDirection.Right, colors: [['#2563EB', 0], ['#4F46E5', 1]] })
              .shadow({ radius: 8, color: 'rgba(10, 89, 247, 0.35)', offsetY: 2 })
              .enabled(!this.savingImage)
              .onClick(() => { this.saveImage() })

              // Secondary Actions
              GlassIconButton({
                icon: $r('app.media.icon_open'),
                label: '查看原图',
                isDark: this.isDark,
                onAction: () => { this.openOriginal() }
              })
              GlassIconButton({
                icon: $r('app.media.icon_fit'),
                label: this.fitMode === 'contain' ? '切换为铺满' : '切换为适应',
                isDark: this.isDark,
                onAction: () => {
                  this.fitMode = this.fitMode === 'contain' ? 'cover' : 'contain'
                  this.imageScale = 1; this.imageOffsetX = 0; this.imageOffsetY = 0
                }
              })
              GlassIconButton({
                icon: $r('app.media.icon_share'),
                label: '分享链接',
                isDark: this.isDark,
                onAction: () => { this.shareImage() }
              })
            }
            .width('100%')
          }
          .width('92%')
          .margin({ bottom: 20 })
          .padding(16)
          .backgroundColor(AppTheme.color(this.isDark).glassSurface)
          .backgroundBlurStyle(BlurStyle.Thin)
          .borderRadius(22)
          .shadow({ radius: 18, color: '#40000000', offsetY: 6 })
          .border({ width: 0.8, color: AppTheme.color(this.isDark).glassBorder })
        }
        .width('100%')
        .height('100%')
        .hitTestBehavior(HitTestMode.Transparent)
      }
    }
    .width('100%').height('100%')
    .backgroundColor('#000000')
  }

  build() {
    Column() {
      // Luminous header: quiet surfaces and a single blue-cyan selection accent.
      Column() {
        Row() {
          Column({ space: 6 }) {
            Text('ACG绘见')
              .fontSize('28fp')
              .fontWeight(FontWeight.Bold)
              .fontColor(AppTheme.color(this.isDark).galleryTitle)
            Text('精选二次元插画与壁纸')
              .fontSize('13fp')
              .fontColor(AppTheme.color(this.isDark).galleryMuted)
          }
          .alignItems(HorizontalAlign.Start).layoutWeight(1)

          Button({ type: ButtonType.Circle }) {
            if (this.refreshing) {
              LoadingProgress().width(20).height(20).color(AppTheme.color(this.isDark).galleryAccent)
            } else {
              Image($r('app.media.icon_refresh')).width(20).height(20)
                .fillColor(AppTheme.color(this.isDark).galleryAccent)
            }
          }
          .width(48).height(48)
          .backgroundColor(AppTheme.color(this.isDark).gallerySelection)
          .enabled(!this.refreshing)
          .accessibilityText(this.refreshing ? '正在刷新画廊' : '刷新画廊')
          .onClick(() => { this.refresh() })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 12 })

        if (this.enabledSources.length > 0) {
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.enabledSources, (config: SourceConfig) => {
                Button({ type: ButtonType.Capsule }) {
                  Text(config.name)
                    .fontSize('14fp')
                    .fontWeight(this.currentSource === config.type ? FontWeight.Medium : FontWeight.Normal)
                    .fontColor(this.currentSource === config.type ? AppTheme.color(this.isDark).galleryAccent : AppTheme.color(this.isDark).textSecondary)
                    .padding({ top: 10, bottom: 10 })
                }
                .constraintSize({ minHeight: 48 })
                .padding({ left: 16, right: 16 })
                .borderRadius(22)
                .backgroundColor(this.currentSource === config.type ?
                  AppTheme.color(this.isDark).gallerySelection : Color.Transparent)
                .accessibilitySelected(this.currentSource === config.type)
                .accessibilityText(`${config.name}${this.currentSource === config.type ? '，已选中' : ''}`)
                .onClick(() => {
                  this.switchSource(config.type)
                })
              }, (config: SourceConfig) => `${config.type}_${config.name}`)
            }
            .padding({ left: 20, right: 20, bottom: 12 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height(this.isHeaderVisible ? undefined : 0)
      .opacity(this.isHeaderVisible ? 1 : 0)
      .clip(true)
      .linearGradient({ direction: GradientDirection.Bottom, colors: [
        [AppTheme.color(this.isDark).galleryHeaderTop, 0],
        [AppTheme.color(this.isDark).background, 1]
      ] })
      .animation({ duration: 220, curve: Curve.EaseInOut })

      // 2. Waterfall Feed
      Refresh({ refreshing: $$this.refreshing }) {
        WaterFlow({ scroller: this.scroller, footer: this.galleryFooter }) {
          LazyForEach(this.ds, (item: ImageItem) => {
            FlowItem() { ACGCard({ item: item, isDark: this.isDark, onOpen: (selected: ImageItem) => this.openDetail(selected) }) }
          }, (item: ImageItem) => `${item.source}_${item.id}`)
        }
        .columnsTemplate(this.galleryWidth >= 840 ? '1fr 1fr 1fr 1fr' : (this.galleryWidth >= 600 ? '1fr 1fr 1fr' : '1fr 1fr'))
        .columnsGap(8).rowsGap(8).padding({ left: 10, right: 10, top: 8 })
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

      // 3. Status Banner
      if ((this.loading && !this.refreshing) || this.loadError || this.enabledSources.length === 0 || (!this.hasMore && this.ds.isEmpty())) {
        Row({ space: 8 }) {
          if (this.loading && !this.refreshing) {
            LoadingProgress().width(18).height(18).color(AppTheme.color(this.isDark).primaryButton)
            Text('加载中…').fontSize(12).fontColor(AppTheme.color(this.isDark).textSecondary)
          } else if (this.enabledSources.length === 0) {
            Text('请在设置中启用图源').fontSize(12).fontColor(AppTheme.color(this.isDark).textMuted)
          } else if (this.loadError) {
            Text('加载失败').fontSize(12).fontColor(AppTheme.danger)
            GlassIconButton({
              icon: $r('app.media.icon_refresh'),
              label: '重试加载图片',
              isDark: this.isDark,
              btnSize: 44,
              iconSize: 16,
              onAction: () => { this.load(this.ds.isEmpty() ? 1 : this.page + 1, this.requestVersion) }
            })
          } else {
            Text('已加载全部插画').fontSize(12).fontColor(AppTheme.color(this.isDark).textMuted)
          }
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .borderRadius(20)
        .backgroundColor(AppTheme.color(this.isDark).glassSurface)
        .backgroundBlurStyle(BlurStyle.Thin)
        .border({ width: 0.8, color: AppTheme.color(this.isDark).glassBorder })
        .margin({ bottom: this.bottomInset + 8 })
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
