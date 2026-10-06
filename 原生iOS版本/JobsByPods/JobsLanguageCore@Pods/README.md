# JobsLanguageCore

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

独立语言学习 App 的公共基座，使用 [**Swift**](https://www.swift.org/)、Jobs UI 工厂与链式 DSL。业务模块依赖本 Pod；公共层不反向依赖任何语种。

## 一、能力与结构 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 目录 / 类型 | 职责 |
| --- | --- |
| `Core/JobsLanguageBaseVC` | GK 导航、系统侧滑返回、设置入口、当前页播放与生命周期停止 |
| `Core/JobsLanguageAppearance` | 白天、黑夜、跟随系统；保存选择并驱动 JobsThemeCenter |
| `Core/JobsLanguageSettingsVC` | 按语种设置声音、语速、重复次数、音量 |
| `Core/JobsLanguageSpeechPlayer` | 系统语音队列、精准取消、旧回调过滤 |
| `Core/JobsLanguageSyllableCourse` | 拉丁字母组合、阿拉伯短元音音节和韩文 Unicode 音节块生成；提供俄语拉丁转写及各课程 IPA / 罗马字提示 |
| `Core/JobsSQLiteDatabase` | 只读 SQLite、参数绑定、JSON 解码 |
| `Core/Factory` | 当前 App 需要的类型工厂与返回 Self 的配置扩展 |
| `Resource` | Jobs 主题配置资源；通过独立 bundle 定位 |

UI 由 [**SnapKit**](https://github.com/SnapKit/SnapKit) 布局。主题依赖动态颜色和 Jobs 主题绑定；声音按语言保存，缺声提示不跨语言兜底。SQLite 对象由业务 Repository actor 持有，不在主线程反复查询大词库。

公共按钮统一由 `JobsLanguageLearningStyle` 创建，`UIButton.byLearningBackgroundColor` 将语义背景绑定到 JobsThemeCenter，禁用文字使用次级语义色。`paint` 在选中与普通状态间更新背景绑定，保留标题和点击行为。富文本通过 `UIView.byLearningObserveAppearance` 同时观察 UIKit 外观与主题中心，重新生成已经解析的文字颜色；尚未挂到窗口的视图也能更新。

公共基类在 `viewDidAppear` 清除系统返回手势的默认代理限制，按导航栈深度启用边缘侧滑；根页面禁用，详情和设置页继承同一行为。

导航条在布局回调中通过 Jobs DSL 更新框架的 Frame 宽度，适配 iPad 旋转及窗口变化；页面业务约束仍由 SnapKit 管理，不改导航框架源码。

## 二、使用与验证 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

Podfile.deps 的 `byJobs` 统一挂载；具体根级依赖与资源范围见 `JobsLanguageCore.podspec`，没有重复的 Core subspec。继承 `JobsLanguageBaseVC` 后覆盖标题和 `speechLanguage`，通过 `speak(_:language:)` 点读。默认右侧为设置入口；首页覆盖 `learningNavigationButtons`，提供主题下拉列表入口，选择后通过 `JobsLanguageAppearance.choose` 保存三态主题。学习说明入口与帮助传参已移除。

SQLite、播放与主题对象独立于原 Demo 主工程。工程级构建、真实词库测试、页面测试及设备限制见根目录 [README](../../README.md) 和 [验证记录](../../验证记录.md)。

## 三、常见问题 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

**为什么译文不在公共层？** 日语的词义限制、中文缓存和系统翻译属于日语业务；公共层只提供点读、UI 与数据访问。

**如何增加拼读语种？** 主业务 UI 放入 App，语种 Pod 或首页保存课程数据；复用 `JobsLanguageSyllableCourse` 生成拼读项与文字注音，再在首页新增入口。语音仍按页面指定语言查找，不跨语言回退。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
