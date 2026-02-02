# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2026-02-03

### Added
- 新增等级系统（Level System），在个人中心动态展示用户等级与勋章。
- 新增“关于我们”页面，提供版本信息、等级系统说明及站点链接。
- 引入 Webview 功能，支持在应用内直接查看《用户协议》与《隐私政策》。
- 上线官方 Web 落地页及合规法律文档。

### Changed
- 完善引导页（Onboarding）合规流程，新增隐私政策勾选及确认机制。
- 统一品牌名称为“猛练卡皮”，更新多处文案与图标路径。
- 重构个人中心（Profile）页面布局，优化交互体验。
- 优化“关于”页面检查更新的弹窗视觉效果。

### Fixed
- 修复了部分组件在暗色模式下的颜色对比度问题。
- 统一了手绘组件的使用规范，使用 `HandDrawnContainer` 替代部分不一致的 `HandDrawnCard` 实现。

## [1.2.0] - 2026-02-02

### Added
- 为饮食库页面添加无限滚动加载功能。
- 引入运动数据库及通用工具类和常量配置。
- 新增计划详情页面及运动计时功能。
- 支持数据备份与恢复功能。
- 运动列表支持“返回顶部”及筛选功能。
- 首页问候语动态显示用户昵称。

### Changed
- 优化膳食库页面体验。
- 重构 UI 层架构，统一使用绝对路径导入。
- 更新应用图标及相关图片资源。
- 调整 Snackbar 显示位置，避免遮挡 App Bar。
- 优化引导页（Onboarding）流程，修复 Android 端跳步问题。
- 调优 App Bar 标题字体大小与粗细。

### Fixed
- 修复手绘风格容器（HandDrawnContainer）在小尺寸下的锯齿问题。
- 修复提醒页面时间选择器在部分机型下无法显示中文的问题。
- 修复侧边栏版本信息显示逻辑。

## [1.1.1] - 2026-02-01

### Changed
- 在发布工作流中重命名 APK 文件以包含应用名和版本号。
- 重命名项目、包名和应用标识符为 `capyfit`。
- 配置 Android 应用发布签名并更新应用 ID。

### Added
- 引导页功能。
- 饮食库重构，引入食物详情页和食物数据库服务。

### Removed
- 移除默认测试文件。

## [1.1.0] - 2026-01-29

### Added
- 实现基于 GitHub Actions 的反馈提交功能（从应用创建 Issue）。
- 引入 Hive 用于本地数据持久化。
- 新增引导页、数据备份、帮助、反馈、提醒和目标设置页面。

### Fixed
- 增加必要的网络权限 ☁️。

## [1.0.0+1] - 2026-01-29

### Changed
- 调整 APK 构建命令以支持按 ABI 拆分。

## [1.0.0] - 2026-01-29

### Added
- 初始版本发布。
- 优化 GitHub Actions 构建流程。
