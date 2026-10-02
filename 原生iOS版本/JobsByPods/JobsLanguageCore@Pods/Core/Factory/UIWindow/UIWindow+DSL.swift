//
//  UIWindow+DSL.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit

public extension UIWindow {

    @discardableResult func byLearningInterfaceStyle(_ value: UIUserInterfaceStyle) -> Self {
        overrideUserInterfaceStyle = value
        return self
    }
}
