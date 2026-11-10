import { ImageItem } from '../model/ImageItem'
import { SourceConfig, ConnectionStatus, SourceType } from '../model/SourceConfig'
import { IImageService } from './IImageService'
import { PicsumService } from './providers/PicsumService'
import { KonachanService } from './providers/KonachanService'
import { YandereService } from './providers/YandereService'
import { NekosBestService } from './providers/NekosBestService'
import { WaifuPicsService } from './providers/WaifuPicsService'
import { DanbooruService } from './providers/DanbooruService'
import { GelbooruService } from './providers/GelbooruService'
import { PixivService } from './providers/PixivService'

export class ImageRepository {
  private static instance: ImageRepository | null = null

  // 1. 采用 Map 维护图源映射，解耦 switch-case 强耦合
  private servicesMap: Map<SourceType, IImageService> = new Map()
  // 2. 内存维护图源配置列表
  private configs: SourceConfig[] = []
  private filterRevision: number = 0

  // ===== 新增：全局 NSFW 状态控制 =====
  private nsfwEnabled: boolean = false

  constructor(services?: Map<SourceType, IImageService>) {
    if (services) {
      this.servicesMap = services
    } else {
      this.registerServices()
    }
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
    if (this.nsfwEnabled !== enabled) {
      this.nsfwEnabled = enabled
      this.filterRevision++
    }
  }

  public getFilterRevision(): number {
    return this.filterRevision
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

  private copyConfig(config: SourceConfig): SourceConfig {
    return { type: config.type, name: config.name, isEnabled: config.isEnabled,
      status: config.status, latency: config.latency }
  }

  public getConfigs(): SourceConfig[] {
    return this.configs.map((config: SourceConfig): SourceConfig => this.copyConfig(config))
  }

  public getEnabledConfigs(): SourceConfig[] {
    return this.getConfigs().filter((config: SourceConfig): boolean => config.isEnabled)
  }

  public setSourceEnabled(type: SourceType, enabled: boolean): void {
    const config = this.configs.find((item: SourceConfig): boolean => item.type === type)
    if (config) config.isEnabled = enabled
  }

  public async load(type: SourceType, page: number): Promise<ImageItem[]> {
    const service = this.servicesMap.get(type)
    if (!service) throw new Error('Unknown image source')
    return await service.load(page, this.nsfwEnabled)
  }

  public async testSource(type: SourceType): Promise<void> {
    const config = this.configs.find((item: SourceConfig): boolean => item.type === type)
    const service = this.servicesMap.get(type)
    if (!config || !service || config.status === ConnectionStatus.TESTING) return
    config.status = ConnectionStatus.TESTING
    try {
      const latency = await service.testConnection(this.nsfwEnabled)
      config.status = latency >= 0 ? ConnectionStatus.SUCCESS : ConnectionStatus.FAILED
      config.latency = latency >= 0 ? latency : 0
    } catch (err) {
      config.status = ConnectionStatus.FAILED
      config.latency = 0
    }
  }
}
