//
//  JobsRussianPairView.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsByUIKit
import JobsLanguageCore
import JobsRussianLearning
import JobsSwiftDSL
import JobsSwiftBaseDefines
import SnapKit

/// 一张卡片包含两个独立点击区域：左侧元音、右侧组合。
final class JobsRussianPairView: UIView {
    var onRead: ((String) -> Void)?
    private var vowel = "а"
    private var syllable = "ба"
    private var uncommon = false
    private lazy var vowelButton = JobsLanguageLearningStyle.button("а", size: 22)
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            onRead?(vowel)
        }
    private lazy var syllableButton = JobsLanguageLearningStyle.button("ба", size: 27)
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            onRead?(syllable)
        }

    override init(frame: CGRect) {
        super.init(frame: frame)
        vowelButton.byAddTo(self) { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(48)
        }
        syllableButton.byAddTo(self) { [unowned self] make in
            make.left.equalTo(vowelButton.snp.right).offset(3)
            make.top.right.bottom.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(consonant: String, vowel: String, current: String) {
        self.vowel = vowel
        syllable = consonant + vowel
        uncommon = JobsRussianLesson.isUncommon(consonant, vowel)
        vowelButton.byTitle(vowel)
        syllableButton.byTitle(syllable + (uncommon ? "·" : ""))
        highlight(current)
    }

    func highlight(_ text: String) {
        JobsLanguageLearningStyle.paint(vowelButton, selected: text == vowel)
        JobsLanguageLearningStyle.paint(syllableButton, selected: text == syllable, uncommon: uncommon)
    }
}
