//
//  JobsLanguageSpeechSettings.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import AVFoundation

public enum JobsLanguageSpeechSettings {

    private static func key(_ language: String, _ name: String) -> String {
        "JobsLanguage.speech.\(language).\(name)"
    }

    public static func rate(_ language: String) -> Float {
        let value = UserDefaults.standard.float(forKey: key(language, "rate"))
        return value > 0 ? value : (language.hasPrefix("ru") ? 0.35 : 0.45)
    }

    public static func volume(_ language: String) -> Float {
        let name = key(language, "volume")
        return UserDefaults.standard.object(forKey: name) == nil ? 1 : UserDefaults.standard.float(forKey: name)
    }

    public static func repeats(_ language: String) -> Int {
        max(1, min(3, UserDefaults.standard.integer(forKey: key(language, "repeats"))))
    }

    public static func voice(_ language: String) -> String? {
        UserDefaults.standard.string(forKey: key(language, "voice"))
    }

    public static func save(_ value: Any, language: String, name: String) {
        UserDefaults.standard.set(value, forKey: key(language, name))
    }
}
