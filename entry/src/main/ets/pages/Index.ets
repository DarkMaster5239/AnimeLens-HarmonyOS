import { window } from '@kit.ArkUI'
import { AppTheme } from '../theme/AppTheme'
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
  @State @Watch('syncSystemBars') currentIndex: number = 0
  @State navVisible: boolean = true
  private tabsController: TabsController = new TabsController()
  @StorageLink('themeMode') @Watch('syncSystemBars') themeMode: string = 'system'
  @StorageProp('colorMode') @Watch('syncSystemBars') systemColorMode: ColorMode = ColorMode.LIGHT

  aboutToAppear(): void { this.syncSystemBars() }

  private async syncSystemBars(): Promise<void> {
    const context = this.getUIContext().getHostContext()
    if (!context) return
    const dark = this.isDark()
    const background = this.currentIndex === 1 ? (dark ? '#080C14' : '#EEF2F9') : AppTheme.color(dark).background
    try {
      const mainWindow = await window.getLastWindow(context)
      mainWindow.setWindowBackgroundColor(background)
      await mainWindow.setWindowSystemBarProperties({
        statusBarColor: AppTheme.color(dark).galleryHeaderTop,
        navigationBarColor: background,
        statusBarContentColor: dark ? '#FFFFFF' : '#0F172A',
        navigationBarContentColor: dark ? '#FFFFFF' : '#0F172A'
      })
    } catch (err) {
      console.warn('Unable to synchronize system bar colors', String(err))
    }
  }

  isDark(): boolean {
    return this.themeMode === 'dark' || (this.themeMode === 'system' && this.systemColorMode === ColorMode.DARK)
  }

  @Builder
  galleryTab() {
    Row({ space: 6 }) {
      Image($r('app.media.icon_gallery'))
        .width(20).height(20)
        .fillColor(this.currentIndex === 0 ? (this.isDark() ? '#00D5FF' : '#054ACB') : AppTheme.color(this.isDark()).tabUnselected)
      Text('浏览')
        .fontSize(12)
        .fontWeight(this.currentIndex === 0 ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentIndex === 0 ? (this.isDark() ? '#00D5FF' : '#054ACB') : AppTheme.color(this.isDark()).tabUnselected)
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .borderRadius(20)
    .backgroundColor(this.currentIndex === 0 ? (this.isDark() ? '#12335A' : '#E2ECFF') : Color.Transparent)
    .animation({ duration: 180, curve: Curve.EaseInOut })
    .accessibilityText(this.currentIndex === 0 ? '浏览，已选中' : '浏览')
  }

  @Builder
  settingsTab() {
    Row({ space: 6 }) {
      Image($r('app.media.icon_settings'))
        .width(20).height(20)
        .fillColor(this.currentIndex === 1 ? (this.isDark() ? '#00D5FF' : '#054ACB') : AppTheme.color(this.isDark()).tabUnselected)
      Text('设置')
        .fontSize(12)
        .fontWeight(this.currentIndex === 1 ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentIndex === 1 ? (this.isDark() ? '#00D5FF' : '#054ACB') : AppTheme.color(this.isDark()).tabUnselected)
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .borderRadius(20)
    .backgroundColor(this.currentIndex === 1 ? (this.isDark() ? '#12335A' : '#E2ECFF') : Color.Transparent)
    .animation({ duration: 180, curve: Curve.EaseInOut })
    .accessibilityText(this.currentIndex === 1 ? '设置，已选中' : '设置')
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() {
          GalleryView({ isActive: this.currentIndex === 0, bottomInset: 80, isDark: this.isDark(),
            onNavigationVisibility: (visible: boolean) => { this.navVisible = visible } })
        }.tabBar('浏览')
        TabContent() {
          SettingsView({ bottomInset: 80, isDark: this.isDark() })
        }.tabBar('设置')
      }
      .width('100%')
      .height('100%')
      .barHeight(0)
      .scrollable(false)
      .onChange((index: number) => {
        this.currentIndex = index
        if (index === 1) this.navVisible = true
      })

      if (this.currentIndex !== 0 || this.navVisible) {
        Row({ space: 4 }) {
          Button({ type: ButtonType.Capsule }) {
            this.galleryTab()
          }
          .backgroundColor(Color.Transparent)
          .padding(0)
          .accessibilityText(this.currentIndex === 0 ? '浏览，已选中' : '浏览')
          .onClick(() => { this.tabsController.changeIndex(0) })

          Button({ type: ButtonType.Capsule }) {
            this.settingsTab()
          }
          .backgroundColor(Color.Transparent)
          .padding(0)
          .accessibilityText(this.currentIndex === 1 ? '设置，已选中' : '设置')
          .onClick(() => { this.tabsController.changeIndex(1) })
        }
        .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        .margin({ bottom: 14 })
        .borderRadius(32)
        .backgroundColor(this.isDark() ? '#ED111827' : '#F2FFFFFF')
        .border({ width: 0.8, color: this.isDark() ? '#26FFFFFF' : '#D9E2EBF5' })
        .shadow({ radius: 12, color: this.isDark() ? '#30000000' : '#140F172A', offsetY: 4 })
      }
    }
    .width('100%')
    .height('100%')
  }
}

