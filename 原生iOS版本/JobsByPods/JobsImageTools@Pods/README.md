# `JobsImageTools`

[toc]

> 中文架构入口：[架构脉络与关键设计](#jobs-architecture)。

<a id="jobs-architecture"></a>

## 一、架构脉络与关键设计

本节用于用中文快速理解组件，并为按框架重建提供入口；关注职责、运行关系和关键边界，不要求逐行复刻。

### 1.1、设计目的与职责划分

分开处理简单图片加载、Kingfisher/SDWebImage 缓存清理，以及对现有 UIKit 视图树的图片刷新。核心不是重新实现图片框架，而是记录与协调实际加载来源。

### 1.2、运行脉络

记录控件图片来源及加载器 → 发起图片加载 → 按需清理缓存 → 遍历已记录来源的控件重新请求

### 1.3、关键设计与边界

- 同时存在两种图片框架时，应按每个控件记录的 jobs_imageLoaderKind 选择刷新方式，不能通过编译分支只处理其中一种。
- 强制重新下载依赖控件记录的远程地址，无法从任意 UIImage 反推出原始 URL。
- 缓存删除与屏幕上已显示图片更新是两件事；UIImageView、按钮前景图和背景图需要分别处理。
- UI 树遍历与控件更新遵循主线程要求，下载与磁盘缓存的完成时机应通过回调衔接。

### 1.4、阅读与重建顺序

先看 JobsSimpleImageLoader，再看 JobsImageCacheCleaner，最后读 ByUIKit 中如何找控件和恢复加载。

源码定位（路径以本 README 所在目录为基准；只带走 README 时，可把文件名作为职责定位线索）：

- [JobsImageCacheCleaner.swift](<./JobsImageCacheCleaner.swift>)
- [JobsSimpleImageLoader.swift](<./JobsSimpleImageLoader.swift>)
- [JobsImageCacheCleanerByUIKit.swift](<./JobsImageCacheCleanerByUIKit.swift>)

依赖与编译入口：[JobsImageTools.podspec](<./JobsImageTools.podspec>)。其中显式依赖声明包括 `Kingfisher`、`SDWebImage`、`JobsSwiftBlock`、`JobsSwiftBaseDefines`、`JobsSwiftDSL`。源码范围、资源及可选 subspec 以这里的声明为准；辅助脚本动态补充的依赖不在上述摘录中展开。
