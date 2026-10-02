//
//  UIViewController+DSL.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsSwiftDSL
import GKNavigationBarSwift

public extension UIViewController {

    @discardableResult func byLearningFitNavigationBar() -> Self {
        let bar = gk_navigationBar
        let frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: bar.bounds.height)
        if bar.frame != frame {
            bar.byFrame(frame)
                .bySetNeedsLayout()
        }
        return self
    }

    @discardableResult func byLearningBackAccessibility(_ label: String) -> Self {
        gk_navLeftBarButtonItem?.customView?.accessibilityLabel = label
        return self
    }

    @discardableResult func byLearningHideRootBackItem() -> Self {
        gk_navLeftBarButtonItem = nil
        gk_navLeftBarButtonItems = nil
        return self
    }

    @discardableResult func byLearningObserveAppearance(_ handler: @escaping () -> Void) -> Self {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (_: UIViewController, _: UITraitCollection) in
            handler()
        }
        return self
    }
}
