//
//  JobsKanjiTranslationView.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import SwiftUI
import JobsKanjiLearning
import Translation

/// 系统翻译会话的 UIKit 桥接载体，业务页面由 UIKit / Jobs DSL 建立。
struct JobsKanjiTranslationView: View {
    @ObservedObject var translator: JobsKanjiChineseTranslator

    var body: some View {
        Color.clear.translationTask(translator.configuration) { session in
            await translator.translate(using: session)
        }
    }
}
