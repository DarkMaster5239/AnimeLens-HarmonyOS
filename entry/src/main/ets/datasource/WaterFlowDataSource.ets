import { ImageItem } from '../model/ImageItem'

export class WaterFlowDataSource implements IDataSource {

  private listeners: DataChangeListener[] = []

  private dataList: ImageItem[] = []

  /**
   * 总数量
   */
  totalCount(): number {
    return this.dataList.length
  }

  /**
   * 获取数据
   */
  getData(index: number): ImageItem {
    return this.dataList[index]
  }

  /**
   * 注册监听
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener)
    }
  }

  /**
   * 注销监听
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener)
    if (index >= 0) {
      this.listeners.splice(index, 1)
    }
  }

  /**
   * 清空数据
   */
  clear(): void {
    this.dataList = []
    this.notifyReload()
  }

  /**
   * 替换全部数据（刷新）
   */
  replace(list: ImageItem[]): void {
    this.dataList = [...list]
    this.notifyReload()
  }

  /**
   * 追加数据（分页）
   */
  append(list: ImageItem[]): void {

    if (list.length === 0) {
      return
    }

    const start = this.dataList.length

    this.dataList.push(...list)

    for (let index = start; index < this.dataList.length; index++) {
      this.notifyAdd(index)
    }
  }

  /**
   * 获取全部数据
   */
  getAll(): ImageItem[] {
    return this.dataList
  }

  /**
   * 获取指定Item
   */
  item(index: number): ImageItem {
    return this.dataList[index]
  }

  /**
   * 是否为空
   */
  isEmpty(): boolean {
    return this.dataList.length === 0
  }

  /**
   * 当前数量
   */
  size(): number {
    return this.dataList.length
  }

  /**
   * 通知刷新
   */
  private notifyReload() {
    this.listeners.forEach(item => {
      item.onDataReloaded()
    })
  }

  /**
   * 通知新增
   */
  private notifyAdd(index: number) {
    this.listeners.forEach(item => {
      item.onDataAdd(index)
    })
  }

}
