import { AppTheme } from '../../theme/AppTheme'
import { ImageItem } from '../../model/ImageItem'

@Component
export struct ACGCard {
  @Prop item: ImageItem
  @Prop isDark: boolean = false
  onOpen: (item: ImageItem) => void = () => {}
  @State isLoaded: boolean = false
  @State hasError: boolean = false
  @State retryKey: number = 0

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column() {
        if (this.hasError) {
          Text('点击重试').fontSize(12).fontColor(AppTheme.color(this.isDark).imageErrorText)
        }
      }
      .width('100%')
      .aspectRatio(this.item.width > 0 && this.item.height > 0 ? this.item.width / this.item.height : 1)
      .backgroundColor(AppTheme.color(this.isDark).imagePlaceholder)
      Image(this.item.previewUrl || this.item.imageUrl)
        .id(`${this.item.id}_${this.retryKey}`)
        .width('100%')
        .aspectRatio(this.item.width > 0 && this.item.height > 0 ? this.item.width / this.item.height : 1)
        .objectFit(ImageFit.Cover)
        .opacity(this.isLoaded ? 1 : 0)
        .onComplete(() => { this.isLoaded = true; this.hasError = false })
        .onError(() => { this.hasError = true; this.isLoaded = false })
      if (this.isLoaded) {
        Column() {
          Text(this.item.title || this.item.source)
            .fontSize(11).fontWeight(FontWeight.Medium).fontColor(Color.White)
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%').alignItems(HorizontalAlign.Start).padding({ left: 10, right: 10, top: 18, bottom: 10 })
        .linearGradient({ angle: 180, colors: [['#00000000', 0], ['#C9000000', 1]] })
      }
    }
    .width('100%')
    .borderRadius(16).clip(true)
    .border({ width: 1, color: AppTheme.color(this.isDark).glassBorder })
    .accessibilityText(this.hasError ? '图片加载失败，点击重试' : `查看图片，${this.item.title || this.item.source}`)
    .onClick(() => {
      if (this.hasError) {
        this.hasError = false
        this.retryKey++
      } else {
        this.onOpen(this.item)
      }
    })
  }
}
