import { ImageItem } from '../model/ImageItem'
import { SourceConfig, ConnectionStatus } from '../model/SourceConfig'
import { IImageService } from './IImageService'
import { PicsumService } from './providers/PicsumService'
import { KonachanService } from './providers/KonachanService'
import { YandereService } from './providers/YandereService'
import { NekosBestService } from './providers/NekosBestService'
import { WaifuPicsService } from './providers/WaifuPicsService'
import { DanbooruService } from './providers/DanbooruService'
import { GelbooruService } from './providers/GelbooruService'
import { PixivService } from './providers/PixivService'

export enum SourceType {
  PICSUM,
  KONACHAN,
  YANDERE,
  NEKOS_BEST,
  WAIFU_PICS,
  DANBOORU,
  GELBOORU,
  PIXIV
}

export class ImageRepository {
  private static instance: ImageRepository | null = null

  // 1. 采用 Map 维护图源映射，解耦 switch-case 强耦合
  private servicesMap: Map<SourceType, IImageService> = new Map()
  // 2. 内存维护图源配置列表
  private configs: SourceConfig[] = []
  private currentType: SourceType = SourceType.PICSUM

  // ===== 新增：全局 NSFW 状态控制 =====
  private nsfwEnabled: boolean = false

  private constructor() {
    this.registerServices()
    this.initDefaultConfigs()
  }

  // 单例模式：确保主页和设置页共享同一套启用配置
  public static getInstance(): ImageRepository {
    if (ImageRepository.instance === null) {
      ImageRepository.instance = new ImageRepository()
    }
    return ImageRepository.instance
  }

  // ===== 新增：NSFW 的获取与设置方法 =====
  public isNsfwEnabled(): boolean {
    return this.nsfwEnabled
  }

  public setNsfwEnabled(enabled: boolean) {
    this.nsfwEnabled = enabled
  }

  // 注册服务
  private registerServices() {
    this.servicesMap.set(SourceType.PICSUM, new PicsumService())
    this.servicesMap.set(SourceType.KONACHAN, new KonachanService())
    this.servicesMap.set(SourceType.YANDERE, new YandereService())
    this.servicesMap.set(SourceType.NEKOS_BEST, new NekosBestService())
    this.servicesMap.set(SourceType.WAIFU_PICS, new WaifuPicsService())
    this.servicesMap.set(SourceType.DANBOORU, new DanbooruService())
    this.servicesMap.set(SourceType.GELBOORU, new GelbooruService())
    this.servicesMap.set(SourceType.PIXIV, new PixivService())
  }

  // 初始化默认配置
  private initDefaultConfigs() {
    const defaultTypes = [
      SourceType.PICSUM, SourceType.KONACHAN, SourceType.YANDERE,
      SourceType.NEKOS_BEST, SourceType.WAIFU_PICS, SourceType.DANBOORU,
      SourceType.GELBOORU, SourceType.PIXIV
    ]
    const names = ["Picsum", "Konachan", "Yandere", "NekosBest", "WaifuPics", "Danbooru", "Gelbooru", "Pixiv"]

    for (let i = 0; i < defaultTypes.length; i++) {
      const configItem: SourceConfig = {
        type: defaultTypes[i],
        name: names[i],
        isEnabled: true, // 默认全部启用
        status: ConnectionStatus.UNTESTED,
        latency: 0
      }
      this.configs.push(configItem)
    }
  }

  // 获取所有图源配置（设置页使用）
  public getConfigs(): SourceConfig[] {
    return this.configs
  }

  // 获取当前已启用的图源配置（主页渲染 Tab 导航栏使用）
  public getEnabledConfigs(): SourceConfig[] {
    return this.configs.filter(item => item.isEnabled)
  }

  // 动态切换图源
  public setSource(type: SourceType) {
    this.currentType = type
  }

  // 统一加载接口
  public async load(page: number): Promise<ImageItem[]> {
    const service = this.servicesMap.get(this.currentType)
    if (service) {
      return await service.load(page)
    }
    const emptyList: ImageItem[] = []
    return emptyList
  }

  /**
   * 测试指定图源的连通性
   */
  public async testSource(type: SourceType): Promise<void> {
    const config = this.configs.find(c => c.type === type)
    const service = this.servicesMap.get(type)

    if (!config || !service) return

    config.status = ConnectionStatus.TESTING
    const latency = await service.testConnection()

    if (latency >= 0) {
      config.status = ConnectionStatus.SUCCESS
      config.latency = latency
    } else {
      config.status = ConnectionStatus.FAILED
      config.latency = 0
    }
  }
}