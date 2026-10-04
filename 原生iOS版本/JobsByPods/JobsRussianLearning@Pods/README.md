# JobsRussianLearning

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

从 Jobs Swift Demo 提取的俄语拼读课程数据模块。使用 [**Swift**](https://www.swift.org/)、Jobs UI 工厂、链式 DSL 和 [**SnapKit**](https://github.com/SnapKit/SnapKit)，不依赖 Demo 根列表。

## 一、职责与架构 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `JobsRussianLesson`：10 个元音、21 个辅音、210 个组合、少见拼写提示，以及学习用拉丁转写 / IPA 提示。

主业务控制器、辅音选择页、卡片和矩阵位于 App 的 `JobsLanguageLearning/Business/JobsRussianLearning`，不进入本 Pod 的编译范围。公共导航、主题、声音与设置归 JobsLanguageCore。

## 二、入口与验证 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

公开数据入口为 `JobsRussianLesson.consonants`、`vowels`、`isUncommon(_:_:)` 及 `pronunciationHint` 系列方法。转写保留常见学习写法，例如 ж → zh、щ → shch；IPA 是宽式音值提示，软辅音会随元音组合标记。课程数据属于 Swift 代码，不需要外部 Python 或字库文件；独立 Pod 配置见 `JobsRussianLearning.podspec`。App 负责分组 / 全表切换、随机练习、点读以及可横向滚动的矩阵。

拼读组合数量、少见规则、页面切换及设置同步验证见根目录 [验证记录](../../验证记录.md)。原 Swift Demo 保持原样。

## 三、常见问题 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

**为何有的辅音读字母名？** 系统 TTS 对单个字母及孤立音节的处理不等同于专业音素录音。

**ъ、ь 在哪里？** 它们是符号，不计入 21 个辅音；矩阵旁的学习说明保留这一边界。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
