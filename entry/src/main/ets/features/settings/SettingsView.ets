import { AppTheme } from '../../theme/AppTheme'
import { ImageRepository } from '../../service/ImageRepository'
import { SourceConfig, ConnectionStatus } from '../../model/SourceConfig'

// Page-scoped Luminous tokens keep the gallery and navigation palettes independent.
class SettingsLuminousColors {
  background: string = '#EEF2F9'
  surface: string = '#FFFFFF'
  base: string = '#F5F7FC'
  border: string = '#E1E7F0'
  accent: string = '#054ACB'
  selected: string = '#E2ECFF'
  muted: string = '#5C6C84'
  positive: string = '#067647'
  error: string = '#B42318'

  constructor(isDark: boolean) {
    if (isDark) {
      this.background = '#080C14'
      this.surface = '#121A2C'
      this.base = '#0B101D'
      this.border = '#243047'
      this.accent = '#00D5FF'
      this.selected = '#12335A'
      this.muted = '#93A3BE'
      this.positive = '#00E599'
      this.error = '#FF8F88'
    }
  }
}

@Component
struct SettingsLuminousChoice {
  @Prop optionLabel: string = ''
  @Prop optionSelected: boolean = false
  @Prop isDark: boolean = false
  onSelect: () => void = () => {}

  build() {
    Button({ type: ButtonType.Capsule }) {
      Row({ space: 6 }) {
        if (this.optionSelected) {
          Text('✓').fontSize('12fp').fontColor(this.isDark ? '#00D5FF' : '#054ACB')
        }
        Text(this.optionLabel)
        .fontSize('14fp')
        .fontWeight(this.optionSelected ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.optionSelected ? (this.isDark ? '#00D5FF' : '#054ACB') : AppTheme.color(this.isDark).textSecondary)
        .textAlign(TextAlign.Center)
      }.justifyContent(FlexAlign.Center).padding({ top: 8, bottom: 8 })
    }
    .width('100%')
    .constraintSize({ minHeight: 36 })
    .responseRegion({ x: 0, y: -6, width: '100%', height: 48 })
    .padding({ left: 4, right: 4 })
    .backgroundColor(this.optionSelected ? (this.isDark ? '#12335A' : '#E2ECFF') : Color.Transparent)
    .accessibilityText(this.optionLabel)
    .accessibilitySelected(this.optionSelected)
    .onClick(() => { this.onSelect() })
  }
}

@Component
export struct SettingsView {
  @Prop bottomInset: number = 0
  @Prop isDark: boolean = false
  @StorageLink('themeMode') themeMode: string = 'system'
  @StorageLink('imageFitMode') fitMode: string = 'contain'
  private repo = ImageRepository.getInstance()
  @State allConfigs: SourceConfig[] = []
  @State testingAll: boolean = false
  @State nsfwEnabled: boolean = false

  aboutToAppear(): void { this.refreshUI() }

  private palette(): SettingsLuminousColors { return new SettingsLuminousColors(this.isDark) }

  private refreshUI(): void {
    this.allConfigs = this.repo.getConfigs()
    this.nsfwEnabled = this.repo.isNsfwEnabled()
  }

  private enabledCount(): number {
    return this.allConfigs.filter((config: SourceConfig): boolean => config.isEnabled).length
  }

  private async testAll(): Promise<void> {
    if (this.testingAll || this.enabledCount() === 0) return
    this.testingAll = true
    try {
      const enabled = this.allConfigs.filter((config: SourceConfig): boolean => config.isEnabled)
      await Promise.all(enabled.map(async (config: SourceConfig): Promise<void> => {
        const pending = this.repo.testSource(config.type)
        this.refreshUI()
        await pending
        this.refreshUI()
      }))
    } finally {
      this.testingAll = false
      this.refreshUI()
    }
  }

  private statusLabel(config: SourceConfig): string {
    if (!config.isEnabled) return '已停用'
    if (config.status === ConnectionStatus.TESTING) return '正在测试连接…'
    if (config.status === ConnectionStatus.SUCCESS) return `连接正常 · ${config.latency} ms`
    if (config.status === ConnectionStatus.FAILED) return '连接失败 · 可重新测试'
    return '尚未测试连接'
  }

  private statusColor(config: SourceConfig): string {
    if (!config.isEnabled) return this.palette().muted
    if (config.status === ConnectionStatus.SUCCESS) return this.palette().positive
    if (config.status === ConnectionStatus.FAILED) return this.palette().error
    if (config.status === ConnectionStatus.TESTING) return this.palette().accent
    return this.palette().muted
  }

