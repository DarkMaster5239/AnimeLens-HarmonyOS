import { AnimeLensNavigation } from './Index'

@Preview
@Component
struct GlassPreview {
  build() {
    Column() {
      AnimeLensNavigation({ previewGlass: true })
    }
    .width('100%')
    .height('100%')
  }
}
