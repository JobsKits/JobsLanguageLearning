//
//  JobsKanjiChineseTranslator.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsSwiftBlock
import SwiftUI
import Translation
import JobsByUIKit
import JobsLanguageCore
import JobsKanjiLearning

/// 英文只作为内部翻译源，学习页仅输出中日文；译文保存在 App 沙盒。
@MainActor
final class JobsKanjiChineseTranslator: ObservableObject {
    @Published var configuration: TranslationSession.Configuration?
    private var cached: [String: String] = [:]
    private var labels: [String: [WeakLabel]] = [:]
    private var sources: [String] = []
    private var activeSources: [String] = []
    private var cacheURL: URL?
    private(set) var isRunning = false
    var onStatus: ((String) -> Void)?
    private struct WeakLabel {
        weak var value: UILabel?
    }

    init() {
        if let bundle = try? JobsLanguageResources.bundle(
            "JobsKanjiLearningResources", owner: JobsKanjiRepository.self),
            let url = bundle.url(forResource: "chinese_cache", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let seed =
                try? JSONDecoder.make({ _ in
                })
                .decode([String: String].self, from: data)
        {
            cached = seed
        }
        if let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            cacheURL = directory.appendingPathComponent("JobsKanjiChinese.json")
            if let url = cacheURL, let data = try? Data(contentsOf: url),
                let saved =
                    try? JSONDecoder.make({ _ in
                    })
                    .decode([String: String].self, from: data)
            {
                cached.merge(saved) { _, new in
                    new
                }
            }
        }
    }

    func bind(_ label: UILabel, source: String) {
        guard !source.isEmpty else {
            label.byText("原字库未收录释义")
            return
        }
        if let value = cached[source] {
            label.byText(value + "（辅助译文）")
            return
        }
        label.byText("中文释义待生成 · 请点“生成 / 重试中文译文”")
        labels[source, default: []].append(WeakLabel(value: label))
        if !sources.contains(source) {
            sources.append(source)
        }
    }

    func request() {
        guard !isRunning else {
            return
        }
        guard !sources.isEmpty else {
            onStatus?("中文译文已就绪")
            return
        }
        #if targetEnvironment(simulator)
            onStatus?("系统翻译需在真机使用；模拟器保留内置中文释义与学习例句。")
            return
        #else
            isRunning = true
            activeSources = sources
            onStatus?("正在生成中文；首次使用可能需要下载系统语言包…")
            if configuration == nil {
                configuration = TranslationSession.Configuration(
                    source: Locale.Language(identifier: "en"), target: Locale.Language(identifier: "zh-Hans"))
            } else {
                configuration?.invalidate()
            }
        #endif
    }

    func translate(using session: TranslationSession) async {
        let work = activeSources
        do {
            try await session.prepareTranslation()
            for start in stride(from: 0, to: work.count, by: 12) {
                try Task.checkCancellation()
                let batch = work[start..<min(start + 12, work.count)]
                    .map {
                        TranslationSession.Request(sourceText: $0, clientIdentifier: $0)
                    }
                let responses = try await session.translations(from: batch)
                for response in responses {
                    guard let source = response.clientIdentifier else {
                        continue
                    }
                    let value = response.targetText.trimmingCharacters(in: .whitespacesAndNewlines)
                    let chinese = value.range(of: "[\\p{Han}]", options: .regularExpression) != nil
                    let english = value.range(of: "[A-Za-z]", options: .regularExpression) != nil
                    guard chinese, !english else {
                        continue
                    }
                    cached[source] = value
                    labels[source]?
                        .forEach {
                            $0.value?.byText(value + "（机器翻译，待校对）")
                        }
                    sources.removeAll {
                        $0 == source
                    }
                }
                if let url = cacheURL {
                    try JSONEncoder.make { _ in
                    }
                    .encode(cached).write(to: url, options: .atomic)
                }
            }
            onStatus?(sources.isEmpty ? "中文译文已保存，可离线复用" : "部分译文待校对，可再次生成")
        } catch {
            onStatus?("中文翻译暂不可用：\(error.localizedDescription)。可重新点击生成。")
        }
        isRunning = false
    }
}
