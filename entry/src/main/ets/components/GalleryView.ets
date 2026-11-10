import { ImageRepository, SourceType } from '../service/ImageRepository'
import { WaterFlowDataSource } from '../datasource/WaterFlowDataSource'
import { ImageItem } from '../model/ImageItem'
import { ACGCard } from './ACGCard'
import { SourceConfig } from '../model/SourceConfig'
import hilog from '@ohos.hilog'

const LOG_DOMAIN = 0xFF00
const LOG_TAG = 'GalleryView'

@Component
export struct GalleryView {
  private repo = ImageRepository.getInstance()
  private ds = new WaterFlowDataSource()
  private scroller: Scroller = new Scroller()

  @State page: number = 1
  @State loading: boolean = false
  @State currentSource: SourceType = SourceType.PICSUM
  @State enabledSources: SourceConfig[] = []
  @State loadError: boolean = false
  @State hasMore: boolean = true
  private requestVersion: number = 0

  // ===== 控制顶部 Header（标题+图源选择器）的显隐状态 =====
  @State isHeaderVisible: boolean = true

  // 核心监视器：由父容器传入 active 状态
  @Prop @Watch('onActiveChanged') isActive: boolean = false

  onActiveChanged() {
    if (this.isActive) {
      hilog.info(LOG_DOMAIN, LOG_TAG, '[Watch] Active changed to true, refreshing tabs')
      this.refreshTabs()
    }
  }

  aboutToAppear() {
    this.refreshTabs()
  }

  refreshTabs() {
    this.enabledSources = this.repo.getEnabledConfigs()
    if (this.enabledSources.length === 0) {
      this.requestVersion++
      this.loading = false
      this.ds.clear()
      return
    }
    const stillEnabled = this.enabledSources.some(item => item.type === this.currentSource)
    if (!stillEnabled) {
      this.currentSource = this.enabledSources[0].type
    }
    this.repo.setSource(this.currentSource)
    this.refresh()
  }

  async load(requestPage: number, version: number) {
    this.loading = true
    this.loadError = false
    try {
      const list = await this.repo.load(requestPage)
      if (version !== this.requestVersion) return

      if (requestPage === 1) {
        this.ds.replace(list)
      } else {
        this.ds.append(list)
      }
      this.page = requestPage
      this.hasMore = list.length > 0
    } catch (err) {
      if (version === this.requestVersion) {
        this.loadError = true
        hilog.error(LOG_DOMAIN, LOG_TAG, '[NetworkError] %{public}s', JSON.stringify(err))
      }
    } finally {
      if (version === this.requestVersion) this.loading = false
    }
  }

  async refresh() {
    const version = ++this.requestVersion
    this.page = 1
    this.hasMore = true
    this.scroller.scrollToIndex(0)
    const emptyList: ImageItem[] = []
    this.ds.replace(emptyList)
    await this.load(1, version)
  }

  async loadMore() {
    if (this.loading || !this.hasMore || this.loadError || this.enabledSources.length === 0) return
    await this.load(this.page + 1, this.requestVersion)
  }

  // ===== 美化版的胶囊 Tab 按钮 (已修复 ArkTS 变量声明报错) =====
  @Builder
  TabButton(title: string, type: SourceType) {
    Text(title)
      .fontSize(13)
      .fontWeight(this.currentSource === type ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.currentSource === type ? '#FFFFFF' : '#64748B')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.currentSource === type ? '#2563EB' : '#FFFFFF')
      .borderRadius(20)
      .shadow(this.currentSource === type ? { radius: 8, color: '#3B82F640', offsetY: 3 } : { radius: 0 })
      .animation({ duration: 250, curve: Curve.FastOutSlowIn })
      .margin({ right: 8 })
      .onClick(() => {
        if (this.currentSource !== type) {
          this.currentSource = type
          this.repo.setSource(type)
          this.refresh()
        }
      })
  }

  build() {
    Column() {
      // ==========================================
      // ===== 顶部可收起的 Header 区域 (标题 + 胶囊) =====
      // ==========================================
      Column() {
        // --- 标题栏 ---
        Row() {
          Text("AnimeLens")
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
            .letterSpacing(0.5)

          // 装饰小圆点
          Circle({ width: 6, height: 6 })
            .fill('#2563EB')
            .margin({ left: 4, bottom: 12 })
        }
        .width("100%")
        .padding({ left: 16, top: 12, right: 16, bottom: 8 })
        .alignItems(VerticalAlign.Bottom)

        // --- 胶囊导航图源选择器 ---
        Scroll() {
          Row() {
            ForEach(this.enabledSources, (config: SourceConfig) => {
              this.TabButton(config.name, config.type)
            }, (config: SourceConfig) => config.name)
          }
          .padding({ left: 16, right: 16, top: 4, bottom: 6 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width("100%")
      }
      // 控制收起与展开的动画与高度
      .height(this.isHeaderVisible ? 'auto' : 0)
      .opacity(this.isHeaderVisible ? 1 : 0)
      .clip(true)
      .animation({ duration: 300, curve: Curve.FastOutSlowIn })

      // ==========================================
      // ===== 瀑布流主体 =====
      // ==========================================
      WaterFlow({ scroller: this.scroller }) {
        LazyForEach(this.ds, (item: ImageItem) => {
          FlowItem() {
            ACGCard({ item: item })
          }
        }, (item: ImageItem) => item.id)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .layoutWeight(1)
      .padding({ left: 12, right: 12, top: 4, bottom: 8 })
      .onReachEnd(() => {
        this.loadMore()
      })
      // 滚动时收起或展开图源选择器
      .onScrollFrameBegin((offset: number, state: ScrollState) => {
        // 设置 8px 防抖门限
        if (Math.abs(offset) > 8) {
          const isScrollingDown = offset > 0
          const newHeaderState = !isScrollingDown

          if (this.isHeaderVisible !== newHeaderState) {
            this.isHeaderVisible = newHeaderState

          }
        }
        return { offsetRemain: offset }
      })

      // ==========================================
      // ===== 底部低打扰加载反馈 =====
      // ==========================================
      Row() {
        if (this.loading) {
          LoadingProgress()
            .width(26)
            .height(26)
            .color('#2563EB')
          Text(" 加载中...")
            .fontSize(12)
            .fontColor('#94A3B8')
            .margin({ left: 6 })
        } else if (this.enabledSources.length === 0) {
          Text('请在设置中启用图源')
        } else if (this.loadError) {
          Button('加载失败，点击重试')
            .onClick(() => {
              if (this.ds.isEmpty()) {
                this.refresh()
              } else {
                this.load(this.page + 1, this.requestVersion)
              }
            })
        }
      }
      .width("100%")
      .height(this.loading || this.loadError || this.enabledSources.length === 0 ? 40 : 0)
      .animation({ duration: 200 })
      .justifyContent(FlexAlign.Center)
    }
    .width("100%")
    .height("100%")
    .backgroundColor('#F8FAFC')
  }
}