  @Builder
  appearanceSection() {
    Column({ space: 12 }) {
        Text('外观与浏览').fontSize('18fp').fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.color(this.isDark).textPrimary)
      Column({ space: 16 }) {
      Column({ space: 6 }) {
        Text('主题模式').fontSize('15fp').fontColor(AppTheme.color(this.isDark).textPrimary)
        Row({ space: 4 }) {
          SettingsLuminousChoice({ optionLabel: '跟随系统', optionSelected: this.themeMode === 'system',
            isDark: this.isDark, onSelect: () => { this.themeMode = 'system' } }).layoutWeight(1)
          SettingsLuminousChoice({ optionLabel: '浅色', optionSelected: this.themeMode === 'light',
            isDark: this.isDark, onSelect: () => { this.themeMode = 'light' } }).layoutWeight(1)
          SettingsLuminousChoice({ optionLabel: '深色', optionSelected: this.themeMode === 'dark',
            isDark: this.isDark, onSelect: () => { this.themeMode = 'dark' } }).layoutWeight(1)
        }
        .width('100%').padding({ left: 4, right: 4, top: 6, bottom: 6 }).borderRadius(24).backgroundColor(this.palette().base)
      }.width('100%').alignItems(HorizontalAlign.Start)

      Column({ space: 6 }) {
        Text('图片默认显示').fontSize('15fp').fontColor(AppTheme.color(this.isDark).textPrimary)
        Row({ space: 4 }) {
          SettingsLuminousChoice({ optionLabel: '完整显示', optionSelected: this.fitMode === 'contain',
            isDark: this.isDark, onSelect: () => { this.fitMode = 'contain' } }).layoutWeight(1)
          SettingsLuminousChoice({ optionLabel: '铺满屏幕', optionSelected: this.fitMode === 'cover',
            isDark: this.isDark, onSelect: () => { this.fitMode = 'cover' } }).layoutWeight(1)
        }
        .width('100%').padding({ left: 4, right: 4, top: 6, bottom: 6 }).borderRadius(24).backgroundColor(this.palette().base)
        Text(this.fitMode === 'contain' ? '保留完整画面，边缘可能留白' : '填满浏览区域，部分边缘可能被裁切')
          .fontSize('13fp').fontColor(this.palette().muted)
      }.width('100%').alignItems(HorizontalAlign.Start)
      }
    .width('100%').padding(20).alignItems(HorizontalAlign.Start)
    .backgroundColor(this.palette().surface).borderRadius(24)
    .border({ width: 1, color: this.palette().border })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  contentSection() {
    Column({ space: 12 }) {
      Text('内容偏好').fontSize('18fp').fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.color(this.isDark).textPrimary)
      Row({ space: 12 }) {
        Column({ space: 6 }) {
          Text('显示敏感内容').fontSize('15fp').fontColor(AppTheme.color(this.isDark).textPrimary)
          Text('允许图源返回 NSFW 插画')
            .fontSize('13fp').fontColor(this.palette().muted)
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.nsfwEnabled })
          .width(52).height(32)
          .responseRegion({ x: 0, y: -8, width: 52, height: 48 })
          .accessibilityText('显示敏感内容，允许图源返回 NSFW 插画')
          .selectedColor(this.isDark ? '#1176CE' : '#0846CC')
          .switchPointColor(AppTheme.onPrimary)
          .onChange((isOn: boolean) => {
            this.repo.setNsfwEnabled(isOn)
            this.refreshUI()
          })
      }.width('100%').constraintSize({ minHeight: 64 })
    .width('100%').padding(20).alignItems(VerticalAlign.Center)
    .backgroundColor(this.palette().surface).borderRadius(24)
    .border({ width: 1, color: this.palette().border })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        Column({ space: 6 }) {
          Text('设置').fontSize('30fp').fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.color(this.isDark).textPrimary)
          Text('让每一次浏览，更合心意').fontSize('14fp').fontColor(this.palette().muted)
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
      }
      .width('100%').padding({ left: 20, right: 20, top: 16, bottom: 20 })
      .linearGradient({ direction: GradientDirection.Bottom, colors: this.isDark ?
        [['#102039', 0], ['#080C14', 1]] : [['#E2ECFF', 0], ['#EEF2F9', 1]] })

