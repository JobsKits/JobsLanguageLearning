# JobsKoreanLearning

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

朝鲜语韩文拼读课程数据模块，依赖公共 `JobsLanguageCore`，不依赖 Demo 根列表。

## 一、职责与音节结构 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `JobsKoreanLesson.course`：`ko-KR` 发音课程，使用 19 个声母、21 个元音，并提供 27 种收音及无收音选项。
- `JobsLanguageSyllableCourse` 按韩文 Unicode 音节块公式组合声母、元音与可选收音，显示为可朗读的完整韩文音节。
- `ㅇ` 作为声母时不发音；收音的实际实现可能随词中位置发生连音和音变。
- App 页面和语音设置位于 `JobsLanguageLearning/Business/JobsPronunciationLearning`；本 Pod 只保存课程数据。

音节结构参考 [韩国国立国语院韩文介绍](https://www.korean.go.kr/eng_hangeul/principle/001.html)。课程展示音节块并使用系统 TTS 试听，不替代逐项人工录音或词中音变课程。

## 二、入口 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

公开入口为 `JobsKoreanLesson.course`。课程使用 JobsLanguageCore 的 `JobsLanguageSyllableCourse` 生成音节块；`JobsKoreanLearning.podspec` 描述 Pod 与 `JobsLanguageCore` 依赖。缺少系统朝鲜语声音时会提示安装，不使用其它语种兜底。

## 三、常见问题 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

**为什么要选收音？** 韩文音节块由声母、元音及可选收音构成；通过同一声母和元音切换收音，试听这些组合。

**表中的音节都代表常用词吗？** 不是。表格用于观察文字组合，孤立音节的 TTS 结果以及词中连音、音变需要另行结合词语学习。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
