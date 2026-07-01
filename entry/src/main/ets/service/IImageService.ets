import { ImageItem } from '../model/ImageItem'

export interface IImageService {
  /**
   * 统一的数据加载接口
   */
  load(page: number): Promise<ImageItem[]>

  /**
   * 统一的连接测试接口。
   * 返回测试耗时（毫秒），若连接失败则返回 -1
   */
  testConnection(): Promise<number>
}