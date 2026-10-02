//
//  JobsKanjiDetailVC.swift
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

final class JobsKanjiDetailVC: JobsLanguageBaseVC, UISearchBarDelegate {
    private var summary: JobsKanjiSummary?

    override var learningTitle: String {
        summary?.literal ?? "汉字详情"
    }

    override var speechLanguage: String? {
        "ja-JP"
    }
    private let repository = JobsKanjiRepository()
    private var wordQuery = ""
    private var offset = 0
    private var total = 0
    private var generation = 0
    private var buttons: [UIButton] = []
    private var labels: [UILabel] = []
    private var rubies: [JobsKanjiRubyText] = []
    private var wordButtons: [UIButton] = []
    private var wordLabels: [UILabel] = []
    private var readingRows: [UIStackView] = []
    private lazy var translator = JobsKanjiChineseTranslator()
    private lazy var translationHost = JobsKanjiTranslationHost.make(translator: translator)
    private lazy var translationStatus = JobsLanguageLearningStyle.label(
        "中文译文为学习辅助，尚未全量人工校对。", size: 12, secondary: true)
    private lazy var translationButton = JobsLanguageLearningStyle.button("生成 / 重试中文译文", size: 14)
        .onTap { [weak self] _ in
            self?.translator.request()
        }
    private lazy var scroll =
        UIScrollView.jobsMake { _ in
        }
        .byKeyboardDismissMode(.onDrag)
    private lazy var content =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.vertical)
        .bySpacing(14)
    private lazy var wordContainer =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.vertical)
        .bySpacing(10)
    private lazy var wordSearch =
        UISearchBar.jobsMake { _ in
        }
        .byDelegate(self)
        .byPlaceholder("在关联词语中搜索，如 がくせい")
        .bySearchBarStyle(.minimal)
    private lazy var wordStatus = JobsLanguageLearningStyle.label(size: 12, secondary: true)
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

    @discardableResult func bySummary(_ value: JobsKanjiSummary) -> Self {
        summary = value
        return self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scroll.byAddTo(view) { [unowned self] make in
            make.top.equalTo(gk_navigationBar.snp.bottom)
            make.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        content.byAddTo(scroll) { [unowned self] make in
            make.edges.equalTo(scroll.contentLayoutGuide).inset(16)
            make.width.equalTo(scroll.frameLayoutGuide).offset(-32)
        }
        translator.onStatus = { [weak self] value in
            self?.translationStatus.byText(value)
        }
        byKanjiTranslationHost(translationHost)
        translationHost.view.byAddTo(view) { make in
            make.left.bottom.equalToSuperview()
            make.width.height.equalTo(1)
        }
        guard let summary else {
            return
        }
        addLabel(summary.literal, size: 64)
        addLabel("\(summary.strokes) 画 · \(summary.chinese)")
        addLabel("「.」后是送假名，「-」表示接续位置；播放时读完整假名。单字读音不能自动套到任意词语。", size: 12, secondary: true)
        Task { [weak self] in
            guard let self else {
                return
            }
            do {
                let entry = try await repository.entry(summary.literal)
                addReadings(
                    "音读",
                    values: entry.readings
                        .filter {
                            $0.type == "ja_on"
                        }
                        .map(\.text))
                addReadings(
                    "训读",
                    values: entry.readings
                        .filter {
                            $0.type == "ja_kun"
                        }
                        .map(\.text))
                addReadings("名乘（人名读法）", values: entry.nanori)
                if let guide = try await repository.guide(summary.literal) {
                    addLabel("中文学习提示：\(guide.meaning)")
                    for example in guide.examples {
                        addReadButton(
                            "\(example.word) / \(example.reading) · \(example.meaning)", reading: example.reading)
                        addRuby(example.tokens)
                        addLabel(example.zh, secondary: true)
                    }
                }
                content.byAddArrangedSubview(translationStatus)
                    .byAddArrangedSubview(translationButton)
                    .byAddArrangedSubview(wordSearch)
                    .byAddArrangedSubview(wordStatus)
                    .byAddArrangedSubview(wordContainer)
                    .byAddArrangedSubview(pages)
                wordSearch.snp.makeConstraints {
                    $0.height.equalTo(52)
                }
                pages.snp.makeConstraints {
                    $0.height.equalTo(44)
                }
                refreshWords()
            } catch {
                showMessage("字库读取失败", error.localizedDescription)
            }
        }
    }

    private func addReadings(_ title: String, values: [String]) {
        addLabel(title, size: 18)
        let unique = values.reduce(into: [String]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
        if unique.isEmpty {
            addLabel("原字库未收录", size: 13, secondary: true)
        }
        for start in stride(from: 0, to: unique.count, by: 3) {
            let row =
                UIStackView.jobsMake { _ in
                }
                .byAxis(.horizontal)
                .bySpacing(8)
                .byDistribution(.fillEqually)
            readingRows.append(row)
            content.byAddArrangedSubview(row)
            for value in unique[start..<min(start + 3, unique.count)] {
                let button = JobsLanguageLearningStyle.button(value, size: 15)
                    .byNumberOfLines(0)
                    .onTap { [weak self] _ in
                        self?.speak(JobsKanjiLinguistics.spoken(value), language: "ja-JP")
                    }
                buttons.append(button)
                row.byAddArrangedSubview(button)
            }
            row.snp.makeConstraints {
                $0.height.greaterThanOrEqualTo(44)
            }
        }
    }

    private func addLabel(_ text: String, size: CGFloat = 15, secondary: Bool = false) {
        let label = JobsLanguageLearningStyle.label(text, size: size, secondary: secondary)
        labels.append(label)
        content.byAddArrangedSubview(label)
    }

    private func addReadButton(_ title: String, reading: String) {
        let button = JobsLanguageLearningStyle.button(title)
            .byNumberOfLines(0)
            .byContentHorizontalAlignment(.leading)
            .onTap { [weak self] _ in
                self?.speak(JobsKanjiLinguistics.spoken(reading), language: "ja-JP")
            }
        buttons.append(button)
        content.byAddArrangedSubview(button)
    }

    private func addRuby(_ tokens: [[String]]) {
        let ruby =
            JobsKanjiRubyText.jobsMake { _ in
            }
            .byTokens(tokens)
            .byOnRead { [weak self] text in
                self?.speak(text, language: "ja-JP")
            }
        rubies.append(ruby)
        content.byAddArrangedSubview(ruby)
    }

    private func refreshWords() {
        guard let literal = summary?.literal else {
            return
        }
        generation += 1
        let token = generation
        let query = wordQuery
        let offset = offset
        Task { [weak self] in
            guard let self else {
                return
            }
            do {
                let page = try await repository.words(literal, query: query, offset: offset)
                guard token == generation else {
                    return
                }
                total = page.total
                for button in wordButtons {
                    button.byRemoveFromSuperview()
                }
                for label in wordLabels {
                    label.byRemoveFromSuperview()
                }
                wordButtons.removeAll()
                wordLabels.removeAll()
                wordStatus.byText(
                    total == 0 ? "原词库没有匹配词语" : "关联词语：\(total) 条 · \(offset + 1)–\(min(offset + 15, total))")
                for word in page.words {
                    for reading in word.readings where reading.no_kanji != true {
                        for spelling in word.validSpellings(literal: literal, reading: reading) {
                            let read = JobsLanguageLearningStyle.button("\(spelling) / \(reading.text) · 点读", size: 16)
                                .byNumberOfLines(0)
                                .byContentHorizontalAlignment(.leading)
                                .onTap { [weak self] _ in
                                    self?.speak(JobsKanjiLinguistics.spoken(reading.text), language: "ja-JP")
                                }
                            let detail = JobsLanguageLearningStyle.button("查看此读法的词义 / 例句", size: 14)
                                .onTap { [weak self] _ in
                                    self?
                                        .push(
                                            JobsKanjiWordDetailVC.jobsMake { _ in
                                            }
                                            .byWord(word, spelling: spelling, reading: reading.text))
                                }
                            wordButtons += [read, detail]
                            wordContainer.byAddArrangedSubview(read)
                                .byAddArrangedSubview(detail)
                        }
                    }
                    if let sense = word.senses.first {
                        let label = JobsLanguageLearningStyle.label(size: 13, secondary: true)
                        wordLabels.append(label)
                        wordContainer.byAddArrangedSubview(label)
                        translator.bind(label, source: sense.gloss.joined(separator: "; "))
                    }
                }
                previous.byEnabled(offset > 0)
                nextPageButton.byEnabled(offset + 15 < total)
            } catch {
                if token == generation {
                    wordStatus.byText(error.localizedDescription)
                }
            }
        }
    }

    private func turn(_ delta: Int) {
        offset = max(0, offset + delta * 15)
        refreshWords()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        wordQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        offset = 0
        refreshWords()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
