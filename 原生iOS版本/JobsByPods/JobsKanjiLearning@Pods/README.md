# JobsKanjiLearning

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

把 JobsKanji 的汉字、读法、关联词与例句学习交互用 [**Swift**](https://www.swift.org/) 重写。使用 Jobs UI 工厂、链式 DSL、[**SnapKit**](https://github.com/SnapKit/SnapKit)，翻译桥接采用 [**SwiftUI**](https://developer.apple.com/xcode/swiftui/) 和 iOS 18 的 [Apple Translation](https://developer.apple.com/documentation/translation/translating-text-within-your-app)。

## 一、职责与架构 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 层 | 内容 |
| --- | --- |
| `Core/Repository` | Repository actor：全部 / 常用 / 人名汉字，汉字、假名、中文检索及关联词分页 |
| `Core/Model` | KANJIDIC2、JMdict 数据模型，写法 / 读法 / 词义限制 |
| `Resource` | catalog.sqlite、chinese_seed.sqlite、guides.json、预制中文与归属声明 |

主业务控制器、振假名视图及本机翻译桥接位于 App 的 `JobsLanguageLearning/Business/JobsKanjiLearning`，不进入本 Pod 的编译范围。数据资源通过 `JobsKanjiRepository` 所属 bundle 定位，不依赖 App 中控制器类型。

音读、训读、名乘采用三列读音按钮；例句 token 点读和整句点读分别处理。按 JMdict 的 `restr`、`stagk`、`stagr` 选择真实适用词义。未缓存中文通过可见按钮请求生成，不以英文释义兜底；失败可重试。缓存保存在 App 沙盒 Application Support 的 `JobsKanjiChinese.json`。

## 二、入口、数据与验证 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

公开数据入口为 `JobsKanjiRepository()` 和公开模型，提供汉字分页、汉字详情、学习指南及关联词查询；词义限制通过 `JobsKanjiWord` 的查询方法处理。词库含 13,108 字、218,844 词和 26,269 条不同例句。缺读音、缺释义或缺关联词按原库提示，不造数据。中文字义和自动振假名可能有歧义，学习界面保留校对提示。

原始数据库、指南和归属声明复制后校验见根目录 `resource-provenance.json`。预制中文从原中文种子及已定义的精确翻译词表导出，词性中文由原软件转换器生成；不包含 Argos 模型或 Python 运行时。EDRDG / Tatoeba 的归属与许可见 `Resource/NOTICE.txt`。

数据、读法限制及页面验证见根目录 [验证记录](../../验证记录.md)。首次下载翻译语言包及本机译文生成必须在真机验证，模拟器保留内置中文字义和学习指南。

## 三、常见问题 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

**为何中文显示待生成？** 此条目没有预制中文；在真机请求下载英中语言包后生成，译文可离线复用。

**红字能保证每句都正确吗？** 继承原软件自动分析结果，可能有歧义；点按正文 token 读取它的完整假名。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
