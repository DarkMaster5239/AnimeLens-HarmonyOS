import { AppTheme } from '../../theme/AppTheme'

@Component
export struct SearchBar {
  @Link keyword: string
  @Prop isDark: boolean = false
  onClear: () => void = () => {}

  build() {
    Row({ space: 8 }) {
      TextInput({
        text: this.keyword,
        placeholder: "搜索标签、作者或作品..."
      })
        .placeholderColor(AppTheme.color(this.isDark).textMuted)
        .fontColor(AppTheme.color(this.isDark).textPrimary)
        .fontSize(14)
        .backgroundColor(Color.Transparent)
        .onChange((value: string) => {
          this.keyword = value
        })
        .layoutWeight(1)

      if (this.keyword.length > 0) {
        Button({ type: ButtonType.Normal }) {
          Text('✕')
            .fontSize(12)
            .fontColor(AppTheme.color(this.isDark).textMuted)
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor(AppTheme.color(this.isDark).glassControl)
        .accessibilityText('清除搜索')
        .onClick(() => {
          this.keyword = ''
          this.onClear()
        })
      }
    }
    .height(44)
    .backgroundColor(AppTheme.color(this.isDark).glassControl)
    .backgroundBlurStyle(BlurStyle.Thin)
    .border({ width: 0.8, color: AppTheme.color(this.isDark).glassBorder })
    .borderRadius(22)
    .padding({ left: 14, right: 10 })
  }
}
