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

  // 1. 核心监视器：由父容器传入 active 状态，切回时自动检测配置变更
  @Prop @Watch('onActiveChanged') isActive: boolean = false

  onActiveChanged() {
    if (this.isActive) {
      hilog.info(LOG_DOMAIN, LOG_TAG, '[Watch] Active changed to true, refreshing tabs')
      this.refreshTabs()
    }
  }

  aboutToAppear() {
    this.refreshTabs()
    this.load()
  }

  refreshTabs() {
    this.enabledSources = this.repo.getEnabledConfigs()
    // 容错：如果当前正在看的源被禁用了，自动切回已启用的第一个源
    const stillEnabled = this.enabledSources.some(item => item.type === this.currentSource)
    if (!stillEnabled && this.enabledSources.length > 0) {
      this.currentSource = this.enabledSources[0].type
      this.repo.setSource(this.currentSource)
      this.refresh()
    }
  }

  async load() {
    this.loading = true
    try {
      const list = await this.repo.load(this.page)
      if (!list) return

      if (this.page === 1) {
        this.ds.replace(list)
      } else {
        this.ds.append(list)
      }
    } catch (err) {
      hilog.error(LOG_DOMAIN, LOG_TAG, '[NetworkError] %{public}s', JSON.stringify(err))
    } finally {
      this.loading = false
    }
  }

  async refresh() {
    this.page = 1
    this.scroller.scrollToIndex(0)
    const emptyList: ImageItem[] = []
    this.ds.replace(emptyList)
    await this.load()
  }

  async loadMore() {
    if (this.loading) return
    this.page++
    await this.load()
  }

  @Builder
  TabButton(title: string, type: SourceType) {
    Text(title)
      .fontSize(13)
      .fontWeight(this.currentSource === type ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.currentSource === type ? '#FFFFFF' : '#555555')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.currentSource === type ? '#007DFF' : '#EEEFf2')
      .borderRadius(18)
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
      // ===== ACG Header Title =====
      Row() {
        Text("AnimeLens")
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
      }
      .width("100%")
      .padding({ left: 16, top: 16, right: 16, bottom: 8 })

      // ===== 胶囊导航选择器 =====
      Scroll() {
        Row() {
          ForEach(this.enabledSources, (config: SourceConfig) => {
            this.TabButton(config.name, config.type)
          }, (config: SourceConfig) => config.name)
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width("100%")
      .margin({ bottom: 12 })

      // ===== 瀑布流组件 =====
      WaterFlow({ scroller: this.scroller }) {
        LazyForEach(this.ds, (item: ImageItem) => {
          FlowItem() {
            ACGCard({ item: item })
          }
        }, (item: ImageItem) => item.id)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .layoutWeight(1)
      .padding({ left: 12, right: 12 })
      .onReachEnd(() => {
        this.loadMore()
      })

      // ===== 底部低打扰加载反馈 =====
      Row() {
        if (this.loading) {
          LoadingProgress()
            .width(32)
            .height(32)
            .color('#007DFF')
        }
      }
      .width("100%")
      .height(50)
      .justifyContent(FlexAlign.Center)
    }
    .width("100%")
    .height("100%")
  }
}