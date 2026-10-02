//
//  JobsKanjiWordDetailVC.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsSwiftBlock
import JobsByUIKit
import JobsSwiftDSL
import JobsSwiftBaseDefines
import JobsLanguageCore
import JobsKanjiLearning
import SnapKit
import GKNavigationBarSwift

final class JobsKanjiWordDetailVC: JobsLanguageBaseVC {
    private var word: JobsKanjiWord?
    private var spelling = ""
    private var reading = ""
    private var labels: [UILabel] = []
    private var buttons: [UIButton] = []
    private var rubies: [JobsKanjiRubyText] = []
    private lazy var translator = JobsKanjiChineseTranslator()
    private lazy var translationHost = JobsKanjiTranslationHost.make(translator: translator)
    private lazy var translationStatus = JobsLanguageLearningStyle.label("未缓存的释义可在本机生成中文。", size: 12, secondary: true)
    private lazy var translationButton = JobsLanguageLearningStyle.button("生成 / 重试中文译文")
        .onTap { [weak self] _ in
            self?.translator.request()
        }
    private lazy var scroll = UIScrollView.jobsMake { _ in
    }
    private lazy var content =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.vertical)
        .bySpacing(16)

    override var learningTitle: String {
        spelling + " / " + reading
    }

    override var speechLanguage: String? {
        "ja-JP"
    }

    @discardableResult func byWord(_ value: JobsKanjiWord, spelling: String, reading: String) -> Self {
        word = value
        self.spelling = spelling
        self.reading = reading
        return self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scroll.byAddTo(view) { [unowned self] make in
            make.top.equalTo(gk_navigationBar.snp.bottom)
            make.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        content.byAddTo(scroll) { [unowned self] make in
            make.edges.equalTo(scroll.contentLayoutGuide).inset(16)
            make.width.equalTo(scroll.frameLayoutGuide).offset(-32)
        }
        translator.onStatus = { [weak self] text in
            self?.translationStatus.byText(text)
        }
        byKanjiTranslationHost(translationHost)
        translationHost.view.byAddTo(view) { make in
            make.left.bottom.equalToSuperview()
            make.width.height.equalTo(1)
        }
        addButton(spelling + " / " + reading + " · 点读", speechText: JobsKanjiLinguistics.spoken(reading))
        addLabel("例句按词义关联；红字为自动振假名，可能存在歧义。中文为辅助译文，尚未全量人工校对。")
        addTranslationControls()
        guard let word else {
            return
        }
        var pos: [String: String] = [:]
        if let bundle = try? JobsLanguageResources.bundle(
            "JobsKanjiLearningResources", owner: JobsKanjiRepository.self),
            let url = bundle.url(forResource: "pos_zh", withExtension: "json"), let data = try? Data(contentsOf: url)
        {
            pos =
                (try? JSONDecoder.make { _ in
                }
                .decode([String: String].self, from: data)) ?? [:]
        }
        let senses = word.allowedSenses(spelling: spelling, reading: reading)
        if senses.isEmpty {
            addLabel("原词库未收录适用于此写法和读法的词义。")
        }
        for (index, sense) in senses.enumerated() {
            addLabel("\(index + 1)、词义")
            addTranslation(sense.gloss.joined(separator: "; "))
            addLabel(
                "词性："
                    + sense.pos
                    .map {
                        pos[$0] ?? "词性暂未完成中文标注"
                    }
                    .joined(separator: " / "))
            sense.info.forEach {
                addTranslation($0)
            }
            if sense.examples.isEmpty {
                addLabel("此词义未收录例句。")
            }
            for example in sense.examples {
                let ruby =
                    JobsKanjiRubyText.jobsMake { _ in
                    }
                    .byTokens(example.tokens)
                    .byOnRead { [weak self] text in
                        self?.speak(text, language: "ja-JP")
                    }
                rubies.append(ruby)
                content.byAddArrangedSubview(ruby)
                addButton("朗读整句", speechText: example.jp)
                addTranslation(example.en)
                if !example.source.isEmpty {
                    addLabel("例句来源：Tatoeba 编号 \(example.source)")
                }
            }
        }
    }

    private func addTranslationControls() {
        content.byAddArrangedSubview(translationStatus)
            .byAddArrangedSubview(translationButton)
    }

    private func addLabel(_ text: String) {
        let label = JobsLanguageLearningStyle.label(text, size: 14, secondary: true)
        labels.append(label)
        content.byAddArrangedSubview(label)
    }

    private func addTranslation(_ source: String) {
        let label = JobsLanguageLearningStyle.label(size: 16)
        labels.append(label)
        content.byAddArrangedSubview(label)
        translator.bind(label, source: source)
    }

    private func addButton(_ title: String, speechText: String) {
        let button = JobsLanguageLearningStyle.button(title)
            .byNumberOfLines(0)
            .byContentHorizontalAlignment(.leading)
            .onTap { [weak self] _ in
                self?.speak(speechText, language: "ja-JP")
            }
        buttons.append(button)
        content.byAddArrangedSubview(button)
    }
}
