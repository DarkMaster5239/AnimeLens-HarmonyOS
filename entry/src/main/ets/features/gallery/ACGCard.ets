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
    Stack({ alignContent: Alignment.Center }) {
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
    }
    .width('100%')
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
