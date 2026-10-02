# 多语言国际化

[toc]

> 中文架构入口：[架构脉络与关键设计](#jobs-architecture)。

## 一、使用说明

* 必要时，需要在启动时注册

  ```swift
  func application(_ application: UIApplication, didFinishLaunchingWithOptions
                   launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
      // MARK: - 语言跟随系统
      LanguageManager.shared.followSystemLanguage()
    
      // MARK: - 语言切换成固定的
      Bundle.enableLanguageOverride()
      /// 先切语言（会更新 localizedBundle）
      LanguageManager.shared.switchTo("vi")
      /// 再把 Bundle.main 指到你的语言 bundle（让 storyboard/xib 也变）
      Bundle.setLanguageBundle(LanguageManager.shared.localizedBundle)
    
      print("✅ currentLanguageCode =", LanguageManager.shared.currentLanguageCode)
      print("✅ preferredLanguages =", Locale.preferredLanguages)
      print("✅ bundlePath =", Bundle.main.path(forResource: LanguageManager.shared.currentLanguageCode, ofType: "lproj") ?? "nil")
  }
  ```
  
* 字符映射文件（默认）➤ `Localizable.strings`

* **应用层的调用方式**

  ```swift
  let to = (LanguageManager.shared.currentLanguageCode == "zh-Hans") ? "en" : "zh-Hans"
  LanguageManager.shared.switchTo(to)// zh-Hans、en
  ```

* 【基础】拿到当前语言字符串

  ```swift
  let s = "user.menu.fundDet".tr
  print(s)
  ```

* 【基础】短写本地化忽略大小写包含判断

  ```swift
  if "AppIcon".inStr(key) {
      print("hit")
  }
  ```

* 自动刷新**UI** ➤ 必须满足 2 个条件（否则不会自动在当前页面刷新**UI**）

  * **语言变化能触发刷新**（通知）且 **翻译来源 bundle 正确**（`TRLang.bundleProvider` 指向当前语言 bundle）
  * **UI 文案设置时走 TRBind/tr_setXXX 形成绑定注册**（而不是直接赋值/提前缓存翻译结果）

## 二、✅ UI 统一调用规范示例

调用方应引入 `JobsByUIKit`；按钮创建以及 UIKit 配置继续遵守 `JobsByUIKit` / `JobsSwiftDSL` 规范。

### 1、`UILabel`

* 普通文本

  ```swift
  titleLabel.tr_setText("KEY".tr)
  ```

* 富文本

  ```swift
  import JobsSwiftBaseDefines

  TRBind.bind(titleLabel, translated: "KEY".tr) { label, text in
      label.byAttributedText(
          NSAttributedString(
              string: text,
              attributes: [
                  .font: JobsFont.boldSystemFont(ofSize: 18),
                  .foregroundColor: JobsCor.systemBlue
              ]
          )
      )
  }
  ```

### 2、`UIButton`

* 普通文本

  ```swift
  UIButton.sys().tr_setTitle("KEY".tr, for: .normal)
  ```

* 富文本

  ```swift
  import JobsSwiftBaseDefines

  TRBind.bind(payButton, translated: "KEY".tr) { btn, text in
      btn.byAttributedTitle(
          NSAttributedString(
              string: text,
              attributes: [
                  .font: JobsFont.systemFont(ofSize: 16, weight: .medium),
                  .underlineStyle: NSUnderlineStyle.single.rawValue
              ]
          ),
          for: .normal
      )
  }
  ```

### 3、`UITextField`

* `placeholder`

  * 普通文本

    ```swift
    phoneField.tr_setPlaceholder("KEY".tr)
    ```

  * 富文本

    ```swift
    import JobsSwiftBaseDefines

    TRBind.bind(phoneField, translated: "KEY".tr) { tf, text in
        tf.byAttributedPlaceholder(
            NSAttributedString(
                string: text,
                attributes: [
                    .foregroundColor: JobsCor.gray,
                    .font: JobsFont.systemFont(ofSize: 14)
                ]
            )
        )
    }
    ```

* `text`

  * 普通文本

    ```swift
    phoneField.tr_setText("KEY".tr)
    ```

  * 富文本

    ```swift
    import JobsSwiftBaseDefines

    TRBind.bind(phoneField, translated: "KEY".tr) { tf, text in
        tf.byAttributedText(
            NSAttributedString(
                string: text,
                attributes: [
                    .foregroundColor: JobsCor.gray,
                    .font: JobsFont.systemFont(ofSize: 14)
                ]
            )
        )
    }
    ```

### 4、`UITextView`

> 原生的**UIKit**并不存在`UITextView.placeholder`

* 普通文本

  ```swift
  textView.tr_setText("KEY".tr)
  ```

* 富文本

  ```swift
  import JobsSwiftBaseDefines

  TRBind.bind(descView, translated: "KEY".tr) { tv, text in
      tv.byAttributedText(
          NSAttributedString(
              string: text,
              attributes: [
                  .font: JobsFont.systemFont(ofSize: 15),
                  .foregroundColor: JobsCor.secondaryLabel
              ]
          )
      )
  }
  ```

### 5、`UIBarButtonItem`

* ```swift
  navigationItem.tr_setTitle("KEY".tr)          /// 主标题（中间大字）
  navigationItem.tr_setPrompt("KEY".tr)         /// 主标题上方的一行小字
  navigationItem.tr_setBackButtonTitle("KEY".tr)/// 返回按钮文字
  ```

* ```swift
  navigationItem.rightBarButtonItem = UIBarButtonItem.make(title: nil)
  navigationItem.rightBarButtonItem?.tr_setTitle("KEY".tr)
  ```

### 6、`UITabBarItem`

```swift
tabBarItem.tr_setTitle("KEY".tr)
```

### 7、`UISegmentedControl`

```swift
segmentedControl.tr_setTitle("KEY".tr, forSegmentAt: 0)
segmentedControl.tr_setTitle("KEY".tr, forSegmentAt: 1)
```

### 8、`UISearchBar`

```swift
searchBar.tr_setPlaceholder("KEY".tr)
searchBar.tr_setPrompt("KEY".tr)
```

### 9、`UIAlertController`

```swift
let alert = UIAlertController.makeAlert()

alert
    .tr_setAlertTitle("KEY".tr)
    .tr_setMessage("KEY".tr)

alert.byAddAction(title: "KEY".tr)
present(alert, animated: true)
```

### 10、`UIView`（无障碍 `accessibilityLabel` / `Hint`）

```swift
contentView
    .tr_setA11yLabel("KEY".tr)
    .tr_setA11yHint("KEY".tr)
```

### 11、`UIViewController`.`title`

```swift
TRBind.bind(self, translated: "KEY".tr) { vc, text in
    vc.byTitle(text)
}
```




















<a id="jobs-architecture"></a>

## 三、架构脉络与关键设计

本节用于用中文快速理解组件，并为按框架重建提供入口；关注职责、运行关系和关键边界，不要求逐行复刻。

### 3.1、设计目的与职责划分

将语言选择、语言码归一化、Bundle 查词和已绑定 UI 自动刷新连接起来。LanguageManager 管理当前语言，Bundle 扩展改变本地化查找目标，TRAutoRefresh 与 UIKit 入口登记需要随语言变化重放的赋值。

### 3.2、运行脉络

设置或恢复语言 → 选择对应 lproj → 翻译键查词 → 登记 UI 文本绑定 → 语言切换通知触发刷新

### 3.3、关键设计与边界

- 只替换一次文字不会自动获得持续刷新，必须理解 tr_setText 等绑定入口与翻译键登记之间的关系。
- 语言码到资源目录存在归一化规则，简繁中文和地区变体不能只截取前两个字符。
- 普通文本、富文本与输入占位有不同赋值路径，UITextView 本身没有原生 placeholder 属性。
- Bundle.main 的覆盖具有全局影响，业务应统一管理语言入口，避免多个库各自安装互相冲突的覆盖。

### 3.4、阅读与重建顺序

先读 LanguageManager、TRLang，再看 Bundle/String 扩展，最后追 TRAutoRefresh 与 UIKit 的登记、通知和释放。

源码定位（路径以本 README 所在目录为基准；只带走 README 时，可把文件名作为职责定位线索）：

- [Jobsl10n.swift](<./Jobsl10n.swift>)
- [LanguageManager.swift](<./LanguageManager.swift>)
- [TRAutoRefresh.swift](<./TRAutoRefresh.swift>)
- [TRLang.swift](<./TRLang.swift>)
- [Foundation&UIKit/Bundle+多语言国际化.swift](<./Foundation&UIKit/Bundle+多语言国际化.swift>)

依赖与编译入口：[Jobsl10n.podspec](<./Jobsl10n.podspec>)。源码范围、资源及可选 subspec 以这里的声明为准；辅助脚本动态补充的依赖不在上述摘录中展开。
