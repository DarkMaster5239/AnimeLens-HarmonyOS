import { AppTheme } from '../theme/AppTheme'
import { uiMaterial } from '@kit.ArkUI'
import { deviceInfo } from '@kit.BasicServicesKit'
import { GalleryView } from '../features/gallery/GalleryView'
import { SettingsView } from '../features/settings/SettingsView'

PersistentStorage.persistProp('themeMode', 'system')
PersistentStorage.persistProp('imageFitMode', 'contain')
Environment.envProp('colorMode', ColorMode.LIGHT)

@Entry
@Component
struct Index {
  build() {
    Column() {
      AnimeLensNavigation()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct AnimeLensNavigation {
  @Prop previewGlass: boolean = false
  @State currentIndex: number = 0
  @State navVisible: boolean = true
  @StorageLink('themeMode') themeMode: string = 'system'
  @StorageProp('colorMode') systemColorMode: ColorMode = ColorMode.LIGHT

  isDark(): boolean {
    return this.themeMode === 'dark' || (this.themeMode === 'system' && this.systemColorMode === ColorMode.DARK)
  }

  @Builder
  galleryTab() {
    Column() {
      Text('浏览')
        .fontSize(16)
        .fontWeight(this.currentIndex === 0 ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentIndex === 0 ? (AppTheme.color(this.isDark()).tabSelected) : (AppTheme.color(this.isDark()).tabUnselected))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  settingsTab() {
    Column() {
      Text('设置')
        .fontSize(16)
        .fontWeight(this.currentIndex === 1 ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentIndex === 1 ? (AppTheme.color(this.isDark()).tabSelected) : (AppTheme.color(this.isDark()).tabUnselected))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      if (this.previewGlass || deviceInfo.apiAvailable('26.0.0')) {
        Tabs({ barPosition: BarPosition.End }) {
          TabContent() {
            GalleryView({ isActive: this.currentIndex === 0, bottomInset: 80, isDark: this.isDark(), onNavigationVisibility: (visible: boolean) => { this.navVisible = visible } })
          }.tabBar(this.galleryTab())
          TabContent() {
            SettingsView({ bottomInset: 80, isDark: this.isDark() })
          }.tabBar(this.settingsTab())
        }
        .width('100%')
        .height('100%')
        .barHeight(this.currentIndex === 0 && !this.navVisible ? 0 : 56)
        .barFloatingStyle(this.currentIndex !== 0 || this.navVisible ? {
          systemMaterial: new uiMaterial.ImmersiveMaterial({
            style: uiMaterial.ImmersiveStyle.ULTRA_THIN,
            interactive: true
          }),
          maskColor: Color.Transparent
        } : undefined)
        .barOverlap(true)
        .scrollable(false)
        .onChange((index: number) => {
          this.currentIndex = index
          if (index === 1) this.navVisible = true
        })
      } else {
        Tabs({ barPosition: BarPosition.End }) {
          TabContent() {
            GalleryView({ isActive: this.currentIndex === 0, isDark: this.isDark(), onNavigationVisibility: (visible: boolean) => { this.navVisible = visible } })
          }.tabBar(this.galleryTab())
          TabContent() {
            SettingsView({ isDark: this.isDark() })
          }.tabBar(this.settingsTab())
        }
        .width('100%')
        .height('100%')
        .barHeight(this.currentIndex === 0 && !this.navVisible ? 0 : 56)
        .barBackgroundColor(AppTheme.color(this.isDark()).background)
        .divider({ strokeWidth: 0.5, color: AppTheme.divider })
        .scrollable(false)
        .onChange((index: number) => {
          this.currentIndex = index
          if (index === 1) this.navVisible = true
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}


