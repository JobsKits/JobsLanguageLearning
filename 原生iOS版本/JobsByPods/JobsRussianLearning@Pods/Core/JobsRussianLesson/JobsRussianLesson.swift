//
//  JobsRussianLesson.swift
//  JobsRussianLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation
import JobsLanguageCore

/// 字母、拼读顺序与提示独立于布局，后续语种各自提供课程数据。
public enum JobsRussianLesson {
    public static let consonants = Array("бвгджзйклмнпрстфхцчшщ").map(String.init)
    public static let vowels = ["а", "я", "о", "ё", "у", "ю", "ы", "и", "э", "е"]
    public static let language = "ru-RU"
    private static let pronunciationCourse = JobsLanguageSyllableCourse(
        title: "俄语拼读",
        language: language,
        vowels: vowels,
        consonants: consonants,
        notice: ""
    )

    public static func pronunciationHint(forVowel vowel: String) -> String {
        pronunciationCourse.pronunciationHint(forVowel: vowel)
    }

    public static func pronunciationHint(forConsonant consonant: String) -> String {
        pronunciationCourse.pronunciationHint(forConsonant: consonant)
    }

    public static func pronunciationHint(consonant: String, vowel: String) -> String {
        pronunciationCourse.pronunciationHint(consonant: consonant, vowel: vowel)
    }

    public static func isUncommon(_ consonant: String, _ vowel: String) -> Bool {
        consonant == "й"
            || ("гкхжшчщ".contains(consonant) && vowel == "ы")
            || ("жшчщц".contains(consonant) && "яю".contains(vowel))
            || ("чщ".contains(consonant) && vowel == "э")
    }

    public static func hint(for text: String) -> String {
        guard text.count == 2, let c = text.first, let v = text.last else {
            return "单字母试听 · 辅音字母名称与纯辅音音素不同。"
        }
        let consonant = String(c)
        let vowel = String(v)
        var note: String
        if isUncommon(consonant, vowel) {
            note = "少见拼写组合 · 可试听，不作为常规拼写范例。"
        } else if "жшц".contains(c) {
            note = vowel == "и" ? "通常恒硬的辅音；这里 и 的声音接近 ы。" : "通常恒硬的辅音，不随元音机械软化。"
        } else if "йчщ".contains(c) {
            note = "通常恒软的辅音；跟读时留意舌位。"
        } else {
            note = "яёюие".contains(v) ? "通常配软辅音 · 与左列比较听。" : "通常配硬辅音 · 与右列比较听。"
        }
        return note + "\n拉丁转写 · IPA：\(pronunciationHint(consonant: consonant, vowel: vowel))"
    }
}
