import { SymbolGlyphModifier } from '@kit.ArkUI'
import { GalleryView } from '../components/GalleryView'
import { SettingsView } from '../components/SettingsView'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @State galleryIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.photo'))
  @State settingsIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.gearshape'))

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        GalleryView({ isActive: this.currentIndex === 0 })
      }
      .tabBar(new BottomTabBarStyle({ normal: this.galleryIcon }, '浏览'))

      TabContent() {
        SettingsView()
      }
      .tabBar(new BottomTabBarStyle({ normal: this.settingsIcon }, '设置'))
    }
    .width('100%')
    .height('100%')
    .scrollable(false)
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }
}
