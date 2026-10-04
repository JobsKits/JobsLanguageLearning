//
//  JobsKoreanLesson.swift
//  JobsKoreanLearning
//
//  Created by Jobs on 2026年10月3日，星期六.
//

import JobsLanguageCore

public enum JobsKoreanLesson {
    public static let course = JobsLanguageSyllableCourse(
        title: "朝鲜语拼读",
        language: "ko-KR",
        vowels: [
            "ㅏ", "ㅑ", "ㅓ", "ㅕ", "ㅗ", "ㅛ", "ㅜ", "ㅠ", "ㅡ", "ㅣ",
            "ㅐ", "ㅒ", "ㅔ", "ㅖ", "ㅘ", "ㅙ", "ㅚ", "ㅝ", "ㅞ", "ㅟ", "ㅢ"
        ],
        consonants: Array("ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ").map(String.init),
        codas: [
            "", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ",
            "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ",
            "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
        ],
        notice:
            "19 个声母、21 个元音可组合成韩文音节块，并可选择 27 种收音或无收音。"
            + "音节附韩国修订罗马字与宽式 IPA；ㅇ 作声母时不发音。收音在词中会受连音和音变规则影响，"
            + "标注只作入门提示，系统 TTS 仅供试听。",
        format: .hangul
    )
}
