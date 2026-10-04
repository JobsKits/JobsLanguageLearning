//
//  JobsFrenchLesson.swift
//  JobsFrenchLearning
//
//  Created by Jobs on 2026年10月3日，星期六.
//

import JobsLanguageCore

public enum JobsFrenchLesson {
    public static let course = JobsLanguageSyllableCourse(
        title: "法语拼读",
        language: "fr-FR",
        vowels: ["a", "e", "i", "o", "u", "y"],
        consonants: Array("bcdfghjklmnpqrstvwxz")
            .map(String.init) + ["ch", "gn", "ph"],
        notice:
            "6 个元音字母与常见辅音组合可点读，并附宽式 IPA 提示。法语 e、y、c、g、q、h 及 "
            + "ch / gn / ph 受拼写位置影响；q 只提供 que / qui。IPA 不覆盖鼻化、重音和全部位置规则；"
            + "系统 TTS 试听不等同于人工音素录音。",
        unavailableCombinations: ["q|a", "q|o", "q|u", "q|y"],
        uncommonConsonants: ["k", "w", "x"],
        syllableOverrides: ["q|e": "que", "q|i": "qui"]
    )
}
