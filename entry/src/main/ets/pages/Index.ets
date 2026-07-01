import { GalleryView } from '../components/GalleryView'
import { SettingsView } from '../components/SettingsView'

@Entry
@Component
struct Index {
  private tabsController: TabsController = new TabsController()
  @State currentIndex: number = 0

  @Builder
  DockItemBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(13)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#666666')
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)

      if (this.currentIndex === index) {
        Circle()
          .width(4)
          .height(4)
          .fill('#007DFF')
          .margin({ top: 4 })
      }
    }
    .width("100%")
    .height("100%")
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      // ===== 鸿蒙标准 Tab 容器 =====
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {

        // 浏览视图组件化：传入当前是否处于活跃页，用于按需自动同步刷新
        TabContent() {
          GalleryView({ isActive: this.currentIndex === 0 })
        }
        .tabBar(this.DockItemBuilder("浏览", 0))

        // 设置视图组件化
        TabContent() {
          SettingsView()
        }
        .tabBar(this.DockItemBuilder("设置", 1))

      }
      .width("100%")
      .layoutWeight(1)
      .barHeight(56)
      .backgroundColor('#FFFFFF')
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
    .width("100%")
    .height("100%")
  }
}