//
//  UIButton+DSL.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsSwiftDSL
import JobsSwiftBaseDefines

public extension UIButton {

    @discardableResult func byLearningBackgroundColor(_ color: UIColor, cornerRadius: CGFloat = 12) -> Self {
        let apply: (UIButton, UIColor) -> Void = { button, resolved in
            button.byConfiguration(
                (button.configuration ?? .plain())
                    .byBackground(
                        UIBackgroundConfiguration.byClear()
                            .byBackgroundColor(resolved)
                            .byCornerRadius(cornerRadius)))
        }
        let slot = "JobsLanguage.button.background"
        if let key = color.jobsThemeColorKey {
            JobsThemeCenter.shared.bind(self, slot: slot) { object, center in
                guard let button = object as? UIButton else {
                    return
                }
                apply(button, center.resolvedColor(key))
            }
        } else {
            JobsThemeCenter.shared.unbind(self, slot: slot)
            apply(self, color)
        }
        return self
    }
}
