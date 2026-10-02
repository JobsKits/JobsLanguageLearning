//
//  AVSpeechSynthesisVoice+Make.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import AVFoundation

public extension AVSpeechSynthesisVoice {

    static func make(lessonLanguage language: String) -> AVSpeechSynthesisVoice? {
        AVSpeechSynthesisVoice(language: language)
    }

    static func make(lessonIdentifier id: String) -> AVSpeechSynthesisVoice? {
        AVSpeechSynthesisVoice(identifier: id)
    }
}
