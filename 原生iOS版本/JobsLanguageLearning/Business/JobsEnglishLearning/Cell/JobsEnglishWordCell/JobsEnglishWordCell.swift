//
//  JobsEnglishWordCell.swift
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

final class JobsEnglishWordCell: UITableViewCell {
    private var word: JobsEnglishWord?
    var onRead: ((String) -> Void)?
    var onDetail: ((JobsEnglishWord, Int) -> Void)?

    @discardableResult func byOnRead(_ value: @escaping (String) -> Void) -> Self {
        onRead = value
        return self
    }

    @discardableResult func byOnDetail(_ value: @escaping (JobsEnglishWord, Int) -> Void) -> Self {
        onDetail = value
        return self
    }
    private var meaningButtons: [UIButton] = []
    private lazy var wordButton = JobsLanguageLearningStyle.button("", size: 20)
        .byContentHorizontalAlignment(.leading)
        .onTap { [weak self] _ in
            guard let self, let word else {
                return
            }
            onRead?(word.word)
        }
    private lazy var phonetic = JobsLanguageLearningStyle.label(size: 12, secondary: true)
    private lazy var meanings =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.vertical)
        .bySpacing(6)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bySelectionStyle(.none)
            .byBackgroundColor(JobsCor.secondarySystemGroupedBackground)
        wordButton.byAddTo(contentView) { make in
            make.top.left.equalToSuperview().inset(12)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.greaterThanOrEqualTo(40)
        }
        phonetic.byAddTo(contentView) { [unowned self] make in
            make.top.equalTo(wordButton.snp.bottom).offset(4)
            make.left.width.equalTo(wordButton)
            make.bottom.lessThanOrEqualToSuperview().inset(12).priority(999)
        }
        meanings.byAddTo(contentView) { [unowned self] make in
            make.top.right.equalToSuperview().inset(12)
            make.left.equalTo(wordButton.snp.right).offset(10)
            make.bottom.equalToSuperview().inset(12).priority(999)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult func byWord(_ word: JobsEnglishWord) -> Self {
        self.word = word
        wordButton.byTitle(word.word)
        phonetic.byText(word.phonetic)
        for button in meaningButtons {
            button.byRemoveFromSuperview()
        }
        meaningButtons.removeAll()
        for (index, sense) in word.senses.enumerated() {
            let button = JobsLanguageLearningStyle.button("\(sense.pos). \(sense.meaning)", size: 14)
                .byContentHorizontalAlignment(.leading)
                .byNumberOfLines(0)
                .onTap { [weak self] _ in
                    self?.onDetail?(word, index)
                }
            meaningButtons.append(button)
            meanings.byAddArrangedSubview(button)
        }
        if word.senses.isEmpty {
            let button = JobsLanguageLearningStyle.button("查看例句", size: 14)
                .onTap { [weak self] _ in
                    self?.onDetail?(word, 0)
                }
            meaningButtons.append(button)
            meanings.byAddArrangedSubview(button)
        }
        return self
    }
}
