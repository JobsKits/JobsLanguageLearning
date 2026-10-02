//
//  AVSpeechUtterance+Make.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import AVFoundation

public extension AVSpeechUtterance {

    static func make(lessonText text: String) -> AVSpeechUtterance {
        AVSpeechUtterance(string: text)
    }

    @discardableResult func byLessonVoice(_ value: AVSpeechSynthesisVoice) -> Self {
        voice = value
        return self
    }

    @discardableResult func byLessonRate(_ value: Float) -> Self {
        rate = value
        return self
    }

    @discardableResult func byLessonVolume(_ value: Float) -> Self {
        volume = value
        return self
    }

    @discardableResult func byLessonPause(_ value: TimeInterval) -> Self {
        postUtteranceDelay = value
        return self
    }
}
