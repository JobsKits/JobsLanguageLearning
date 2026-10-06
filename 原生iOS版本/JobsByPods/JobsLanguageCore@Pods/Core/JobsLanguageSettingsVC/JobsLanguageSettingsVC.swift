//
//  JobsLanguageSettingsVC.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import AVFoundation
import JobsByUIKit
import JobsSwiftDSL
import JobsSwiftBaseDefines
import SnapKit
import GKNavigationBarSwift

public final class JobsLanguageSettingsVC: JobsLanguageBaseVC, UITableViewDataSource, UITableViewDelegate {
    private var language: String?

    public override var learningTitle: String {
        "学习设置"
    }

    public override var showsLearningSettings: Bool {
        false
    }
    private lazy var table = UITableView.make(learningStyle: .insetGrouped)
        .byDataSource(self)
        .byDelegate(self)
        .byRowHeight(56)
        .byBackgroundColor(JobsCor.systemGroupedBackground)

    @discardableResult public func byLanguage(_ value: String?) -> Self {
        language = value
        return self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        table.byAddTo(view) { [unowned self] make in
            make.top.equalTo(gk_navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        language == nil ? 1 : 2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 3 : 4
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "外观" : "点读声音（按语言保存）"
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let labels = ["白天", "黑夜", "跟随系统"]
        var title = ""
        var detail = ""
        var selected = false
        if indexPath.section == 0 {
            title = labels[indexPath.row]
            selected = JobsLanguageAppearance.shared.mode == ["light", "dark", "system"][indexPath.row]
        } else if indexPath.section == 1, let language {
            title = ["语速", "重复次数", "音量", "系统声音"][indexPath.row]
            detail =
                [
                    String(format: "%.2f", JobsLanguageSpeechSettings.rate(language)),
                    "\(JobsLanguageSpeechSettings.repeats(language)) 遍",
                    "\(Int(JobsLanguageSpeechSettings.volume(language) * 100))%", "点击选择"
                ][indexPath.row]
        }
        return UITableViewCell.make(style: .value1)
            .byText(title)
            .bySecondaryText(detail)
            .byTitleCor(JobsCor.label)
            .byDetailTitleCor(JobsCor.secondaryLabel)
            .byAccessoryType(selected ? .checkmark : .none)
            .byBackgroundColor(JobsCor.secondarySystemGroupedBackground)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.byDeselectRow(indexPath)
        if indexPath.section == 0 {
            JobsLanguageAppearance.shared.choose(["light", "dark", "system"][indexPath.row])
            table.byReloadData()
        } else if indexPath.section == 1, let language {
            let titles = ["语速", "重复次数", "音量", "系统声音"]
            var choices: [(String, Any)] = []
            let keys = ["rate", "repeats", "volume", "voice"]
            switch indexPath.row {
            /// 保存三档语速
            case 0: choices = [("慢速", Float(0.35)), ("稍慢", Float(0.45)), ("正常", Float(0.5))]
            /// 每个目标重复一至三遍
            case 1: choices = [("1 遍", 1), ("2 遍", 2), ("3 遍", 3)]
            /// 调整播放音量
            case 2: choices = [("25%", Float(0.25)), ("50%", Float(0.5)), ("75%", Float(0.75)), ("100%", Float(1))]
            /// 只列出同语种声音
            default:
                choices = AVSpeechSynthesisVoice.speechVoices()
                    .filter {
                        $0.language.hasPrefix(String(language.prefix(2)))
                    }
                    .map {
                        ("\($0.name) · \($0.language)", $0.identifier)
                    }
            }
            guard !choices.isEmpty else {
                showMessage("没有对应声音", "请在系统辅助功能朗读设置中下载对应语言声音。")
                return
            }
            let alert = UIAlertController.makeAlert(titles[indexPath.row])
            choices.forEach { label, value in
                alert.byAddAction(title: label) { [weak self] _ in
                    JobsLanguageSpeechSettings.save(value, language: language, name: keys[indexPath.row])
                    self?.table.byReloadData()
                }
            }
            alert.byAddCancel()
                .byPresent(self)
        }
    }
}
