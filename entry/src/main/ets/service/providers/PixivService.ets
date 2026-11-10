import { HttpClient } from '../../network/HttpClient'
import { ImageItem } from '../../model/ImageItem'
import { IImageService } from '../IImageService'
import { ImageRepository } from '../ImageRepository'

interface PixivPost {
  pid: number
  title: string
  author: string
  width: number
  height: number
  tags: string[]
  urls: PixivUrls
}

interface PixivUrls {
  regular: string
}

interface PixivResponse {
  data: PixivPost[]
}

export class PixivService implements IImageService {

  async load(page: number): Promise<ImageItem[]> {
    // 动态检测全局 NSFW 状态：未开启则 r18=0，开启则 r18=1 (混入)
    const nsfwFlag = ImageRepository.getInstance().isNsfwEnabled() ? 1 : 0
    const url = `https://api.lolicon.app/setu/v2?r18=${nsfwFlag}&num=20`

    const response = await HttpClient.get<PixivResponse>(url)

    if (!response || !response.data) {
      const emptyList: ImageItem[] = []
      return emptyList
    }

    return response.data.map((item): ImageItem => {
      // 核心修复：直接使用接口返回的 regular 链接（已经是 pixiv.re 免封锁反代），不进行二次 weserv 中转，速度极快
      const displayUrl = item.urls.regular

      const imageItem: ImageItem = {
        id: "pixiv_" + item.pid,
        title: `${item.title} (by ${item.author})`,
        previewUrl: displayUrl,
        imageUrl: displayUrl,
        width: item.width || 300,
        height: item.height || 400,
        tags: item.tags,
        source: "Pixiv",
        favorite: false
      }
      return imageItem
    })
  }

  async testConnection(): Promise<number> {
    const startTime = Date.now()
    try {
      const url = `https://api.lolicon.app/setu/v2?r18=0&num=1`
      const testResult = await HttpClient.get<PixivResponse>(url)

      if (testResult && testResult.data && testResult.data.length >= 0) {
        return Date.now() - startTime
      }
      return -1
    } catch (e) {
      return -1
    }
  }
}