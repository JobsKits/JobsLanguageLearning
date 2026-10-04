# JobsGermanLearning

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

德语基础拼读课程数据模块，提供元音、辅音与常见辅音拼写组合；依赖公共 `JobsLanguageCore`，不依赖 Demo 根列表。

## 一、职责与拼读范围 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `JobsGermanLesson.course`：`de-DE` 系统语音课程，包含 `a / ä / e / i / o / ö / u / ü` 八个基础元音、外来词元音 `y`、20 个基础辅音及常见 `ch / sch / sp / st / pf / tsch` 拼写组合；字母主字形大于下方 IPA 注音。
- `q` 行会自动补入 `u` 生成常见组合；`q + ö / u / ü / y` 标为不可用。长短元音、`c / ch / s / v` 等读音按常见规则提供宽式 IPA 提示。
- 本课程用于字母和常见组合入门试听，不是完整德语音系或逐项人工录音；词源、重音、音节结构及地区变体会影响真实读音。
- App 页面与语音设置位于 `JobsLanguageLearning/Business/JobsPronunciationLearning`；本 Pod 只保存课程数据。

## 二、入口 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

公开入口为 `JobsGermanLesson.course`。组合由 JobsLanguageCore 的 `JobsLanguageSyllableCourse` 生成；`JobsGermanLearning.podspec` 描述 Pod 与 `JobsLanguageCore` 的依赖。

系统 TTS 需要设备上安装德语声音，不会回退到其它语种。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➔点我回到首页</a>
