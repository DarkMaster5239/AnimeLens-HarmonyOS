import { HttpClient } from '../../network/HttpClient'
import { ImageItem } from '../../model/ImageItem'
import { IImageService } from '../IImageService'

interface NekoItem {
  url: string
  artist_name: string
  source_url: string
}

interface NekosBestResponse {
  results: NekoItem[]
}

// 显式实现 IImageService 接口
export class NekosBestService implements IImageService {

  // 接纳 page 参量以严格对齐接口规范
  async load(page: number, nsfwEnabled: boolean): Promise<ImageItem[]> {
    // 2. 动态决定请求类目：未开启走 neko，开启走 lewd
    const category = nsfwEnabled ? "lewd" : "neko"
    const url = `https://nekos.best/api/v2/${category}?amount=20`

    const response = await HttpClient.get<NekosBestResponse>(url)

    return response.results.map((item, index): ImageItem => {
      // 显式定义符合 ArkTS 规范的对象
      const imageItem: ImageItem = {
        id: `neko_${Date.now()}_${index}`,
        title: item.artist_name ? `Artist: ${item.artist_name}` : "Nekos Best Illustration",
        previewUrl: item.url,
        imageUrl: item.url,
        width: 300,
        height: 400,
        tags: ["neko", "illustration"] as string[],
        source: "Nekos.best",
        favorite: false
      }
      return imageItem
    })
  }

  /**
   * 接口实现：实现 NekosBest 平台的轻量化连通性测试
   */
  async testConnection(nsfwEnabled: boolean): Promise<number> {
    const startTime = Date.now()
    try {
      // 测速也需要同步跟随类目，防止类目不可达导致测试不准
      const category = nsfwEnabled ? "lewd" : "neko"
      const url = `https://nekos.best/api/v2/${category}?amount=1`
      const testResult = await HttpClient.get<NekosBestResponse>(url)

      if (testResult && testResult.results && testResult.results.length >= 0) {
        return Date.now() - startTime
      }
      return -1
    } catch (e) {
      return -1
    }
  }
}