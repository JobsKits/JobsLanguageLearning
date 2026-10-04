//
//  JobsLanguageSyllablePickerVC.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月3日，星期六.
//

import UIKit
import JobsByUIKit
import JobsLanguageCore
import JobsSwiftDSL
import JobsSwiftBaseDefines
import SnapKit
import GKNavigationBarSwift

final class JobsLanguageSyllablePickerVC: JobsLanguageBaseVC {

    private var values: [String] = []
    private var selectedValue = ""
    private var pickerTitle = "选择"
    private var onSelect: ((String) -> Void)?

    @discardableResult
    func byValues(_ value: [String]) -> Self {
        values = value
        return self
    }

    @discardableResult
    func bySelectedValue(_ value: String) -> Self {
        selectedValue = value
        return self
    }

    @discardableResult
    func byPickerTitle(_ value: String) -> Self {
        pickerTitle = value
        return self
    }

    @discardableResult
    func byOnSelect(_ value: @escaping (String) -> Void) -> Self {
        onSelect = value
        return self
    }

    override var learningTitle: String {
        pickerTitle
    }

    override var showsLearningSettings: Bool {
        false
    }

    private lazy var titleLabel = JobsLanguageLearningStyle.label(pickerTitle, size: 22)
    private lazy var closeButton = JobsLanguageLearningStyle.button("关闭")
        .onTap { [weak self] _ in
            self?.dismiss(animated: true)
        }
    private lazy var scroll = UIScrollView.jobsMake { _ in
    }
    .byShowsVerticalScrollIndicator(false)
    private lazy var content = UIStackView.jobsMake { _ in
    }
    .byAxis(.vertical)
    .bySpacing(8)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.byBackgroundColor(JobsCor.systemGroupedBackground)
        titleLabel.byAddTo(view) { [unowned self] make in
            make.top.equalTo(gk_navigationBar.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        closeButton.byAddTo(view) { [unowned self] make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        scroll.byAddTo(view) { [unowned self] make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        content.byAddTo(scroll) { [unowned self] make in
            make.edges.equalTo(scroll.contentLayoutGuide)
            make.width.equalTo(scroll.frameLayoutGuide)
        }
        for start in stride(from: 0, to: values.count, by: 4) {
            let row = UIStackView.jobsMake { _ in
            }
            .byAxis(.horizontal)
            .bySpacing(8)
            .byDistribution(.fillEqually)
            for index in start..<min(start + 4, values.count) {
                let value = values[index]
                let title = value.isEmpty ? "无收音" : value
                let button = JobsLanguageLearningStyle.button(title, size: 21)
                    .onTap { [weak self] _ in
                        self?.onSelect?(value)
                        self?.dismiss(animated: true)
                    }
                JobsLanguageLearningStyle.paint(button, selected: value == selectedValue)
                row.byAddArrangedSubview(button)
                button.snp.makeConstraints {
                    $0.height.equalTo(56)
                }
            }
            for _ in row.arrangedSubviews.count..<4 {
                row.byAddArrangedSubview(UIView.jobsMake { _ in
                })
            }
            content.byAddArrangedSubview(row)
        }
    }
}
