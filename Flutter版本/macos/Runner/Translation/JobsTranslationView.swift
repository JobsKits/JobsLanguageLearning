//
//  JobsTranslationView.swift
//  JobsLanguageLearningFlutter
//
//  Created by Jobs on 2026年10月2日，星期五.
//

import SwiftUI
import Translation

@available(macOS 15.0, *)
struct JobsTranslationView: View {
    let source: String
    let completion: (Result<String, Error>) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("正在生成中文辅助译文")
                .font(.headline)
            ProgressView()
            Text("首次使用可能需要下载系统语言包。\n关闭窗口可取消，译文仍需人工校对。")
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(width: 420, height: 160)
        .translationTask(source: Locale.Language(identifier: "en"), target: Locale.Language(identifier: "zh-Hans")) { session in
            do {
                try await session.prepareTranslation()
                let response = try await session.translate(source)
                completion(.success(response.targetText))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
