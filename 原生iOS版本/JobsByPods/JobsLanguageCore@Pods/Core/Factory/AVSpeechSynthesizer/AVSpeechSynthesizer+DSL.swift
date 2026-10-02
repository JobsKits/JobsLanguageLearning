//
//  AVSpeechSynthesizer+DSL.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import AVFoundation

public extension AVSpeechSynthesizer {

    @discardableResult func byLessonDelegate(_ value: AVSpeechSynthesizerDelegate) -> Self {
        delegate = value
        return self
    }

    @discardableResult func byLessonAudioSession(_ value: Bool) -> Self {
        usesApplicationAudioSession = value
        return self
    }

    @discardableResult func byLessonSpeak(_ value: AVSpeechUtterance) -> Self {
        speak(value)
        return self
    }

    @discardableResult func byLessonStop() -> Self {
        stopSpeaking(at: .immediate)
        return self
    }
}
