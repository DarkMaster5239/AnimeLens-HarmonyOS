import { AppTheme } from '../../theme/AppTheme'
@Component
export struct SearchBar {

  @Link keyword: string
  @Prop isDark: boolean = false

  build() {

    Row() {

      TextInput({
        text: this.keyword,
        placeholder: "搜索标签..."
      })
        .onChange(value => {
          this.keyword = value
        })
        .layoutWeight(1)

    }
    .height(48)
    .backgroundColor(AppTheme.color(this.isDark).glassControl)
    .backgroundBlurStyle(BlurStyle.Thin)
    .border({ width: 1, color: AppTheme.color(this.isDark).glassBorder })
    .borderRadius(24)
    .padding(12)

  }

}