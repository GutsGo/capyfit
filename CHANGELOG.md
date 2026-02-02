# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- 为饮食库页面添加无限滚动加载功能。
- 引入运动数据库及通用工具类和常量配置。

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
