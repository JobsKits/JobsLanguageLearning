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

    override var learningHelp: String {
        "点击汉字查看音读、训读和名乘，点击词语的读法查看相应词义及红色振假名例句。13,108 字、218,844 词、26,269 不同例句；原库仍有缺读音、缺字义或缺例句。译文是辅助机器译文，尚未全量校对。未缓存的中文需真机首次下载 Apple 翻译语言包。"
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
    private lazy var kanaButton = JobsLanguageLearningStyle.button("元音 · 辅音 · 元音＋辅音", size: 14)
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            showingKana.toggle()
            kanaButton.byTitle(showingKana ? "返回汉字词库" : "元音 · 辅音 · 元音＋辅音")
            search.byHidden(showingKana)
            pages.byHidden(showingKana)
            table.byReloadData()
            if showingKana {
                status.byText("表头元音、左侧辅音、组合均可点读。辅音用代表音节试听；— 无组合。し shi、ち chi、つ tsu、ふ fu；を读 o，ん为鼻音。系统 TTS 非音素录音。")
            } else {
                refresh()
            }
        }
    private let repository = JobsKanjiRepository()
    private var entries: [JobsKanjiSummary] = []
    private var query = ""
    private var group = 0
    private var offset = 0
    private var total = 0
    private var generation = 0
    private var loadTask: Task<Void, Never>?
    private lazy var search =
        UISearchBar.jobsMake { _ in
        }
        .byDelegate(self)
        .byPlaceholder("搜索汉字、假名或中文")
        .byScopeButtonTitles(["全部", "常用", "人名用"])
        .byShowsScopeBar(true)
        .bySearchBarStyle(.minimal)
    private lazy var status = JobsLanguageLearningStyle.label("正在读取字库…", size: 12, secondary: true)
        .byNumberOfLines(0)
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
    private lazy var table = UITableView.make(learningStyle: .insetGrouped)
        .byDelegate(self)
        .byDataSource(self)
        .byRowHeight(UITableView.automaticDimension)
        .byEstimatedRowHeight(90)
        .byKeyboardDismissMode(.onDrag)
        .byBackgroundColor(JobsCor.systemGroupedBackground)

    override func viewDidLoad() {
        super.viewDidLoad()
        kanaButton.byAddTo(view) { [unowned self] make in
            make.top.equalTo(gk_navigationBar.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(40)
        }
        search.byAddTo(view) { [unowned self] make in
            make.top.equalTo(kanaButton.snp.bottom)
            make.left.right.equalToSuperview()

            make.height.equalTo(100)
        }
        status.byAddTo(view) { [unowned self] make in
            make.top.equalTo(search.snp.bottom)
            make.left.right.equalToSuperview().inset(16)
        }
        pages.byAddTo(view) { [unowned self] make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(40)
        }
        table.byAddTo(view) { [unowned self] make in
            make.top.equalTo(status.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(pages.snp.top).offset(-8)
        }
        refresh()
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
                ("元音 \($0.1)\n\($0.0)", String($0.0))
            }
        } else if row == kanaRows.count + 1 {
            sounds = [("ん ン / n · 鼻音", "ん")]
        } else {
            let (consonant, kana, readings) = kanaRows[row - 1]
            sounds.append(("\(consonant) 行\n\(kana.first!)", String(kana.first!)))
            for (index, character) in kana.enumerated() {
                let roman = readings[index]
                let katakana = String(UnicodeScalar(character.unicodeScalars.first!.value + 0x60)!)
                sounds.append(roman.isEmpty ? ("—", "") : ("\(character)\(katakana)\n\(roman)", String(character)))
            }
        }
        for (title, sound) in sounds {
            let button = JobsLanguageLearningStyle.button(title, size: 12)
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
        status.byText("正在查询…")
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
                status.byText(total == 0 ? "没有匹配汉字" : "共 \(total) 字 · \(offset + 1)–\(min(offset + 50, total))")
                previous.byEnabled(offset > 0)
                nextPageButton.byEnabled(offset + 50 < total)
                table.byReloadData()
            } catch {
                if token == generation {
                    status.byText(error.localizedDescription)
                }
            }
        }
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

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        group = selectedScope
        offset = 0
        refresh()
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
