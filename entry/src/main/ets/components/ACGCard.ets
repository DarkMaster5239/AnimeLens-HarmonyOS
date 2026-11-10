import { ImageItem } from '../model/ImageItem'

@Component
export struct ACGCard {
  @Prop item: ImageItem

  // 1. 用于控制全屏预览模态框
  @State isPreview: boolean = false
  // 2. 新增：标记图片是否已经加载解码完成
  @State isLoaded: boolean = false

  // 全屏预览的布局构造器
  @Builder
  PreviewBuilder() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width("100%")
        .height("100%")
        .backgroundColor('#111111')
        .onClick(() => {
          this.isPreview = false
        })

      Image(this.item.imageUrl)
        .width("100%")
        .height("100%")
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.isPreview = false
        })
    }
    .width("100%")
    .height("100%")
  }

  build() {
    // 将整个卡片包装在 Stack 中，实现骨架占位底图与真实图片的完美叠加
    Stack() {

      // ===== 占位骨架屏 (图片未加载出来时显示) =====
      if (!this.isLoaded) {
        Column() {
          LoadingProgress()
            .width(28)
            .height(28)
            .color('#CCCCCC') // 低饱和度的灰色加载圈
        }
        .width("100%")
        .aspectRatio(this.item.width / (this.item.height || 1))
        .backgroundColor('#EBECEF') // 质感高级的淡灰色骨架背景
        .justifyContent(FlexAlign.Center)
        .borderRadius(12)
      }

      // ===== 真实网络图片 =====
      Image(this.item.previewUrl || this.item.imageUrl)
        .width("100%")
        .aspectRatio(this.item.width / (this.item.height || 1))
        .objectFit(ImageFit.Cover)
        .borderRadius(12)
        // 3. 优雅渐变：加载完成后透明度由 0 渐变至 1
        .opacity(this.isLoaded ? 1 : 0)
        .animation({
          duration: 250, // 250ms 的丝滑淡入
          curve: Curve.EaseInOut
        })
        // 4. 监听加载完成事件
        .onComplete(() => {
          this.isLoaded = true
        })
        // 5. 监听加载失败事件（容错处理：即使失败也淡入，显示内置默认占位或保持骨架色）
        .onError(() => {
          this.isLoaded = true
        })

    }
    .width("100%")
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.isPreview = true
    })
    .bindContentCover(this.isPreview, this.PreviewBuilder(), {
      modalTransition: ModalTransition.ALPHA,
      onDisappear: () => {
        this.isPreview = false
      }
    })
    .stateStyles({
      normal: {
        .scale({ x: 1.0, y: 1.0 })
      },
      pressed: {
        .scale({ x: 0.97, y: 0.97 })
      }
    })
    .animation({
      duration: 150,
      curve: Curve.EaseOut
    })
  }
}
