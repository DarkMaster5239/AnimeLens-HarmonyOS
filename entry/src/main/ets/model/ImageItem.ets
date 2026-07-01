/**
 * 图片数据模型
 */
export interface ImageItem {
  /** 图片ID */
  id: string

  /** 标题 */
  title: string

  /** 缩略图 */
  previewUrl: string

  /** 原图 */
  imageUrl: string

  /** 图片宽 */
  width: number

  /** 图片高 */
  height: number

  /** 标签 */
  tags: string[]

  /** 来源 */
  source: string

  /** 是否收藏 */
  favorite: boolean
}