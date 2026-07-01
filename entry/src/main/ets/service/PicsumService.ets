import { HttpClient } from '../network/HttpClient'
import { Constants } from '../common/Constants'
import { ImageItem } from '../model/ImageItem'
// 导入统一服务接口
import { IImageService } from './IImageService'

interface PicsumImage {
  id: string
  author: string
  width: number
  height: number
  download_url: string
}

// 显式实现 IImageService 接口
export class PicsumService implements IImageService {

  async load(page: number): Promise<ImageItem[]> {
    const limit = Constants.PAGE_SIZE || 20
    const url = `https://picsum.photos/v2/list?page=${page}&limit=${limit}`

    const result = await HttpClient.get<PicsumImage[]>(url)

    let list: ImageItem[] = []

    result.forEach(item => {
      // ===== 动态计算适合瀑布流显示的分辨率 =====

      // 1. 设定列表展示的图片目标宽度（例如：主图 500px，缩略图 200px）
      const targetWidth = 500
      const previewTargetWidth = 200

      // 2. 保持原图的宽高比例计算对应的高度
      const targetHeight = Math.round((targetWidth / item.width) * item.height)
      const previewTargetHeight = Math.round((previewTargetWidth / item.width) * item.height)

      // 3. 构建指定分辨率的 Picsum URL 地址
      // 格式：https://picsum.photos/id/{id}/{width}/{height}
      const optimizedImageUrl = `https://picsum.photos/id/${item.id}/${targetWidth}/${targetHeight}`
      const optimizedPreviewUrl = `https://picsum.photos/id/${item.id}/${previewTargetWidth}/${previewTargetHeight}`

      // 4. 显式声明符合 ArkTS 规范的对象，防止编译器报匿名对象警告
      const imageItem: ImageItem = {
        id: item.id,
        title: item.author,
        previewUrl: optimizedPreviewUrl,
        imageUrl: optimizedImageUrl,
        width: targetWidth,
        height: targetHeight,
        tags: [] as string[],
        source: "Picsum",
        favorite: false
      }

      list.push(imageItem)
    })

    return list
  }

  /**
   * 接口实现：实现 Picsum 平台的轻量化连通性测试
   */
  async testConnection(): Promise<number> {
    const startTime = Date.now()
    try {
      // 极简测试：仅加载第 1 页的 1 条数据来测算网络往返延迟
      const url = `https://picsum.photos/v2/list?page=1&limit=1`
      const testResult = await HttpClient.get<PicsumImage[]>(url)

      if (testResult && testResult.length >= 0) {
        return Date.now() - startTime // 返回网络延迟
      }
      return -1
    } catch (e) {
      return -1 // 超时、DNS 异常或连接失败时返回 -1
    }
  }
}