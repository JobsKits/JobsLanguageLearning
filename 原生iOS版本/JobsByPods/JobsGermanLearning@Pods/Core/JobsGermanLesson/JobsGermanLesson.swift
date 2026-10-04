//
//  JobsGermanLesson.swift
//  JobsGermanLearning
//
//  Created by Jobs on 2026年10月4日，星期日.
//

import JobsLanguageCore

public enum JobsGermanLesson {
    public static let course = JobsLanguageSyllableCourse(
        title: "德语拼读",
        language: "de-DE",
        vowels: ["a", "ä", "e", "i", "o", "ö", "u", "ü", "y"],
        consonants: Array("bcdfghjklmnpqrstvwxz")
            .map(String.init) + ["ch", "sch", "sp", "st", "pf", "tsch"],
        notice:
            "8 个基础元音字母、外来词元音 y 与 20 个辅音字母可组合点读，并提供常见 ch / sch / sp / st / pf / tsch 拼写。"
            + "q 行组合自动补入 u；元音长短、c / ch / s / v 等读音受拼写位置和词源影响。注音为入门提示，系统 TTS 不等同于人工音素录音。",
        unavailableCombinations: ["q|ö", "q|u", "q|ü", "q|y"],
        uncommonConsonants: ["c", "q", "x"],
        syllableOverrides: Dictionary(
            uniqueKeysWithValues: ["a", "ä", "e", "i", "o", "ö", "u", "ü"].map {
                ("q|\($0)", "qu\($0)")
            }
        )
    )
}
