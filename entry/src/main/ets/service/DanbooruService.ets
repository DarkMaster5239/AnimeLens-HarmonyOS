import { HttpClient } from '../network/HttpClient'
import { ImageItem } from '../model/ImageItem'
// 导入统一的服务接口
import { IImageService } from './IImageService'
// 1. 核心修复：导入单例仓储管理器
import { ImageRepository } from './ImageRepository'

interface DanbooruPost {
  id: number
  tag_string: string
  file_url?: string
  large_file_url?: string
  preview_file_url?: string
  image_width: number
  image_height: number
}

// 显式实现 IImageService 接口
export class DanbooruService implements IImageService {

  async load(page: number): Promise<ImageItem[]> {
    // 2. 动态检测全局 NSFW 状态：未开启则只看 rating:general，开启则不设评级过滤限制（展示全部内容）
    const ratingTag = ImageRepository.getInstance().isNsfwEnabled() ? "" : "rating:general"
    const url = `https://danbooru.donmai.us/posts.json?page=${page}&limit=20&tags=${ratingTag}`

    const result = await HttpClient.get<DanbooruPost[]>(url)

    const validPosts = result.filter(item => item.large_file_url || item.file_url)

    return validPosts.map((item): ImageItem => {
      const displayUrl = item.large_file_url || item.file_url || ""
      const previewUrl = item.preview_file_url || displayUrl

      const imageItem: ImageItem = {
        id: "danbooru_" + item.id,
        title: item.tag_string,
        previewUrl: previewUrl,
        imageUrl: displayUrl,
        width: item.image_width || 300,
        height: item.image_height || 400,
        tags: item.tag_string.split(" "),
        source: "Danbooru",
        favorite: false
      }
      return imageItem
    })
  }

  /**
   * 接口实现：实现 Danbooru 平台的轻量化连通性测试
   */
  async testConnection(): Promise<number> {
    const startTime = Date.now()
    try {
      // 测速也跟随全局状态保持一致的过滤条件
      const ratingTag = ImageRepository.getInstance().isNsfwEnabled() ? "" : "rating:general"
      const url = `https://danbooru.donmai.us/posts.json?page=1&limit=1&tags=${ratingTag}`
      const testResult = await HttpClient.get<DanbooruPost[]>(url)

      if (testResult && testResult.length >= 0) {
        return Date.now() - startTime // 返回网络往返延迟（ms）
      }
      return -1
    } catch (e) {
      return -1 // 网络异常、超时或被拦截时返回 -1
    }
  }
}