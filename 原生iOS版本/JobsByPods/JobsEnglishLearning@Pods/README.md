# JobsEnglishLearning

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#jobs-toc-heading-1)
- [一、职责与架构](#jobs-toc-heading-2)
- [二、入口、数据与验证](#jobs-toc-heading-3)
- [三、常见问题](#jobs-toc-heading-4)

</details>
<!-- jobs-toc:end -->

---

## <span id="jobs-toc-heading-1" data-jobs-toc="v2">🔥 <font id=前言>前言</font></span><!-- jobs-toc:heading-end -->

把 JobsEnglishWordBook 的学习交互用 [**Swift**](https://www.swift.org/) 重写为原生 iOS 模块；复用原软件离线词库，不包含 Python / Qt 运行时。

## <span id="jobs-toc-heading-2" data-jobs-toc="v2">一、职责与架构 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

| 层 | 内容 |
| --- | --- |
| `Core/Repository` | Repository actor：12 档目录、字母 / 中英搜索、40 词分页 |
| `Core/Model` | 词条、释义、词组、例句及分页结果 |
| `Resource` | catalog.sqlite3、覆盖报告、第三方声明 |

列表、详情和 Cell 归 App 的 `JobsLanguageLearning/Business/JobsEnglishLearning`；本 Pod 只编译数据能力。页面使用 Jobs UI 工厂、链式 DSL 与 [**SnapKit**](https://github.com/SnapKit/SnapKit)。公共 UI、点读和设置归 JobsLanguageCore。查询采用参数绑定，用户输入中的 LIKE 通配符按字面量处理，旧搜索结果不能覆盖新请求。

## <span id="jobs-toc-heading-3" data-jobs-toc="v2">二、入口、数据与验证 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

公开数据入口为 `JobsEnglishRepository()`，通过 `levels()`、`page(level:letter:query:offset:)` 查询；实际签名见 Repository 源码。原库包含 13,430 词和 25,832 条例句；844 词缺例句。初中、高中、CET4、CET6、专八、雅思 1～7 的完整目录由 SQLite 读取。雅思属于自定义学习分级，详见 `Resource/coverage.json`。

真实词库、分页及词条例句页面验证见根目录 [验证记录](../../验证记录.md)。原数据库复制保持原样，校验清单见根目录 `resource-provenance.json`。公开发行前须解决源词库再分发授权，保留 `THIRD_PARTY_NOTICES.txt`。

## <span id="jobs-toc-heading-4" data-jobs-toc="v2">三、常见问题 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

**为何所有释义显示相同例句？** 原库没有逐义例句映射，详情页明确标注词条级关联。

**可以离线点读吗？** 词库离线；系统对应语言的声音需要设备上已安装。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
