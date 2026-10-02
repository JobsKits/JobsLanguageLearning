//
//  JobsRussianTableView.swift
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

/// 只有主体处理拖动；固定表头与固定首列同步偏移，不形成双向代理循环。
final class JobsRussianTableView: UIView, UIScrollViewDelegate {
    var onRead: ((String) -> Void)?
    private var buttons: [String: UIButton] = [:]
    private var cellWidth: CGFloat = 72
    private let cellHeight: CGFloat = 50
    private lazy var corner =
        UILabel.jobsMake {
            JobsLanguageLearningStyle.bindText($0, key: .textSecondary)
        }
        .byText("辅 / 元")
        .byFont(JobsFont.systemFont(ofSize: 12))

        .byTextAlignment(.center)
    private lazy var topScroll =
        UIScrollView.jobsMake { _ in
        }
        .byScrollEnabled(false)
        .byShowsHorizontalScrollIndicator(false)
    private lazy var leftScroll =
        UIScrollView.jobsMake { _ in
        }
        .byScrollEnabled(false)
        .byShowsVerticalScrollIndicator(false)
    private lazy var bodyScroll =
        UIScrollView.jobsMake { _ in
        }
        .byDelegate(self)
        .byBounces(false)
    private lazy var topContent = UIView.jobsMake { _ in
    }
    private lazy var leftContent = UIView.jobsMake { _ in
    }
    private lazy var bodyContent = UIView.jobsMake { _ in
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        assemble()
        makeButtons()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = max(72, (bounds.width - 56) / CGFloat(JobsRussianLesson.vowels.count))
        guard abs(width - cellWidth) > 0.5 else {
            return
        }
        cellWidth = width
        topContent.snp.updateConstraints {
            $0.width.equalTo(CGFloat(JobsRussianLesson.vowels.count) * width)
        }
        bodyContent.snp.updateConstraints {
            $0.width.equalTo(CGFloat(JobsRussianLesson.vowels.count) * width)
        }
        for (column, vowel) in JobsRussianLesson.vowels.enumerated() {
            let targets =
                [vowel]
                + JobsRussianLesson.consonants.map {
                    $0 + vowel
                }
            for text in targets {
                buttons[text]?.snp
                    .updateConstraints { make in
                        make.left.equalToSuperview().offset(CGFloat(column) * width + 2)
                        make.width.equalTo(width - 4)
                    }
            }
        }
    }

    private func assemble() {
        corner.byAddTo(self) { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(50)
        }
        topScroll.byAddTo(self) { [unowned self] make in
            make.left.equalTo(corner.snp.right)
            make.top.right.equalToSuperview()
            make.height.equalTo(50)
        }
        leftScroll.byAddTo(self) { [unowned self] make in
            make.top.equalTo(corner.snp.bottom)
            make.left.bottom.equalToSuperview()
            make.width.equalTo(56)
        }
        bodyScroll.byAddTo(self) { [unowned self] make in
            make.top.equalTo(topScroll.snp.bottom)
            make.left.equalTo(leftScroll.snp.right)
            make.right.bottom.equalToSuperview()
        }
        topContent.byAddTo(topScroll) { [unowned self] make in
            make.edges.equalTo(topScroll.contentLayoutGuide)
            make.width.equalTo(CGFloat(JobsRussianLesson.vowels.count) * cellWidth)
            make.height.equalTo(50)
        }
        leftContent.byAddTo(leftScroll) { [unowned self] make in
            make.edges.equalTo(leftScroll.contentLayoutGuide)
            make.width.equalTo(56)
            make.height.equalTo(CGFloat(JobsRussianLesson.consonants.count) * cellHeight)
        }
        bodyContent.byAddTo(bodyScroll) { [unowned self] make in
            make.edges.equalTo(bodyScroll.contentLayoutGuide)
            make.width.equalTo(CGFloat(JobsRussianLesson.vowels.count) * cellWidth)
            make.height.equalTo(CGFloat(JobsRussianLesson.consonants.count) * cellHeight)
        }
    }

    private func makeButtons() {
        for (col, vowel) in JobsRussianLesson.vowels.enumerated() {
            add(vowel, title: vowel, parent: topContent, x: CGFloat(col) * cellWidth, y: 0, width: cellWidth)
        }
        for (row, consonant) in JobsRussianLesson.consonants.enumerated() {
            add(consonant, title: consonant, parent: leftContent, x: 0, y: CGFloat(row) * cellHeight, width: 56)
            for (col, vowel) in JobsRussianLesson.vowels.enumerated() {
                let text = consonant + vowel
                add(
                    text, title: text + (JobsRussianLesson.isUncommon(consonant, vowel) ? "·" : ""),
                    parent: bodyContent,
                    x: CGFloat(col) * cellWidth, y: CGFloat(row) * cellHeight, width: cellWidth)
            }
        }
    }

    private func add(_ text: String, title: String, parent: UIView, x: CGFloat, y: CGFloat, width: CGFloat) {
        buttons[text] = JobsLanguageLearningStyle.button(title, size: 20)
            .onTap { [weak self] _ in
                self?.onRead?(text)
            }
            .byAddTo(parent) { [unowned self] make in
                make.left.equalToSuperview().offset(x + 2)
                make.top.equalToSuperview().offset(y + 2)
                make.width.equalTo(width - 4)
                make.height.equalTo(cellHeight - 4)
            }
    }

    func highlight(_ text: String) {
        for (key, button) in buttons {
            JobsLanguageLearningStyle.paint(button, selected: key == text)
        }
    }

    @discardableResult func byHighlight(_ text: String) -> Self {
        highlight(text)
        return self
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        topScroll.byContentOffsetBy(CGPoint(x: scrollView.contentOffset.x, y: 0))
        leftScroll.byContentOffsetBy(CGPoint(x: 0, y: scrollView.contentOffset.y))
    }
}
