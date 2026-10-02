//
//  TranslationDeviceAPI.swift
//  JobsLanguageLearningVerification
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation
import Translation

/// 只做 iPhoneOS SDK 类型检查，覆盖模拟器条件编译排除的配置分支。
@MainActor
func verifyDeviceTranslationConfiguration() {
    var configuration: TranslationSession.Configuration? = nil
    if configuration == nil {
        configuration = TranslationSession.Configuration(source: Locale.Language(identifier: "en"), target: Locale.Language(identifier: "zh-Hans"))
    } else {
        configuration?.invalidate()
    }
}
