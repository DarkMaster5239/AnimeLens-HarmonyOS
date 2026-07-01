@Component
export struct SearchBar {

  @Link keyword: string

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
    .backgroundColor("#222")
    .borderRadius(24)
    .padding(12)

  }

}