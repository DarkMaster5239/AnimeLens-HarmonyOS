export enum SourceType {
  PICSUM, KONACHAN, YANDERE, NEKOS_BEST, WAIFU_PICS, DANBOORU, GELBOORU, PIXIV
}

// 定义连接测试状态
export enum ConnectionStatus {
  UNTESTED, // 未测试
  TESTING,  // 测试中
  SUCCESS,  // 成功
  FAILED    // 失败
}

export interface SourceConfig {
  type: SourceType
  name: string
  isEnabled: boolean          // 是否启用
  status: ConnectionStatus    // 连接状态
  latency: number             // 延迟（毫秒）
}