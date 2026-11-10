import { AppTheme } from '../../theme/AppTheme'

@Component
export struct GlassIconButton {
  @Prop icon: Resource
  @Prop label: string = ''
  @Prop isDark: boolean = false
  @Prop busy: boolean = false
  onAction: () => void = () => {}

  build() {
    Button() {
      if (this.busy) {
        LoadingProgress().width(20).height(20).color(AppTheme.color(this.isDark).textPrimary)
      } else {
        Image(this.icon).width(20).height(20).fillColor(AppTheme.color(this.isDark).textPrimary)
      }
    }
    .width(44).height(44)
    .backgroundColor(AppTheme.color(this.isDark).glassControl)
    .enabled(!this.busy)
    .accessibilityText(this.label)
    .onClick(() => { this.onAction() })
  }
}
