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
import JobsFrenchLearning
import JobsSpanishLearning
import JobsKoreanLearning
import JobsGermanLearning
import JobsEnglishLearning
import JobsKanjiLearning
import SnapKit
import GKNavigationBarSwift

final class JobsLanguageHomeVC: JobsLanguageBaseVC, UITableViewDataSource, UITableViewDelegate {

    private enum ToolKind {
        case english
        case russian
        case french
        case spanish
        case korean
        case german
        case japanese
        case arabic
    }

    private struct Tool {
        let kind: ToolKind
        let title: String
        let flag: String
        let detail: String
    }

    override var learningTitle: String {
        "Jobs语言学习"
    }
    private let tools = [
        Tool(
            kind: .english,
            title: "分级英语词本",
            flag: "🇬🇧",
            detail: "初中 / 高中 / CET4 / CET6 / 专八 / 雅思 1～7"
        ),
        Tool(
            kind: .russian,
            title: "俄语拼读",
            flag: "🇷🇺",
            detail: "31 个字母 · 210 个组合 · 分组与全表点读"
        ),
        Tool(
            kind: .french,
            title: "法语拼读",
            flag: "🇫🇷",
            detail: "6 个元音 · 辅音与元音组合点读"
        ),
        Tool(
            kind: .spanish,
            title: "西班牙语拼读",
            flag: "🇪🇸",
            detail: "5 个元音 · 辅音与元音组合点读"
        ),
        Tool(
            kind: .korean,
            title: "朝鲜语拼读",
            flag: "🇰🇷",
            detail: "19 个声母 · 21 个元音 · 可选收音"
        ),
        Tool(
            kind: .german,
            title: "德语拼读",
            flag: "🇩🇪",
            detail: "8 个基础元音 · 外来词 y · 辅音组合点读"
        ),
        Tool(
            kind: .japanese,
            title: "日语汉字点读",
            flag: "🇯🇵",
            detail: "音读 / 训读 / 名乘 · 中日释义 · 红字振假名"
        ),
        Tool(
            kind: .arabic,
            title: "阿拉伯语拼读",
            flag: "",
            detail: "28 个辅音 · 3 个短元音 · 拉丁注音与 IPA"
        )
    ]
    private let arabicCourse = JobsLanguageSyllableCourse(
        title: "阿拉伯语拼读",
        language: "ar-SA",
        vowels: ["َ", "ِ", "ُ"],
        consonants: Array("ءبتثجحخدذرزسشصضطظعغفقكلمنهوي").map(String.init),
        notice:
            "基础短元音拼读表：辅音加َ a、ِ i、ُ u；拉丁注音与 IPA 是常见现代标准阿拉伯语的入门提示。阿拉伯语日常书写通常省略短元音，词中读音、长元音、辅音连缀与地区口音不在本表范围内。"
    )
    private lazy var table = UITableView.make(learningStyle: .plain)
        .byDelegate(self)
        .byDataSource(self)
        .byRowHeight(UITableView.automaticDimension)
        .byEstimatedRowHeight(105)
        .bySectionHeaderHeight(44)
        .byEstimatedSectionHeaderHeight(44)
        .byNoSectionHeaderTopPadding()
        .byBackgroundColor(JobsCor.systemGroupedBackground)

    override func viewDidLoad() {
        super.viewDidLoad()
        table.byAddTo(view) { [unowned self] make in
            make.top.equalTo(gk_navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tools.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "选择一个学习工具"
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "离线词库 · 系统点读 · 白天 / 黑夜 / 跟随系统"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tool = tools[indexPath.row]
        let title = tool.flag.isEmpty ? tool.title : "\(tool.flag)  \(tool.title)"
        return UITableViewCell.make(style: .subtitle)
            .byText(title)
            .byImage(tool.kind == .arabic ? #imageLiteral(resourceName: "ArabLeagueFlag") : nil)
            .bySecondaryText(tool.detail)
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
        switch tools[indexPath.row].kind {
        /// 进入从 Swift Demo 提取的俄语点读
        case .russian:
            push(
                JobsRussianLearningVC.jobsMake { _ in
                })
        /// 进入法语音节组合点读
        case .french:
            push(
                JobsSyllableLearningVC.jobsMake { _ in
                }
                .byCourse(JobsFrenchLesson.course)
            )
        /// 进入西班牙语音节组合点读
        case .spanish:
            push(
                JobsSyllableLearningVC.jobsMake { _ in
                }
                .byCourse(JobsSpanishLesson.course)
            )
        /// 进入朝鲜语音节组合点读
        case .korean:
            push(
                JobsSyllableLearningVC.jobsMake { _ in
                }
                .byCourse(JobsKoreanLesson.course)
            )
        /// 进入德语字母与组合点读
        case .german:
            push(
                JobsSyllableLearningVC.jobsMake { _ in
                }
                .byCourse(JobsGermanLesson.course)
            )
        /// 进入 Swift 重写的分级英语词本
        case .english:
            push(
                JobsEnglishLearningVC.jobsMake { _ in
                })
        /// 进入 Swift 重写的日语汉字词库
        case .japanese:
            push(
                JobsKanjiLearningVC.jobsMake { _ in
                })
        /// 进入阿拉伯语短元音组合点读
        case .arabic:
            push(
                JobsSyllableLearningVC.jobsMake { _ in
                }
                .byCourse(arabicCourse)
            )
        }
    }
}
