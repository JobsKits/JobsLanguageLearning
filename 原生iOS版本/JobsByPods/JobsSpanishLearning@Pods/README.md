# JobsSpanishLearning

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

西班牙语拼读练习数据模块，提供基础元音字母、辅音字母与常见拼写组合；依赖公共 `JobsLanguageCore`，不依赖 Demo 根列表。

## 一、职责与拼读范围 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `JobsSpanishLesson.course`：`es-ES` 发音课程，包含 5 个元音、22 个辅音字母，以及 `ch / ll` 组合行。
- `q` 行只开放 `que / qui`；`·` 标记 `k / w / x` 等较少见或常见于外来词的字母。
- `h` 不发音，`c / g` 的读音随后接元音改变；`b / v` 通常同音，`z / c` 在 seseo / ceceo 地区读音不同。
- App 页面、矩阵和语音设置位于 `JobsLanguageLearning/Business/JobsPronunciationLearning`；本 Pod 只保存课程模型。

字母与拼写参考 [西班牙皇家学院正字法文档](https://www.rae.es/diccionario-estudiante/docs/ortografia.pdf)，地区差异参考 [RAE 对 seseo / ceceo 的说明](https://www.rae.es/buen-uso-español/el-seseo-y-el-ceceo)。本课程用于基础组合试听，不是完整 IPA 或逐项人工录音。

## 二、入口 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

公开入口为 `JobsSpanishLesson.course`。音节组合由 JobsLanguageCore 的 `JobsLanguageSyllableCourse` 生成；`JobsSpanishLearning.podspec` 描述 Pod 与 `JobsLanguageCore` 依赖。系统 TTS 需要设备上有对应西班牙语声音，不会回退到其它语种。

## 三、常见问题 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

**`ch` 和 `ll` 为什么单列？** 它们是常见字母组合，便于按一个辅音行练习；课程不把它们称为西班牙字母表中的独立字母。

**为什么 `q` 不能与任意元音组合？** 基础拼写中 `q` 主要出现在 `que / qui`；`u` 不单独作为此处的元音读出。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