      List({ space: 20 }) {
        ListItem() { this.appearanceSection() }
        ListItem() { this.contentSection() }
        ListItem() {
          Column({ space: 16 }) {
            Row({ space: 12 }) {
              Column({ space: 6 }) {
                Text('图源管理').fontSize('18fp').fontWeight(FontWeight.Medium)
                  .fontColor(AppTheme.color(this.isDark).textPrimary)
                Text(`已启用 ${this.enabledCount()} / ${this.allConfigs.length} 个图源`)
                  .fontSize('13fp').fontColor(this.palette().muted)
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              Button({ type: ButtonType.Capsule }) {
                Row({ space: 6 }) {
                  if (this.testingAll) {
                    LoadingProgress().width(16).height(16).color(this.palette().accent)
                  } else {
                    Image($r('app.media.icon_refresh')).width(16).height(16).fillColor(AppTheme.color(this.isDark).textSecondary)
                  }
                  Text(this.testingAll ? '测试中' : '全部测速').fontSize('14fp')
                    .fontWeight(FontWeight.Medium).fontColor(AppTheme.color(this.isDark).textSecondary)
                }.padding({ top: 12, bottom: 12 })
              }
              .constraintSize({ minHeight: 48 }).padding({ left: 14, right: 14 })
              .backgroundColor(this.palette().surface)
              .opacity(this.enabledCount() === 0 ? 0.5 : 1)
              .enabled(!this.testingAll && this.enabledCount() > 0)
              .accessibilityText(this.enabledCount() === 0 ? '全部测速，请先启用图源' : '测试全部已启用的图源')
              .onClick(() => { this.testAll() })
            }.width('100%')
            Text(this.enabledCount() === 0 ? '启用至少一个图源后，即可测试连接' : '仅测试已启用图源，耗时取决于网络状态')
              .fontSize('13fp').fontColor(this.palette().muted)
          }.width('100%').padding({ left: 4, right: 4, top: 8 }).alignItems(HorizontalAlign.Start)
        }

        ListItemGroup() {
          ForEach(this.allConfigs, (config: SourceConfig) => {
            ListItem() {
              Row({ space: 10 }) {
                Column().width(6).height(6).borderRadius(3).backgroundColor(this.statusColor(config))
                  .accessibilityLevel('no')
                Column({ space: 6 }) {
                  Text(config.name).fontSize('15fp').fontWeight(FontWeight.Medium)
                    .fontColor(AppTheme.color(this.isDark).textPrimary)
                  Text(this.statusLabel(config)).fontSize('13fp').fontColor(this.statusColor(config))
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Button({ type: ButtonType.Circle }) {
                  if (config.status === ConnectionStatus.TESTING) {
                    LoadingProgress().width(18).height(18).color(this.palette().accent)
                  } else {
                    Image($r('app.media.icon_refresh')).width(18).height(18).fillColor(this.palette().muted)
                  }
                }
                .width(48).height(48).backgroundColor(Color.Transparent)
                .enabled(!this.testingAll && config.status !== ConnectionStatus.TESTING)
                .accessibilityText(config.status === ConnectionStatus.TESTING ? `${config.name}测速中` : `测试${config.name}连接`)
                .onClick(async () => {
                  const pending = this.repo.testSource(config.type)
                  this.refreshUI()
                  await pending
                  this.refreshUI()
                })
                Toggle({ type: ToggleType.Switch, isOn: config.isEnabled })
                  .width(52).height(32)
                  .responseRegion({ x: 0, y: -8, width: 52, height: 48 })
                  .accessibilityText(`启用${config.name}`)
                  .selectedColor(this.isDark ? '#1176CE' : '#0846CC').switchPointColor(AppTheme.onPrimary)
                  .onChange((isOn: boolean) => {
                    this.repo.setSourceEnabled(config.type, isOn)
                    this.refreshUI()
                  })
              }
              .width('100%').constraintSize({ minHeight: 76 })
              .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            }
          }, (config: SourceConfig): string => `${config.type}_${config.status}_${config.latency}_${config.isEnabled}`)
        }
        .divider({ strokeWidth: 0.5, color: this.palette().border, startMargin: 32, endMargin: 16 })
        .backgroundColor(this.palette().surface).borderRadius(24)
        .border({ width: 1, color: this.palette().border })

        ListItem() { Column().height(12) }
      }
      .width('100%').layoutWeight(1).padding({ left: 20, right: 20 })
      .margin({ bottom: this.bottomInset })
      .scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(this.palette().background)
  }
}
