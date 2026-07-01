import { ImageRepository, SourceType } from '../service/ImageRepository'
import { SourceConfig, ConnectionStatus } from '../model/SourceConfig'

@Component
export struct SettingsView {
  private repo = ImageRepository.getInstance()

  // 使用 @State 监视图源配置数组
  @State allConfigs: SourceConfig[] = []

  aboutToAppear() {
    this.refreshUI()
  }

  // 1. 核心修复：使用 [...展开运算符] 浅拷贝数组，强制通知 ArkUI 更新列表渲染树
  private refreshUI() {
    this.allConfigs = [...this.repo.getConfigs()]
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text("图源设置与测速")
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
      }
      .width("100%")
      .padding({ left: 16, top: 16, right: 16, bottom: 12 })

      // ===== 全局配置分区（NSFW 开关） =====
      Column() {
        Row() {
          Column() {
            Text("开启非安全内容 (NSFW)")
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FF3B30') // 使用瞩目的警示红色
            Text("包含敏感、限制级动漫插画过滤控制")
              .fontSize(12)
              .fontColor('#888888')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Toggle({ type: ToggleType.Switch, isOn: this.repo.isNsfwEnabled() })
            .selectedColor('#FF3B30') // 开启时显示警示红
            .onChange((isOn: boolean) => {
              // 动态调整 Repository 的全局配置
              this.repo.setNsfwEnabled(isOn)
              this.refreshUI() // 同步通知设置页刷新
            })
        }
        .width("100%")
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
      }
      .padding({ left: 12, right: 12 })
      .margin({ bottom: 16 })

      // ===== 修复补全：原图源配置卡片列表 =====
      List() {
        ForEach(this.allConfigs, (config: SourceConfig) => {
          ListItem() {
            Row() {
              Column() {
                Text(config.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#111111')

                // 连通性测试状态展示
                if (config.status === ConnectionStatus.TESTING) {
                  Row() {
                    LoadingProgress()
                      .width(14)
                      .height(14)
                      .color('#007DFF')
                      .margin({ right: 6 })

                    Text("正在测速...")
                      .fontSize(12)
                      .fontColor('#007DFF')
                  }
                  .margin({ top: 4 })
                  .alignItems(VerticalAlign.Center)

                } else if (config.status === ConnectionStatus.SUCCESS) {
                  Text(`正常 / 延迟: ${config.latency}ms`)
                    .fontSize(12)
                    .fontColor('#34C759')
                    .margin({ top: 4 })

                } else if (config.status === ConnectionStatus.FAILED) {
                  Text("连接失败 (Blocked)")
                    .fontSize(12)
                    .fontColor('#FF3B30')
                    .margin({ top: 4 })

                } else {
                  Text("未测试")
                    .fontSize(12)
                    .fontColor('#888888')
                    .margin({ top: 4 })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              // 独立测速按钮：联动置灰，防重复点击
              Button(config.status === ConnectionStatus.TESTING ? "测速中" : "测试")
                .fontSize(12)
                .height(28)
                .enabled(config.status !== ConnectionStatus.TESTING)
                .backgroundColor(config.status === ConnectionStatus.TESTING ? '#E5E5EA' : '#EEEFf2')
                .fontColor(config.status === ConnectionStatus.TESTING ? '#8E8E93' : '#007DFF')
                .margin({ right: 12 })
                .onClick(async () => {
                  // 同步更改状态，并立即引发重绘
                  config.status = ConnectionStatus.TESTING
                  this.refreshUI()

                  // 异步测速
                  await this.repo.testSource(config.type)

                  // 测速完成，再次引发重绘
                  this.refreshUI()
                })

              // 单个图源启用/禁用 Toggle 开关
              Toggle({ type: ToggleType.Switch, isOn: config.isEnabled })
                .onChange((isOn: boolean) => {
                  config.isEnabled = isOn
                  this.refreshUI() // 状态改变后同步刷新并浅拷贝数组
                })
            }
            .width("100%")
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({
              radius: 4,
              color: 'rgba(0,0,0,0.02)'
            })
            .margin({ bottom: 8 })
          }
        },
          // 动态组合键：一旦 status, latency 或 isEnabled 变化，Key 变化，强制重新绘制渲染该单行
          (config: SourceConfig) => `${config.name}_${config.status}_${config.latency}_${config.isEnabled}`)
      }
      .width("100%")
      .layoutWeight(1)
      .padding({ left: 12, right: 12 })
    }
    .width("100%")
    .height("100%")
    .backgroundColor('#F1F3F5')
  }
}