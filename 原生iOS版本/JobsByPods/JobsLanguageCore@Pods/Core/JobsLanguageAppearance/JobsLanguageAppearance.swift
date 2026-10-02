//
//  JobsLanguageAppearance.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsByUIKit
import JobsSwiftDSL
import JobsSwiftBaseDefines

@MainActor
public final class JobsLanguageAppearance {
    public static let shared = JobsLanguageAppearance()
    private weak var window: UIWindow?

    public var mode: String {
        UserDefaults.standard.string(forKey: "JobsLanguage.appearance") ?? "system"
    }

    public func attach(_ window: UIWindow) {
        if let bundle = try? JobsLanguageResources.bundle("JobsLanguageCoreResources", owner: JobsLanguageBaseVC.self) {
            _ = try? JobsThemeCenter.shared.configure(resource: "JobsThemeResources", bundle: bundle)
        }
        self.window = window
        apply()
    }

    public func choose(_ value: String) {
        UserDefaults.standard.set(value, forKey: "JobsLanguage.appearance")
        apply()
    }

    public func systemDidChange() {
        if mode == "system" {
            apply()
        }
    }

    private func apply() {
        let style: UIUserInterfaceStyle = mode == "dark" ? .dark : mode == "light" ? .light : .unspecified
        window?.byLearningInterfaceStyle(style)
        let dark = mode == "dark" || (mode == "system" && window?.traitCollection.userInterfaceStyle == .dark)
        JobsThemeCenter.shared.setStyle(dark ? .dark : .light)
    }
}
