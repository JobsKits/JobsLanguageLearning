//
//  JobsEnglishLearningVC.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsByUIKit
import JobsSwiftDSL
import JobsSwiftBaseDefines
import JobsLanguageCore
import JobsEnglishLearning
import SnapKit
import GKNavigationBarSwift

final class JobsEnglishLearningVC: JobsLanguageBaseVC, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    override var learningTitle: String {
        "分级英语词本"
    }

    override var speechLanguage: String? {
        "en-US"
    }

    private let repository = JobsEnglishRepository()
    private var levels: [JobsEnglishLevel] = []
    private var words: [JobsEnglishWord] = []
    private var level = UserDefaults.standard.string(forKey: "JobsEnglish.level") ?? "junior"
    private var letter = ""
    private var query = ""
    private var offset = 0
    private var total = 0
    private var generation = 0
    private var loadTask: Task<Void, Never>?
    private lazy var levelButton = JobsLanguageLearningStyle.button("初中 ▾")
        .onTap { [weak self] _ in
            self?.chooseLevel()
        }
    private lazy var letterButton = JobsLanguageLearningStyle.button("全部字母 ▾")
        .onTap { [weak self] _ in
            self?.chooseLetter()
        }
    private lazy var filters =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.horizontal)
        .bySpacing(8)
        .byDistribution(.fillEqually)
        .byAddArrangedSubview(levelButton)
        .byAddArrangedSubview(letterButton)
    private lazy var search =
        UISearchBar.jobsMake { _ in
        }
        .byDelegate(self)
        .byPlaceholder("搜索单词或中文释义")
        .bySearchBarStyle(.minimal)
    private lazy var dismissKeyboardTap = UITapGestureRecognizer
        .byConfig { [weak self] _ in
            self?.view.jobsDismissKeyboard()
        }
        .byCancelsTouchesInView(false)
        .byDelaysTouchesBegan(false)
        .byDelaysTouchesEnded(false)
    private lazy var status = JobsLanguageLearningStyle.label("正在读取离线词库…", size: 12, secondary: true)
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
        .byDistribution(.fillEqually)
        .bySpacing(8)
        .byAddArrangedSubview(previous)
        .byAddArrangedSubview(nextPageButton)
    private lazy var table = UITableView.make(learningStyle: .plain)
        .byDataSource(self)
        .byDelegate(self)
        .byRegisterCell(JobsEnglishWordCell.self)
        .byRowHeight(UITableView.automaticDimension)
        .byEstimatedRowHeight(150)
        .byKeyboardDismissMode(.onDrag)
        .byBackgroundColor(JobsCor.systemGroupedBackground)

    override func viewDidLoad() {
        super.viewDidLoad()
        gk_navTitleView = searchTitleView
        fitSearchBarToNavigationTitle()
        filters.byAddTo(view) { [unowned self] make in
            make.top.equalTo(gk_navigationBar.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(42)
        }
        status.byAddTo(view) { [unowned self] make in
            make.top.equalTo(filters.snp.bottom).offset(8)
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
        view.jobs_addGestureRetView(dismissKeyboardTap)
        Task { [weak self] in
            guard let self else {
                return
            }
            do {
                levels = try await repository.levels()
                if !levels.contains(where: {
                    $0.id == self.level
                }) {
                    level = levels.first?.id ?? "junior"
                }
                refresh()
            } catch {
                status.byText(error.localizedDescription)
            }
        }
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

    private func refresh() {
        generation += 1
        let token = generation
        let level = level
        let letter = letter
        let query = query
        let offset = offset
        levelButton.byTitle(
            (levels.first {
                $0.id == level
            }?
            .name ?? level) + " ▾")
        letterButton.byTitle(letter.isEmpty ? "全部字母 ▾" : "\(letter) ▾")
        status.byText("正在查询…")
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else {
                return
            }
            do {
                let page = try await repository.page(level: level, letter: letter, query: query, offset: offset)
                guard !Task.isCancelled, token == generation else {
                    return
                }
                words = page.words
                total = page.total
                status.byText(total == 0 ? "没有匹配词条" : "共 \(total) 词 · \(offset + 1)–\(min(offset + 40, total))")
                previous.byEnabled(offset > 0)
                nextPageButton.byEnabled(offset + 40 < total)
                table.byReloadData()
            } catch {
                if token == generation {
                    status.byText(error.localizedDescription)
                }
            }
        }
    }

    private func turn(_ delta: Int) {
        offset = max(0, offset + delta * 40)
        refresh()
    }

    private func chooseLevel() {
        let alert = UIAlertController.makeAlert("学习级别", "雅思档位为自定义词频学习分级")
        levels.forEach { item in
            alert.byAddAction(title: item.name) { [weak self] _ in
                guard let self else {
                    return
                }
                level = item.id
                offset = 0
                UserDefaults.standard.set(level, forKey: "JobsEnglish.level")
                refresh()
            }
        }
        alert.byAddCancel()
            .byPresent(self)
    }

    private func chooseLetter() {
        let alert = UIAlertController.makeAlert("字母分区")
        ([""] + Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map(String.init))
            .forEach { item in
                alert.byAddAction(title: item.isEmpty ? "全部" : item) { [weak self] _ in
                    guard let self else {
                        return
                    }
                    letter = item
                    offset = 0
                    refresh()
                }
            }
        alert.byAddCancel()
            .byPresent(self)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        offset = 0
        refresh()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        words.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobsEnglishWordCell", for: indexPath)
                as? JobsEnglishWordCell
        else {
            return UITableViewCell.make()
        }
        return
            cell
            .byOnRead { [weak self] text in
                self?.speak(text, language: "en-US")
            }
            .byOnDetail { [weak self] word, sense in
                self?
                    .push(
                        JobsEnglishWordDetailVC.jobsMake { _ in
                        }
                        .byWord(word, sense: sense))
            }
            .byWord(words[indexPath.row])
    }
}
