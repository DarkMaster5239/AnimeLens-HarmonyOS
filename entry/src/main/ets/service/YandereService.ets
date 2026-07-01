import { HttpClient } from '../network/HttpClient'
import { ImageItem } from '../model/ImageItem'
import { IImageService } from './IImageService'

interface YanderePost {
  id: number
  tags: string
  preview_url: string
  sample_url: string
  file_url: string
  width: number
  height: number
}

export class YandereService implements IImageService {

  // 日本 VPN 节点下，无需反代，只需补全 "//" 相对协议头即可直连
  private formatUrl(url: string): string {
    if (!url) {
      return ""
    }
    if (url.startsWith("//")) {
      return "https:" + url
    }
    return url // 直连原始高速域名 files.yande.re
  }

  async load(page: number): Promise<ImageItem[]> {
    const url = `https://yande.re/post.json?page=${page}&limit=20&tags=rating:s`
    const result = await HttpClient.get<YanderePost[]>(url)

    if (!result || result.length === 0) {
      const emptyList: ImageItem[] = []
      return emptyList
    }

    return result.map((item): ImageItem => {
      const rawImageUrl = item.sample_url || item.file_url
      const displayUrl = this.formatUrl(rawImageUrl)
      const displayPreviewUrl = this.formatUrl(item.preview_url)

      const imageItem: ImageItem = {
        id: "yandere_" + item.id,
        title: item.tags,
        previewUrl: displayPreviewUrl,
        imageUrl: displayUrl,
        width: item.width || 300,
        height: item.height || 400,
        tags: item.tags.split(" "),
        source: "Yande.re",
        favorite: false
      }
      return imageItem
    })
  }

  async testConnection(): Promise<number> {
    const startTime = Date.now()
    try {
      const url = `https://yande.re/post.json?page=1&limit=1&tags=rating:s`
      const testResult = await HttpClient.get<YanderePost[]>(url)

      if (testResult && testResult.length >= 0) {
        return Date.now() - startTime
      }
      return -1
    } catch (e) {
      return -1
    }
  }
}