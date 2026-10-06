# <span id="前言">JobsLanguageLearningFlutter</span>

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## <span id="前言">🔥 前言</span>

Jobs 多语种学习应用的 [**Flutter**](https://flutter.dev/) 版本，以 [**Dart**](https://dart.dev/) 实现界面与业务。词库独立复制自 JobsLanguageLearning，运行时不依赖 Swift 或 Python 来源目录。

## 一、功能 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 模块 | 能力 |
| --- | --- |
| 首页 | 英语分级词典置顶；俄、法、西、朝鲜、德、日语及阿拉伯语学习入口，国家语种行显示国旗；阿拉伯联盟旗帜使用本地打包资源，原始 SVG 与来源说明一并保留；右上角“主题 ▾”展开下拉列表，勾选当前模式；选择白天 / 黑夜 / 跟随系统后生效并保存，点外部关闭 |
| 俄语 | 10 元音、21 辅音、210 组合；拉丁转写与 IPA；分组 / 全表和顺序点读 |
| 阿拉伯语 | 28 个辅音音值、3 个短元音符号；简化拉丁注音与 IPA；分组 / 全表点读 |
| 法语 | 6 个元音字母、常见辅音组合；宽式 IPA、`q` 的 `que / qui` 和拼写例外提示；分组 / 全表点读 |
| 西班牙语 | 5 个元音、22 个辅音字母及 `ch / ll`；宽式 IPA、`c / g / h / q` 规则和地区读音提示；分组 / 全表点读 |
| 朝鲜语 | 19 个声母、21 个元音；韩国修订罗马字与 IPA；音节块、27 种收音或无收音；分组 / 全表点读 |
| 德语 | 8 个基础元音、外来词元音 `y`、辅音与常见拼写组合；宽式 IPA、分组 / 全表点读；独立 `de-DE` 系统语音 |
| 英语 | 原来源的全部级别；字母与中英文搜索；分页；音标、词义、短语及词条级例句点读 |
| 日语 | 13,108 汉字、218,844 词条、26,269 不同例句；全部 / 常用 / 人名用检索；音读、训读、名乘；读法 / 写法 / 义项限制；红色振假名；原句作者链接 |
| 日语基础发音 | 5 元音、14 辅音行、65 有效组合及鼻音；平假名 / 片假名 / Hepburn 罗马字 / IPA；点击播放及全表顺序播放 |
| 设置 | 白天 / 黑夜 / 跟随系统；每种语言独立保存声音、语速、音量和重复次数 |
| 播放生命周期 | 新点读取消旧队列；切换页面、退出或切入后台停止；缺声音显示安装提示 |
| 中文 | 内置字义、学习指南和缓存；缺译可在 macOS / iOS / Android 按需生成并保存 |

## 二、运行与构建 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

使用 Flutter 3.47.6 / Dart 3.13.5 创建。项目根目录执行：

```sh
flutter pub get
flutter run -d macos
```

构建 macOS：

```sh
flutter build macos --release
```

输出 `./build/macos/Build/Products/Release/JobsLanguageLearningFlutter.app`。如根目录存在 `JobsLanguageLearningFlutter.app` 相对链接，可直接双击启动已验证的本机构建产物。

其他平台：

```sh
flutter run -d <设备ID>
flutter build ios --release --no-codesign
flutter build apk --release
flutter build windows --release
```

1、iOS 需要 macOS、[**Xcode**](https://developer.apple.com/xcode/) 与有效开发签名；最低 iOS 15.5。首次设备端翻译需下载模型。

2、Android 需要 SDK、命令行工具及已接受的许可证。ML Kit 模型只在 Wi-Fi 下载；系统 TTS 可能需额外安装俄语、法语、西班牙语、朝鲜语、德语、英语或日语声音。

3、macOS 应用可查询词库与播放系统声音；按需中文生成需要 macOS 15+，使用 Apple Translation，首次可能提示下载语言包。

4、Windows 必须在 Windows 本机构建，使用系统 SQLite `winsqlite3.dll` 与系统 TTS。按需中文生成暂未接入，保留内置中文与缺译提示。不承诺 macOS 交叉构建 EXE。

5、此工程提供 Android、iOS、macOS、Windows 宿主；未提供 Web / Linux 运行入口。

## 三、结构 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```text
./
├── lib/
│   ├── main.dart                 # 应用、首页、生命周期与路由
│   ├── core/                     # 设置、语音、SQLite、发音课程、设备翻译
│   ├── features/                 # 多语拼读页面、词典详情与设置
│   └── widgets/                  # 页面基座、分页、点读与红色振假名
├── assets/
│   ├── english/                  # 完整原始英语词库、覆盖与来源说明
│   └── japanese/                 # 完整日语词库、中文种子、指南与许可
├── macos/Runner/Translation/     # Apple Translation 通道与可取消的翻译窗口
├── android/ ios/ macos/ windows/ # 平台宿主
├── test/                         # 课程、读法限制、设置和播放测试
├── integration_test/             # 真实词库与页面流程
├── resource-provenance.json      # 来源、文件大小和 SHA-256
└── 验证记录.md                   # 已执行检查与平台边界
```

首次查询将只读词库复制至系统 Application Support 的 `catalog-v1`，使用绑定参数查询，不改打包资源。升级资源时应同步提升词库目录版本，避免沿用旧缓存。主题 / 语音设置和已生成中文保存到本机偏好中。

## 四、语料与版权 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 日语 KANJIDIC2 / JMdict 版权归 EDRDG，派生数据遵守 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)；详情保留 Tatoeba 原句链接。完整原始归属见 `./assets/japanese/NOTICE.txt`。
- 英语来源与使用限制见 `./assets/english/THIRD_PARTY_NOTICES.txt` 和 `coverage.json`，不能因制作 Flutter 客户端扩大原数据再分发许可。
- SQLite、中文种子、指南等 10 份资源与来源文件 SHA-256 一致，记录于 `resource-provenance.json`。
- 来源 NOTICE 包含 Python、Qt、Argos 的历史说明；Flutter 应用未携带 Python / Qt / Argos 运行时或模型。
- 业务未新增第三方图片或下载图标，保留 Flutter 宿主提供的系统导航控件。字体由平台负责日语及俄语回退。

## 五、验证方式 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```sh
flutter analyze
flutter test
flutter test integration_test/app_test.dart -d macos
```

测试覆盖课程缺位和特殊音、义项限制、主题与语音持久化、快速点读取消、俄语页面、完整英日 SQLite 查询及英日详情。插件模拟测试只验证调用与控制流程，不代表真实扬声器试听。新增语言仍需在目标设备检查对应系统声音；实际验证结果见 `./验证记录.md`。

注音是宽式入门提示，不代替完整发音规则或人工录音。阿拉伯语表使用 hamza 与三个短元音符号，不覆盖长元音、词形变化和地区口音；法语不覆盖鼻化、重音及全部位置规则；西班牙语表按西班牙本土音值显示 /θ/，拉美 seseo 地区相应读 /s/；韩语收音标注不模拟词中连音和音变；德语长短元音及辅音拼写依上下文变化。参考资料：[阿拉伯语罗马转写与 IPA 对照（沙迦大学）](https://romanization.sharjah.ac.ae/firstpageView/)、[国际音标表（IPA 协会）](https://www.internationalphoneticassociation.org/content/ipa-chart)、[法国教育部法语音素表](https://www.education.gouv.fr/media/199500/download)、[西班牙皇家学院正字法文档](https://www.rae.es/diccionario-estudiante/docs/ortografia.pdf)、[RAE seseo / ceceo 说明](https://www.rae.es/buen-uso-español/el-seseo-y-el-ceceo)、[韩国国立国语院修订罗马字](https://www.korean.go.kr/front_eng/roman/roman_01.do)、[慕尼黑大学德语元音音质研究](https://www.phonetik.uni-muenchen.de/forschung/publikationen/DioubinaPfitzinger_ICSLP02.pdf) 与[IPA 协会音标表](https://www.internationalphoneticassociation.org/IPAcharts/IPA_chart_trans/pdfs/IPA_Kiel_2020_full_deu.pdf)。

## 六、FAQ <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1、点击后没有声音？ <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

先查看页面底部错误，再到系统语音设置安装对应语言。零音量、静音输出设备或未安装声音都会影响点读。系统 TTS 不等同于专业音素录音，俄语单辅音可能读成字母名称；日语辅音表头明确使用代表音节。

### 2、为什么日语有“中文译文待补充”？ <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

原库缺项和机器译文未经完整校对。支持的平台可点击“生成 / 重试中文译文”，首次可能下载模型；成功后本机缓存，拒绝把仍含英文的结果当成中文释义。Windows 暂时保留缺译提示。

### 3、红色振假名是否一定准确？ <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

自动分析可能有歧义。词库保留整词读法、义项及例句关联限制，不把熟字训强拆为单字读音，不使用自动造句补齐缺失语料。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
