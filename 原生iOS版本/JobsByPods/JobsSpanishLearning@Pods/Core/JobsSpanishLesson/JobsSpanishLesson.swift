//
//  JobsSpanishLesson.swift
//  JobsSpanishLearning
//
//  Created by Jobs on 2026年10月3日，星期六.
//

import JobsLanguageCore

public enum JobsSpanishLesson {
    public static let course = JobsLanguageSyllableCourse(
        title: "西班牙语拼读",
        language: "es-ES",
        vowels: ["a", "e", "i", "o", "u"],
        consonants: Array("bcdfghjklmnñpqrstvwxyz")
            .map(String.init) + ["ch", "ll"],
        notice:
            "5 个元音、22 个辅音字母及 ch / ll 拼写组合可点读，并附宽式 IPA 提示。"
            + "c、g 会随后接元音改变读音；h 不发音，q 通过 que / qui 拼写；"
            + "b / v 同音。表按西班牙本土读音标注 /θ/，拉美 seseo 地区会读 /s/；"
            + "k / w / x 多见于外来词。",
        unavailableCombinations: ["q|a", "q|o", "q|u"],
        uncommonConsonants: ["k", "w", "x"],
        syllableOverrides: ["q|e": "que", "q|i": "qui"]
    )
}
