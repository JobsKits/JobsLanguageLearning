//
//  UIView+DSL.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsSwiftBaseDefines

public extension UIView {

    @discardableResult
    func byLearningAccessibility(label: String, value: String, hint: String) -> Self {
        accessibilityLabel = label
        accessibilityValue = value
        accessibilityHint = hint
        return self
    }

    @discardableResult func byLearningObserveAppearance(_ handler: @escaping () -> Void) -> Self {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (_: UIView, _: UITraitCollection) in
            handler()
        }
        // 富文本存储的是已解析颜色，主题中心更新后仍需重新生成。
        JobsThemeCenter.shared.bind(self, slot: "JobsLanguage.view.appearance") { _, _ in
            handler()
        }
        return self
    }
}
