# ACG绘见 应用架构

本项目以单个 entry 模块实现逻辑分层，遵循[鸿蒙分层架构设计](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-layered-architecture-design/)的依赖方向；现阶段不额外拆分 HAR/HSP。页面仍采用 ArkUI V1 状态管理，参考[状态刷新控制](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-state-refresh/)。

## 职责与依赖

- `pages/` 和 `entryability/`：应用入口、导航和系统生命周期。
- `features/`：按浏览、设置组织 UI；页面保留布局、交互状态和提示。`gallery/ImageActions` 封装分享、打开和保存等系统交互。
- `model/`：图源标识、配置和图片数据结构，不依赖仓库或页面。
- `service/`：仓库拥有图源配置与内容过滤状态，通过 `IImageService` 调度图源；`providers/` 只接收请求参数，负责各图源的协议转换。
- `network/`、`datasource/`、`components/`、`theme/`：网络、列表数据源、通用控件和主题能力。

依赖方向为入口 → 功能 → 仓库与模型 → 图源适配及网络。图源适配器不反向引用仓库或界面。单例只负责应用内共享，仓库也支持注入服务映射以便测试。

## 状态约定

仓库返回图源配置快照，修改通过 `setSourceEnabled`、`setNsfwEnabled` 和 `testSource` 进行。加载请求显式传入图源 ID，避免异步请求受其他页面切换图源影响。内容过滤条件发生变化时递增版本；浏览页重新激活时清除旧缓存和详情，重新加载当前图源。

图源开关、测速状态和内容过滤条件目前只保存在进程内；主题和图片显示方式由应用的 PersistentStorage 维护。分页、列表滚动和图片详情状态由浏览功能管理，不跨进程持久化。

## 验证

`entry/src/test/Repository.test.ets` 使用可注入的假图源检查配置快照、请求路由、过滤版本及测速失败。修改后执行项目构建，并在具备测试运行环境时运行本地单元测试；图源切换、过滤变更、保存与分享还需在设备上验证。
