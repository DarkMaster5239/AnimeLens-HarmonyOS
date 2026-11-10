import { HttpClient } from '../../network/HttpClient'
import { ImageItem } from '../../model/ImageItem'
// 导入统一接口
import { IImageService } from '../IImageService'

interface WaifuPicsResponse {
  files: string[]
}

interface WaifuRequestBody {
  exclude: string[]
}

// 供连通性测试使用的极简单图返回结构
interface WaifuSingleResponse {
  url: string
}

// 显式实现 IImageService 接口
export class WaifuPicsService implements IImageService {

  // 接入 page 参量以严格对齐契约接口规范
  async load(page: number, nsfwEnabled: boolean): Promise<ImageItem[]> {
    // 官方标准 API 地址确实为 api.waifu.pics
    const url = `https://api.waifu.pics/many/sfw/waifu`

    const requestBody: WaifuRequestBody = {
      exclude: []
    }

    const response = await HttpClient.post<WaifuPicsResponse>(url, requestBody)

    return response.files.map((fileUrl, index): ImageItem => {
      // 显式声明 ImageItem 类型变量，防止无类型字面量警告
      const imageItem: ImageItem = {
        id: `waifu_${Date.now()}_${index}`,
        title: "SFW Waifu",
        previewUrl: fileUrl,
        imageUrl: fileUrl,
        width: 300,
        height: 450,
        tags: ["waifu"] as string[],
        source: "Waifu.pics",
        favorite: false
      }
      return imageItem
    })
  }

  /**
   * 接口实现：实现 WaifuPics 平台的轻量化连通性测试
   * 采用 GET 方式请求单图端点，避开复杂的 POST 负载，测速效率极高
   */
  async testConnection(nsfwEnabled: boolean): Promise<number> {
    const startTime = Date.now()
    try {
      const url = `https://api.waifu.pics/sfw/waifu`
      const testResult = await HttpClient.get<WaifuSingleResponse>(url)

      if (testResult && testResult.url) {
        return Date.now() - startTime // 返回延迟耗时
      }
      return -1
    } catch (e) {
      return -1 // 连接超时、被拦截或域名无法解析时返回 -1
    }
  }
}