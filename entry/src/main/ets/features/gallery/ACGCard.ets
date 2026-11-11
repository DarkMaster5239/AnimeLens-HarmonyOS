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
  @State isPressed: boolean = false

  private getAspectRatio(): number {
    if (this.item.width > 0 && this.item.height > 0) {
      return this.item.width / this.item.height
    }
    return 0.75
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      // 1. Placeholder & Error State
      Column() {
        if (this.hasError) {
          Column({ space: 4 }) {
            Image($r('app.media.icon_refresh'))
              .width(20).height(20)
              .fillColor(AppTheme.color(this.isDark).imageErrorText)
            Text('点击重试')
              .fontSize(11)
              .fontColor(AppTheme.color(this.isDark).imageErrorText)
          }
        }
      }
      .width('100%')
      .aspectRatio(this.getAspectRatio())
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(AppTheme.color(this.isDark).imagePlaceholder)

      // 2. Main Image
      Image(this.item.previewUrl || this.item.imageUrl)
        .id(`${this.item.id}_${this.retryKey}`)
        .width('100%')
        .aspectRatio(this.getAspectRatio())
        .objectFit(ImageFit.Cover)
        .opacity(this.isLoaded ? 1 : 0)
        .animation({ duration: 250, curve: Curve.EaseOut })
        .onComplete(() => { this.isLoaded = true; this.hasError = false })
        .onError(() => { this.hasError = true; this.isLoaded = false })

      // 3. Top Badges (Source & High-Res)
      if (this.isLoaded) {
        Row() {
          Text(this.item.source ? this.item.source.toUpperCase() : 'ACG')
            .fontSize(9)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .padding({ left: 6, right: 6, top: 2.5, bottom: 2.5 })
            .backgroundColor('rgba(11, 15, 25, 0.65)')
            .borderRadius(6)
            .border({ width: 0.5, color: 'rgba(255, 255, 255, 0.2)' })


        }
        .width('100%')
        .position({ x: 0, y: 0 })
        .padding({ left: 8, right: 8, top: 8 })
      }

      // 4. Bottom Information with Soft Multi-Stop Gradient
      if (this.isLoaded) {
        Column({ space: 2 }) {
          Text(this.item.title || this.item.source)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (this.item.width > 0 && this.item.height > 0) {
            Text(`${this.item.width} × ${this.item.height}`)
              .fontSize(10)
              .fontColor('rgba(240, 246, 255, 0.7)')
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 8, right: 8, top: 24, bottom: 8 })
        .linearGradient({
          angle: 180,
          colors: [
            ['#00000000', 0],
            ['rgba(11, 15, 25, 0.35)', 0.45],
            ['rgba(11, 15, 25, 0.80)', 1]
          ]
        })
      }
    }
    .width('100%')
    .borderRadius(10)
    .clip(true)
    .shadow({
      radius: 6,
      color: AppTheme.cardShadow(this.isDark),
      offsetY: 3
    })
    .border({ width: 0.8, color: AppTheme.color(this.isDark).glassBorder })
    .scale({ x: this.isPressed ? 0.97 : 1, y: this.isPressed ? 0.97 : 1 })
    .animation({ duration: 150, curve: Curve.EaseOut })
    .accessibilityText(this.hasError ? '图片加载失败，点击重试' : `查看图片，${this.item.title || this.item.source}`)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false
      }
    })
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
