@Component
export struct LoadingView {

  build() {

    Column() {

      LoadingProgress()
        .width(40)
        .height(40)

      Text("加载中...")
        .fontSize(14)
        .margin({ top: 12 })

    }
    .width("100%")
    .height(120)
    .justifyContent(FlexAlign.Center)

  }

}