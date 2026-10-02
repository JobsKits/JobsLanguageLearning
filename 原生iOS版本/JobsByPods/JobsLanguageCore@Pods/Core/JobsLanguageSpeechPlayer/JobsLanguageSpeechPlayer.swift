//
//  JobsLanguageSpeechPlayer.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import AVFoundation
import JobsByUIKit

/// 迁自语言学习 Demo；每页独占播放器，取消后丢弃旧 utterance 回调。
@MainActor
public final class JobsLanguageSpeechPlayer: NSObject, AVSpeechSynthesizerDelegate {
    public var onStart: ((String) -> Void)?
    public var onFinish: (() -> Void)?
    public var onError: ((String) -> Void)?
    private var pending: [ObjectIdentifier: String] = [:]
    private lazy var synthesizer = AVSpeechSynthesizer.jobsMake {
        $0.byLessonDelegate(self)
            .byLessonAudioSession(false)
    }

    @discardableResult public func byOnStart(_ value: @escaping (String) -> Void) -> Self {
        onStart = value
        return self
    }

    @discardableResult public func byOnFinish(_ value: @escaping () -> Void) -> Self {
        onFinish = value
        return self
    }

    @discardableResult public func byOnError(_ value: @escaping (String) -> Void) -> Self {
        onError = value
        return self
    }

    public func play(_ texts: [String], language: String, rate: Float? = nil, repeats: Int? = nil) {
        stop()
        let saved = JobsLanguageSpeechSettings.voice(language)
            .flatMap {
                AVSpeechSynthesisVoice.make(lessonIdentifier: $0)
            }
        let voice =
            saved?.language.hasPrefix(String(language.prefix(2))) == true
            ? saved : AVSpeechSynthesisVoice.make(lessonLanguage: language)
        guard let voice, voice.language.hasPrefix(String(language.prefix(2))) else {
            onError?(
                "未找到\(language.hasPrefix("ru") ? "俄语" : language.hasPrefix("ja") ? "日语" : "英语")声音，请在系统辅助功能的朗读声音设置中下载对应语言后重试。"
            )
            return
        }
        for text in texts where !text.isEmpty {
            for _ in 0..<max(1, min(repeats ?? JobsLanguageSpeechSettings.repeats(language), 3)) {
                let utterance = AVSpeechUtterance.make(lessonText: text)
                    .byLessonVoice(voice)
                    .byLessonRate(rate ?? JobsLanguageSpeechSettings.rate(language))
                    .byLessonVolume(JobsLanguageSpeechSettings.volume(language))
                    .byLessonPause(0.3)
                pending[ObjectIdentifier(utterance)] = text
                synthesizer.byLessonSpeak(utterance)
            }
        }
    }

    public func stop() {
        pending.removeAll()
        synthesizer.byLessonStop()
    }
    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance)
    {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor [weak self] in
            guard let self, let text = pending[id] else {
                return
            }
            onStart?(text)
        }
    }
    nonisolated public func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance
    ) {
        complete(ObjectIdentifier(utterance))
    }
    nonisolated public func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance
    ) {
        complete(ObjectIdentifier(utterance))
    }
    nonisolated private func complete(_ id: ObjectIdentifier) {
        Task { @MainActor [weak self] in
            guard let self, pending.removeValue(forKey: id) != nil else {
                return
            }
            if pending.isEmpty {
                onFinish?()
            }
        }
    }
}
