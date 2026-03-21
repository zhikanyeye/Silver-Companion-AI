# 银龄智伴子女端数据流升级设计文档

## 目标

将子女端从直接读取静态常量文件的展示页，升级为具备真实数据流结构的看板页面。首轮不接线上接口，而是先引入本地 service、统一数据模型、加载态、失败态与刷新行为，为后续接入真实接口打好架构基础。

## 范围

- 新增统一的子女端 dashboard 数据模型
- 新增本地 `ChildDashboardService`
- `ChildHomePage` 改为异步加载页面
- 增加加载态、失败态、刷新态
- 保持现有看板 UI 和响应式布局风格基本不变

## 总体方案

首轮采用“本地 service + async load + refresh”的轻量数据流方案：

- 页面不再直接 import 并消费 `mock_family_data.dart` 中的常量列表
- 改为通过 `ChildDashboardService.loadDashboard()` 获取 `Future<ChildDashboardData>`
- service 目前仍返回本地 mock 数据，但调用方式、错误处理、刷新链路都按真实数据流设计

这样可以在不依赖后端联调的前提下，把子女端从“静态页面”推进为“可加载页面”，后续替换成 API 数据时改动面更小。

## 数据模型

新增统一 dashboard 数据对象，例如：

- `ChildDashboardData`
  - 总览指标
  - 状态卡列表
  - 提醒列表
- `ChildOverviewMetricData`
- `ChildStatusCardData`
- `ChildAlertItem`

这样子女端页面只关心一个顶层对象，不直接拼接多个零散常量。

## 数据来源

- 保留 `mock_family_data.dart` 作为本地数据源，但调整为返回结构化 dashboard 数据
- 新增 `ChildDashboardService`
  - `Future<ChildDashboardData> loadDashboard()`
  - 首轮可加轻微延时，模拟真实加载
- 后续如果接接口，只替换 service 内部实现即可

## 页面行为

`ChildHomePage` 从 `StatelessWidget` 升级为具备状态管理的页面组件：

- `loading`：显示看板骨架或简化加载提示
- `loaded`：展示总览、照护指标、提醒时间线
- `error`：展示失败提示和重试按钮
- `refreshing`：支持下拉刷新，不中断已有页面结构

页面刷新优先使用 `RefreshIndicator`，保证手机端交互自然，也便于后续接真实接口。

## 测试策略

- 先修改现有子女端测试，让其表达“异步加载后才出现页面内容”的预期
- 新增 service 测试，验证本地 service 返回结构化数据
- 新增失败态 / 重试态测试（可通过注入 fake service 实现）
- 保留现有响应式布局测试，确保引入数据流后不会破坏窄屏/分栏结构

## 依赖与边界

- 本轮不引入新的状态管理框架
- 不接真实网络请求
- 不修改老人端页面
- 不改 Cloudflare Pages Functions 或部署链路

## 不在范围内

- 子女端接入真实远程 API
- 提醒项编辑、标记完成、推送通知
- 子女端跨页跳转和详情页体系
- 聊天页或社区页联动数据
