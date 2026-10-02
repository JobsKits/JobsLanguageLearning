//
//  JobsLanguageLearningStyle.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsByUIKit
import JobsSwiftDSL
import JobsSwiftBaseDefines

@MainActor
public enum JobsLanguageLearningStyle {

    public static func button(_ title: String, size: CGFloat = 16) -> UIButton {
        UIButton.sys()
            .byLearningBackgroundColor(JobsCor.secondarySystemGroupedBackground)
            .byTitle(title)
            .byTitleFont(JobsFont.systemFont(ofSize: size, weight: .semibold))
            .byTitleColor(JobsCor.label)
            .byTitleColor(JobsCor.secondaryLabel, for: .disabled)
    }

    public static func label(_ text: String = "", size: CGFloat = 15, secondary: Bool = false) -> UILabel {
        UILabel.jobsMake { _ in
        }
        .byText(text)
        .byFont(JobsFont.systemFont(ofSize: size))
        .byTextColor(secondary ? JobsCor.secondaryLabel : JobsCor.label)
        .byNumberOfLines(0)
    }

    public static func bindText(_ label: UILabel, key: JobsThemeColorKey) {
        label.byTextColor(JobsThemeCenter.shared.color(key))
    }

    public static func paint(_ button: UIButton, selected: Bool, uncommon: Bool = false) {
        button.byLearningBackgroundColor(
            selected
                ? JobsCor.systemBlue
                : uncommon ? JobsCor.tertiarySystemGroupedBackground : JobsCor.secondarySystemGroupedBackground
        )
        .byTitleColor(selected ? JobsCor.white : JobsCor.label)
    }
}
