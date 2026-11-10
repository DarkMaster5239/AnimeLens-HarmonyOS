import { HttpClient } from '../../network/HttpClient'
import { ImageItem } from '../../model/ImageItem'
// 导入统一的服务接口
import { IImageService } from '../IImageService'

interface GelbooruPost {
  id: number
  tags: string
  file_url: string
  sample_url: string
  preview_url: string
  width: number
  height: number
}

interface GelbooruResponse {
  post?: GelbooruPost[]
}

// 显式实现 IImageService 接口
export class GelbooruService implements IImageService {

  async load(page: number, nsfwEnabled: boolean): Promise<ImageItem[]> {
    const pid = page - 1
    const url = `https://gelbooru.com/index.php?page=dapi&s=post&q=index&json=1&limit=20&pid=${pid}&tags=rating:general`

    const response = await HttpClient.get<GelbooruResponse>(url)

    if (!response || !response.post) {
      const emptyList: ImageItem[] = []
      return emptyList
    }

    return response.post.map((item): ImageItem => {
      const displayUrl = item.sample_url || item.file_url

      const imageItem: ImageItem = {
        id: "gelbooru_" + item.id,
        title: item.tags,
        previewUrl: item.preview_url,
        imageUrl: displayUrl,
        width: item.width || 300,
        height: item.height || 400,
        tags: item.tags.split(" "),
        source: "Gelbooru",
        favorite: false
      }
      return imageItem
    })
  }

  /**
   * 接口实现：实现 Gelbooru 平台的轻量化连通性测试
   */
  async testConnection(nsfwEnabled: boolean): Promise<number> {
    const startTime = Date.now()
    try {
      // 测速请求（只请求一条数据，pid=0 代表第一页）
      const url = `https://gelbooru.com/index.php?page=dapi&s=post&q=index&json=1&limit=1&pid=0&tags=rating:general`
      const testResult = await HttpClient.get<GelbooruResponse>(url)

      // 只要服务器正常响应并返回格式化后的 post 数组，即算通断成功
      if (testResult && testResult.post) {
        return Date.now() - startTime // 返回网络延迟（ms）
      }
      return -1
    } catch (e) {
      return -1 // 连接超时或被拦截时返回 -1
    }
  }
}