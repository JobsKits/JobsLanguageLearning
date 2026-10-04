# JobsFrenchLearning

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

法语拼读练习数据模块，提供基础元音字母、辅音字母与常见多字母组合；依赖公共 `JobsLanguageCore`，不依赖 Demo 根列表。

## 一、职责与拼读范围 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `JobsFrenchLesson.course`：`fr-FR` 发音课程，包含 6 个元音字母、20 个辅音字母，以及 `ch / gn / ph` 组合。
- `q` 行仅开放 `que / qui`；`·` 标记 `k / w / x` 等较少见字母。
- 法语 `e / y / c / g / h` 和多字母组合的实际读音受拼写位置影响。本课程用于基础组合试听，不是完整 IPA 课程或逐项人工录音。
- App 页面、矩阵和语音设置位于 `JobsLanguageLearning/Business/JobsPronunciationLearning`；本 Pod 只保存课程模型。

课程以 [法国教育部法语音素表](https://www.education.gouv.fr/media/199500/download) 为发音范围参考。系统 TTS 需要设备上有对应法语声音，不会回退到其它语种。

## 二、入口 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

公开入口为 `JobsFrenchLesson.course`。音节组合由 JobsLanguageCore 的 `JobsLanguageSyllableCourse` 生成；`JobsFrenchLearning.podspec` 描述 Pod 与 `JobsLanguageCore` 依赖。

## 三、常见问题 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

**为什么有些字母和组合不像单一辅音音素？** 系统 TTS 朗读拼写文本，可能按字母名或上下文规则合成。完整发音需结合教师示范或专业音素教材。

**是否覆盖法语全部元音？** 页面采用 6 个基础元音字母拼读；带符号拼写、鼻化元音、半元音及重音不作为独立课程矩阵。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
