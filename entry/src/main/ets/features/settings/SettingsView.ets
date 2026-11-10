import { GlassIconButton } from '../../components/common/GlassIconButton'
import { AppTheme } from '../../theme/AppTheme'
import { ImageRepository } from '../../service/ImageRepository'
import { SourceConfig, ConnectionStatus } from '../../model/SourceConfig'

@Component
export struct SettingsView {
  @Prop bottomInset: number = 0
  @Prop isDark: boolean = false
  @StorageLink('themeMode') themeMode: string = 'system'
  @StorageLink('imageFitMode') fitMode: string = 'contain'
  private repo = ImageRepository.getInstance()
  @State allConfigs: SourceConfig[] = []

  aboutToAppear() { this.refreshUI() }

  private refreshUI() { this.allConfigs = [...this.repo.getConfigs()] }

  build() {
    Column() {
      Column({ space: 4 }) {
        Text('设置').fontSize(28).fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.color(this.isDark).textPrimary)
      }
      .alignItems(HorizontalAlign.Start).width('100%')
      .padding({ left: 22, right: 22, top: 20, bottom: 16 })

      List({ space: 12 }) {
        ListItem() {
          Column({ space: 16 }) {
            Column({ space: 3 }) {
              Text('外观与浏览').fontSize(17).fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.color(this.isDark).textPrimary)
            }.alignItems(HorizontalAlign.Start).width('100%')
            Row() {
              Column({ space: 3 }) {
                Text('主题模式').fontSize(15).fontWeight(FontWeight.Medium)
                  .fontColor(AppTheme.color(this.isDark).textPrimary)
                Text('选择你喜欢的界面外观').fontSize(12)
                  .fontColor(AppTheme.color(this.isDark).textMuted)
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              Select([{ value: '跟随系统' }, { value: '浅色' }, { value: '深色' }])
                .selected(this.themeMode === 'system' ? 0 : (this.themeMode === 'light' ? 1 : 2))
                .value(this.themeMode === 'system' ? '跟随系统' : (this.themeMode === 'light' ? '浅色' : '深色'))
                .fontColor(AppTheme.color(this.isDark).textPrimary)
                .optionFontColor(AppTheme.color(this.isDark).textPrimary)
                .menuBackgroundColor(AppTheme.color(this.isDark).menuBackground)
                .menuBackgroundBlurStyle(BlurStyle.NONE)
                .selectedOptionBgColor(AppTheme.color(this.isDark).menuSelection)
                .selectedOptionFontColor(AppTheme.color(this.isDark).textPrimary)
                .backgroundColor(AppTheme.color(this.isDark).glassControl)
                .borderRadius(20)
                .onSelect((index: number) => { this.themeMode = index === 0 ? 'system' : (index === 1 ? 'light' : 'dark') })
            }.width('100%')
            Row() {
              Column({ space: 3 }) {
                Text('图片显示').fontSize(15).fontWeight(FontWeight.Medium)
                  .fontColor(AppTheme.color(this.isDark).textPrimary)
                Text('打开图片时的默认方式').fontSize(12)
                  .fontColor(AppTheme.color(this.isDark).textMuted)
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              Select([{ value: '完整显示' }, { value: '铺满屏幕' }])
                .selected(this.fitMode === 'contain' ? 0 : 1)
                .value(this.fitMode === 'contain' ? '完整显示' : '铺满屏幕')
                .fontColor(AppTheme.color(this.isDark).textPrimary)
                .optionFontColor(AppTheme.color(this.isDark).textPrimary)
                .menuBackgroundColor(AppTheme.color(this.isDark).menuBackground)
                .menuBackgroundBlurStyle(BlurStyle.NONE)
                .selectedOptionBgColor(AppTheme.color(this.isDark).menuSelection)
                .selectedOptionFontColor(AppTheme.color(this.isDark).textPrimary)
                .backgroundColor(AppTheme.color(this.isDark).glassControl)
                .borderRadius(20)
                .onSelect((index: number) => { this.fitMode = index === 0 ? 'contain' : 'cover' })
            }.width('100%')
          }
          .width('100%').padding(18).alignItems(HorizontalAlign.Start)
          .backgroundColor(AppTheme.color(this.isDark).glassSurface)
          .borderRadius(24)
        }
        ListItem() {
          Column({ space: 14 }) {
            Column({ space: 3 }) {
              Text('内容偏好').fontSize(17).fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.color(this.isDark).textPrimary)
            }.alignItems(HorizontalAlign.Start).width('100%')
            Row() {
              Column({ space: 3 }) {
                Text('非安全内容 (NSFW)').fontSize(15).fontWeight(FontWeight.Medium)
                  .fontColor(AppTheme.color(this.isDark).textPrimary)
                Text('允许显示敏感及限制级插画').fontSize(12)
                  .fontColor(AppTheme.color(this.isDark).textMuted)
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.repo.isNsfwEnabled() })
                .selectedColor(AppTheme.danger).backgroundColor(AppTheme.color(this.isDark).glassTrack)
                .switchPointColor(AppTheme.onPrimary)
                .onChange((isOn: boolean) => { this.repo.setNsfwEnabled(isOn); this.refreshUI() })
            }.width('100%')
          }
          .width('100%').padding(18).alignItems(HorizontalAlign.Start)
          .backgroundColor(AppTheme.color(this.isDark).glassSurface)
          .borderRadius(24)
        }
        ListItem() {
          Column({ space: 3 }) {
            Text('图源管理').fontSize(17).fontWeight(FontWeight.Bold)
              .fontColor(AppTheme.color(this.isDark).textPrimary)
            Text('启用图源或测试连接状态').fontSize(12)
              .fontColor(AppTheme.color(this.isDark).textMuted)
          }.alignItems(HorizontalAlign.Start).width('100%').padding({ left: 4, top: 8, bottom: 2 })
        }
        ListItemGroup() {
          ForEach(this.allConfigs, (config: SourceConfig) => {
            ListItem() {
              Row({ space: 10 }) {
                Column({ space: 4 }) {
                  Text(config.name).fontSize(15).fontWeight(FontWeight.Medium)
                    .fontColor(AppTheme.color(this.isDark).textPrimary)
                  if (config.status === ConnectionStatus.TESTING) {
                    Row({ space: 5 }) {
                      LoadingProgress().width(12).height(12).color(AppTheme.info)
                      Text('正在测速…').fontSize(12).fontColor(AppTheme.info)
                    }
                  } else if (config.status === ConnectionStatus.SUCCESS) {
                    Text(`正常 · ${config.latency} ms`).fontSize(12).fontColor(AppTheme.success)
                  } else if (config.status === ConnectionStatus.FAILED) {
                    Text('连接失败').fontSize(12).fontColor(AppTheme.danger)
                  } else {
                    Text('未测试').fontSize(12).fontColor(AppTheme.color(this.isDark).textMuted)
                  }
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                GlassIconButton({
                  icon: $r('app.media.icon_refresh'), isDark: this.isDark,
                  label: config.status === ConnectionStatus.TESTING ? `${config.name}测速中` : `测试${config.name}连接`,
                  busy: config.status === ConnectionStatus.TESTING,
                  onAction: async () => {
                    const pending = this.repo.testSource(config.type)
                    this.refreshUI()
                    await pending
                    this.refreshUI()
                  }
                })
                Toggle({ type: ToggleType.Switch, isOn: config.isEnabled })
                  .accessibilityText(`启用${config.name}`)
                  .selectedColor(AppTheme.color(this.isDark).switchSelected)
                  .backgroundColor(AppTheme.color(this.isDark).glassTrack).switchPointColor(AppTheme.onPrimary)
                  .onChange((isOn: boolean) => { this.repo.setSourceEnabled(config.type, isOn); this.refreshUI() })
              }
              .width('100%').padding({ left: 18, right: 16, top: 15, bottom: 15 })
            }
          }, (config: SourceConfig) => `${config.name}_${config.status}_${config.latency}_${config.isEnabled}`)
        }
        .backgroundColor(AppTheme.color(this.isDark).glassSurface).borderRadius(24)
        ListItem() { Column().height(this.bottomInset + 4) }
      }
      .width('100%').layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
    .width('100%').height('100%')
    .backgroundColor(AppTheme.color(this.isDark).background)
  }
}
