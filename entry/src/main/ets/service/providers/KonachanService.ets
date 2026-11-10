import { HttpClient } from '../../network/HttpClient'
import { Constants } from '../../common/Constants'
import { ImageItem } from '../../model/ImageItem'
import { IImageService } from '../IImageService'

interface KonachanPost {
  id: number
  tags: string
  preview_url: string
  sample_url: string
  file_url: string
  width: number
  height: number
}

// 显式实现 IImageService 接口
export class KonachanService implements IImageService {

  private formatUrl(url: string): string {
    if (!url) return ""
    if (url.startsWith("//")) return "https:" + url
    return url
  }

  async load(page: number, nsfwEnabled: boolean): Promise<ImageItem[]> {
    const limit = Constants.PAGE_SIZE || 20
    const url = `https://konachan.net/post.json?page=${page}&limit=${limit}&tags=rating:s`
    const result = await HttpClient.get<KonachanPost[]>(url)

    return result.map((item): ImageItem => {
      const displayUrl = this.formatUrl(item.sample_url || item.file_url)
      const displayPreviewUrl = this.formatUrl(item.preview_url)

      const imageItem: ImageItem = {
        id: "konachan_" + String(item.id),
        title: item.tags,
        previewUrl: displayPreviewUrl,
        imageUrl: displayUrl,
        width: item.width || 300,
        height: item.height || 400,
        tags: item.tags.split(" "),
        source: "Konachan",
        favorite: false
      }
      return imageItem
    })
  }

  // 实现通断测试：请求 1 条数据，记录往返时间
  async testConnection(nsfwEnabled: boolean): Promise<number> {
    const startTime = Date.now()
    try {
      const url = `https://konachan.net/post.json?page=1&limit=1&tags=rating:s`
      const testResult = await HttpClient.get<KonachanPost[]>(url)
      if (testResult && testResult.length >= 0) {
        return Date.now() - startTime // 返回网络往返耗时
      }
      return -1
    } catch (e) {
      return -1 // 连接失败
    }
  }
}