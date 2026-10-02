//
//  JobsEnglishWordDetailVC.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsByUIKit
import JobsSwiftDSL
import JobsSwiftBaseDefines
import JobsLanguageCore
import JobsEnglishLearning
import SnapKit
import GKNavigationBarSwift

final class JobsEnglishWordDetailVC: JobsLanguageBaseVC {
    private var word: JobsEnglishWord?
    private var senseIndex = 0

    override var learningTitle: String {
        word?.word ?? "例句"
    }

    override var speechLanguage: String? {
        "en-US"
    }
    private var buttons: [UIButton] = []
    private var labels: [UILabel] = []
    private lazy var scroll = UIScrollView.jobsMake { _ in
    }
    private lazy var content =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.vertical)
        .bySpacing(14)

    @discardableResult func byWord(_ value: JobsEnglishWord, sense: Int) -> Self {
        word = value
        senseIndex = sense
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
        guard let word else {
            return
        }
        addButton(word.word, speechText: word.word, size: 32)
        addLabel(word.phonetic, secondary: true)
        if word.senses.indices.contains(senseIndex) {
            let sense = word.senses[senseIndex]
            addLabel("当前释义：\(sense.pos). \(sense.meaning)")
        }
        addLabel("例句为词条级收录，原库没有逐义对应关系。", secondary: true)
        for sense in word.senses {
            addLabel("\(sense.pos). \(sense.meaning)")
        }
        if word.examples.isEmpty {
            addLabel("原词库未收录此词例句。", secondary: true)
        }
        for (index, example) in word.examples.enumerated() {
            addButton("\(index + 1)、\(example.en)", speechText: example.en)
            addLabel(example.zh, secondary: true)
        }
        if !word.phrases.isEmpty {
            addLabel("词组")
        }
        for phrase in word.phrases {
            addButton(phrase.en, speechText: phrase.en)
            addLabel(phrase.zh, secondary: true)
        }
    }

    private func addLabel(_ text: String, secondary: Bool = false) {
        let label = JobsLanguageLearningStyle.label(text, secondary: secondary)
        labels.append(label)
        content.byAddArrangedSubview(label)
    }

    private func addButton(_ title: String, speechText: String, size: CGFloat = 17) {
        let button = JobsLanguageLearningStyle.button(title, size: size)
            .byContentHorizontalAlignment(.leading)
            .byNumberOfLines(0)
            .onTap { [weak self] _ in
                self?.speak(speechText, language: "en-US")
            }
        buttons.append(button)
        content.byAddArrangedSubview(button)
    }
}
