//
//  JobsLanguageHomeVC.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsByUIKit
import JobsSwiftDSL
import JobsSwiftBaseDefines
import JobsLanguageCore
import JobsRussianLearning
import JobsEnglishLearning
import JobsKanjiLearning
import SnapKit
import GKNavigationBarSwift

final class JobsLanguageHomeVC: JobsLanguageBaseVC, UITableViewDataSource, UITableViewDelegate {

    override var learningTitle: String {
        "Jobs语言学习"
    }
    private let titles = ["俄语拼读", "分级英语词本", "日语汉字点读"]
    private let details = [
        "31 个字母 · 210 个组合 · 分组与全表点读", "初中 / 高中 / CET4 / CET6 / 专八 / 雅思 1～7", "音读 / 训读 / 名乘 · 中日释义 · 红字振假名"
    ]
    private lazy var table = UITableView.make(learningStyle: .insetGrouped)
        .byDelegate(self)
        .byDataSource(self)
        .byRowHeight(UITableView.automaticDimension)
        .byEstimatedRowHeight(105)
        .byBackgroundColor(JobsCor.systemGroupedBackground)

    override func viewDidLoad() {
        super.viewDidLoad()
        table.byAddTo(view) { [unowned self] make in
            make.top.equalTo(gk_navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "选择一个学习工具"
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "离线词库 · 系统点读 · 白天 / 黑夜 / 跟随系统"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell.make(style: .subtitle)
            .byText(titles[indexPath.row])
            .bySecondaryText(details[indexPath.row])
            .byTitleFont(JobsFont.systemFont(ofSize: 21, weight: .semibold))
            .byDetailTitleFont(JobsFont.systemFont(ofSize: 14))
            .byDetailTitleNumberOfLines(0)
            .byTitleCor(JobsCor.label)
            .byDetailTitleCor(JobsCor.secondaryLabel)
            .byAccessoryType(.disclosureIndicator)
            .byBackgroundColor(JobsCor.secondarySystemGroupedBackground)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.byDeselectRow(indexPath)
        switch indexPath.row {
        /// 进入从 Swift Demo 提取的俄语点读
        case 0:
            push(
                JobsRussianLearningVC.jobsMake { _ in
                })
        /// 进入 Swift 重写的分级英语词本
        case 1:
            push(
                JobsEnglishLearningVC.jobsMake { _ in
                })
        /// 进入 Swift 重写的日语汉字词库
        default:
            push(
                JobsKanjiLearningVC.jobsMake { _ in
                })
        }
    }
}
