//
//  JobsKanjiLearningVC.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsByUIKit
import JobsSwiftDSL
import JobsSwiftBaseDefines
import JobsLanguageCore
import JobsKanjiLearning
import SnapKit
import GKNavigationBarSwift

final class JobsKanjiLearningVC: JobsLanguageBaseVC, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    override var learningTitle: String {
        "日语汉字点读"
    }

    override var speechLanguage: String? {
        "ja-JP"
    }

    private var showingKana = false
    private let kanaRows: [(String, String, [String])] = [
        ("k", "かきくけこ", ["ka", "ki", "ku", "ke", "ko"]),
        ("s", "さしすせそ", ["sa", "shi", "su", "se", "so"]),
        ("t", "たちつてと", ["ta", "chi", "tsu", "te", "to"]),
        ("n", "なにぬねの", ["na", "ni", "nu", "ne", "no"]),
        ("h", "はひふへほ", ["ha", "hi", "fu", "he", "ho"]),
        ("m", "まみむめも", ["ma", "mi", "mu", "me", "mo"]),
        ("y", "や ゆ よ", ["ya", "", "yu", "", "yo"]),
        ("r", "らりるれろ", ["ra", "ri", "ru", "re", "ro"]),
        ("w", "わ   を", ["wa", "", "", "", "o"]),
        ("g", "がぎぐげご", ["ga", "gi", "gu", "ge", "go"]),
        ("z", "ざじずぜぞ", ["za", "ji", "zu", "ze", "zo"]),
        ("d", "だぢづでど", ["da", "ji", "zu", "de", "do"]),
        ("b", "ばびぶべぼ", ["ba", "bi", "bu", "be", "bo"]),
        ("p", "ぱぴぷぺぽ", ["pa", "pi", "pu", "pe", "po"])
    ]
    private let kanaIPA: [Character: String] = [
        "あ": "a", "い": "i", "う": "ɯ", "え": "e", "お": "o",
        "か": "ka", "き": "ki", "く": "kɯ", "け": "ke", "こ": "ko",
        "さ": "sa", "し": "ɕi", "す": "sɯ", "せ": "se", "そ": "so",
        "た": "ta", "ち": "tɕi", "つ": "tsɯ", "て": "te", "と": "to",
        "な": "na", "に": "ni", "ぬ": "nɯ", "ね": "ne", "の": "no",
        "は": "ha", "ひ": "çi", "ふ": "ɸɯ", "へ": "he", "ほ": "ho",
        "ま": "ma", "み": "mi", "む": "mɯ", "め": "me", "も": "mo",
        "や": "ja", "ゆ": "jɯ", "よ": "jo",
        "ら": "ɾa", "り": "ɾi", "る": "ɾɯ", "れ": "ɾe", "ろ": "ɾo",
        "わ": "wa", "を": "o",
        "が": "ɡa", "ぎ": "ɡi", "ぐ": "ɡɯ", "げ": "ɡe", "ご": "ɡo",
        "ざ": "za", "じ": "dʑi", "ず": "zɯ", "ぜ": "ze", "ぞ": "zo",
        "だ": "da", "ぢ": "dʑi", "づ": "dzɯ", "で": "de", "ど": "do",
        "ば": "ba", "び": "bi", "ぶ": "bɯ", "べ": "be", "ぼ": "bo",
        "ぱ": "pa", "ぴ": "pi", "ぷ": "pɯ", "ぺ": "pe", "ぽ": "po",
        "ん": "ɴ"
    ]
    private lazy var kanaButton = JobsLanguageLearningStyle.button("元音 · 辅音 · 元音＋辅音", size: 14)
        .onTap { [weak self] sender in
            guard let self else {
                return
            }
            showingKana.toggle()
            sender.byTitle(showingKana ? "返回汉字词库" : "元音 · 辅音 · 元音＋辅音")
            gk_navTitleView = showingKana ? nil : searchTitleView
            pages.byHidden(showingKana)
            scopeSelection.byHidden(showingKana)
            tableTopConstraint?.update(offset: showingKana ? -40 : 4)
            tableBottomConstraint?.update(offset: showingKana ? 32 : -8)
            if showingKana {
                setSectionStatus("元音 · 辅音 · 罗马字 · IPA 均可点读")
            } else {
                refresh()
            }
            table.byReloadData()
        }
    private let repository = JobsKanjiRepository()
    private var entries: [JobsKanjiSummary] = []
    private var query = ""
    private var group = 0
    private var sectionStatus = "正在读取字库…"
    private var offset = 0
    private var total = 0
    private var generation = 0
    private var tableTopConstraint: Constraint?
    private var tableBottomConstraint: Constraint?
    private var loadTask: Task<Void, Never>?
    private lazy var search =
        UISearchBar.jobsMake { _ in
        }
        .byDelegate(self)
        .byPlaceholder("搜索汉字、假名或中文")
        .bySearchBarStyle(.minimal)
    private lazy var scopeButtons: [UIButton] = ["全部", "常用", "人名用"].enumerated().map { index, title in
        JobsLanguageLearningStyle.button(title, size: 13)
            .onTap { [weak self] _ in
                guard let self else {
                    return
                }
                group = index
                for (buttonIndex, button) in scopeButtons.enumerated() {
                    JobsLanguageLearningStyle.paint(button, selected: buttonIndex == group)
                }
                offset = 0
                refresh()
            }
    }
    private lazy var scopeSelection = UIStackView.jobsMake { _ in
    }
    .byAxis(.horizontal)
    .bySpacing(8)
    .byDistribution(.fillEqually)
    .byAddArrangedSubview(scopeButtons[0])
    .byAddArrangedSubview(scopeButtons[1])
    .byAddArrangedSubview(scopeButtons[2])
    private lazy var dismissKeyboardTap = UITapGestureRecognizer
        .byConfig { [weak self] _ in
            self?.view.jobsDismissKeyboard()
        }
        .byCancelsTouchesInView(false)
        .byDelaysTouchesBegan(false)
        .byDelaysTouchesEnded(false)
    private lazy var previous = JobsLanguageLearningStyle.button("上一页", size: 14)
        .onTap { [weak self] _ in
            self?.turn(-1)
        }
    private lazy var nextPageButton = JobsLanguageLearningStyle.button("下一页", size: 14)
        .onTap { [weak self] _ in
            self?.turn(1)
        }
    private lazy var pages =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.horizontal)
        .bySpacing(8)
        .byDistribution(.fillEqually)
        .byAddArrangedSubview(previous)
        .byAddArrangedSubview(nextPageButton)
    private lazy var table = UITableView.make(learningStyle: .plain)
        .byDelegate(self)
        .byDataSource(self)
        .byRowHeight(UITableView.automaticDimension)
        .byEstimatedRowHeight(90)
        .bySectionHeaderHeight(44)
        .byEstimatedSectionHeaderHeight(44)
        .byNoSectionHeaderTopPadding()
        .byKeyboardDismissMode(.onDrag)
        .byBackgroundColor(JobsCor.systemGroupedBackground)

    override func viewDidLoad() {
        super.viewDidLoad()
        gk_navTitleView = searchTitleView
        fitSearchBarToNavigationTitle()
        kanaButton.byAddTo(view) { [unowned self] make in
            make.top.equalTo(gk_navigationBar.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(40)
        }
        for (index, button) in scopeButtons.enumerated() {
            JobsLanguageLearningStyle.paint(button, selected: index == group)
        }
        scopeSelection.byAddTo(view) { [unowned self] make in
            make.top.equalTo(kanaButton.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(36)
        }
        pages.byAddTo(view) { [unowned self] make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(40)
        }
        table.byAddTo(view) { [unowned self] make in
            tableTopConstraint = make.top.equalTo(scopeSelection.snp.bottom).offset(4).constraint
            make.left.right.equalToSuperview()
            tableBottomConstraint = make.bottom.equalTo(pages.snp.top).offset(-8).constraint
        }
        view.jobs_addGestureRetView(dismissKeyboardTap)
        refresh()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fitSearchBarToNavigationTitle()
    }

    /// 导航栏管理外层尺寸，内部约束保持搜索框上移位置。
    private lazy var searchTitleView = UIView.jobsMake { [unowned self] container in
        search.byAddTo(container) { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview().offset(-6)
            make.height.equalTo(44)
        }
    }

    private func fitSearchBarToNavigationTitle() {
        searchTitleView.byFrame(
            CGRect(
                x: 0,
                y: 0,
                width: max(150, view.bounds.width - 136),
                height: 44
            )
        )
    }

    private func kanaCell(_ row: Int) -> UITableViewCell {
        let cell = UITableViewCell.make(style: .default)
            .bySelectionStyle(.none)
            .byBackgroundColor(JobsCor.secondarySystemGroupedBackground)
        let stack = UIStackView.jobsMake { _ in
        }
        .byAxis(.horizontal)
        .bySpacing(3)
        .byDistribution(.fillEqually)
        .byAddTo(cell.contentView) { make in
            make.edges.equalToSuperview().inset(6)
            make.height.greaterThanOrEqualTo(50)
        }
        var sounds: [(String, String)] = []
        if row == 0 {
            sounds = [("辅 / 元", "")] + zip(Array("あいうえお"), ["a", "i", "u", "e", "o"]).map {
                ("\($0.0)\n\($0.1) /\(kanaIPA[$0.0] ?? "")/", String($0.0))
            }
        } else if row == kanaRows.count + 1 {
            sounds = [("ん ン\nn /ɴ/", "ん")]
        } else {
            let (consonant, kana, readings) = kanaRows[row - 1]
            sounds.append(("\(consonant) 行\n\(kana.first!) /\(kanaIPA[kana.first!] ?? "")/", String(kana.first!)))
            for (index, character) in kana.enumerated() {
                let roman = readings[index]
                let katakana = String(UnicodeScalar(character.unicodeScalars.first!.value + 0x60)!)
                sounds.append(roman.isEmpty
                    ? ("—", "")
                    : ("\(character)\(katakana)\n\(roman) /\(kanaIPA[character] ?? "")/", String(character)))
            }
        }
        for (title, sound) in sounds {
            let button = JobsLanguageLearningStyle.button(title, size: 9)
                .byNumberOfLines(2)
                .byEnabled(!sound.isEmpty)
                .onTap { [weak self] _ in
                    self?.speak(sound, language: "ja-JP")
                }
            stack.byAddArrangedSubview(button)
        }
        return cell
    }

    private func refresh() {
        generation += 1
        let token = generation
        let query = query
        let group = group
        let offset = offset
        setSectionStatus("正在查询…")
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else {
                return
            }
            do {
                let page = try await repository.page(query: query, group: group, offset: offset)
                guard !Task.isCancelled, token == generation else {
                    return
                }
                entries = page.entries
                total = page.total
                guard !showingKana else {
                    return
                }
                setSectionStatus(total == 0 ? "没有匹配汉字" : "共 \(total) 字 · \(offset + 1)–\(min(offset + 50, total))")
                previous.byEnabled(offset > 0)
                nextPageButton.byEnabled(offset + 50 < total)
                table.byReloadData()
            } catch {
                if token == generation {
                    setSectionStatus(error.localizedDescription)
                }
            }
        }
    }

    private func setSectionStatus(_ value: String) {
        sectionStatus = value
        table.byReloadData()
    }

    private func turn(_ delta: Int) {
        offset = max(0, offset + delta * 50)
        refresh()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        offset = 0
        refresh()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionStatus
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showingKana ? kanaRows.count + 2 : entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showingKana {
            return kanaCell(indexPath.row)
        }
        let item = entries[indexPath.row]
        return UITableViewCell.make(style: .subtitle)
            .byText("\(item.literal) · \(item.strokes) 画")
            .bySecondaryText(item.chinese)
            .byTitleFont(JobsFont.systemFont(ofSize: 24, weight: .semibold))
            .byDetailTitleNumberOfLines(0)
            .byTitleCor(JobsCor.label)
            .byDetailTitleCor(JobsCor.secondaryLabel)
            .byAccessoryType(.disclosureIndicator)
            .byBackgroundColor(JobsCor.secondarySystemGroupedBackground)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !showingKana else {
            return
        }
        table.byDeselectRow(indexPath)
        push(
            JobsKanjiDetailVC.jobsMake { _ in
            }
            .bySummary(entries[indexPath.row]))
    }
}
