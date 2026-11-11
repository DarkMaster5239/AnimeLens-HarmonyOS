import { AppTheme } from '../../theme/AppTheme'

@Component
export struct GlassIconButton {
  @Prop icon: Resource
  @Prop label: string = ''
  @Prop isDark: boolean = false
  @Prop busy: boolean = false
  @Prop iconSize: number = 20
  @Prop btnSize: number = 44
  @State isPressed: boolean = false
  onAction: () => void = () => {}

  build() {
    Button({ type: ButtonType.Circle }) {
      if (this.busy) {
        LoadingProgress().width(this.iconSize).height(this.iconSize).color(AppTheme.color(this.isDark).textPrimary)
      } else {
        Image(this.icon).width(this.iconSize).height(this.iconSize).fillColor(AppTheme.color(this.isDark).textPrimary)
      }
    }
    .width(this.btnSize).height(this.btnSize)
    .borderRadius(this.btnSize / 2)
    .backgroundColor(AppTheme.color(this.isDark).glassControl)
    .border({ width: 0.8, color: AppTheme.color(this.isDark).glassBorder })
    .scale({ x: this.isPressed ? 0.96 : 1, y: this.isPressed ? 0.96 : 1 })
    .animation({ duration: 120, curve: Curve.EaseOut })
    .enabled(!this.busy)
    .accessibilityText(this.label)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false
      }
    })
    .onClick(() => { this.onAction() })
  }
}
