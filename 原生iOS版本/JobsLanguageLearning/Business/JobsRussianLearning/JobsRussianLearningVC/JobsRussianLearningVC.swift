//
//  JobsRussianLearningVC.swift
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
import GKNavigationBarSwift

final class JobsRussianLearningVC: JobsLanguageBaseVC {

    override var learningTitle: String {
        "俄语拼读"
    }

    override var speechLanguage: String? {
        "ru-RU"
    }

    override var learningHelp: String {
        "元音、辅音、210 个组合都可点读；分组与全表可切换。· 表示少见拼写。系统 TTS 不是专业音素录音，单个辅音可能读字母名称。ъ、ь 是符号，不列入辅音。"
    }
    private var consonantIndex = 0
    private var currentText = "ба"
    private var isTable = false
    private var isReading = false
    private var rate = JobsLanguageSpeechSettings.rate("ru-RU")
    private var repeats = JobsLanguageSpeechSettings.repeats("ru-RU")

    private var consonant: String {
        JobsRussianLesson.consonants[consonantIndex]
    }
    private lazy var player = JobsLanguageSpeechPlayer.jobsMake {
        $0.onStart = { [weak self] text in
            guard let self else {
                return
            }
            currentText = text
            status.byText("正在朗读：\(text)")
            refresh()
        }
        $0.onFinish = { [weak self] in
            guard let self else {
                return
            }
            isReading = false
            status.byText("朗读完成 · 点击即可再听")
            refreshPlaybackControls()
        }
        $0.onError = { [weak self] message in
            guard let self else {
                return
            }
            isReading = false
            status.byText("无法朗读 · 请检查系统声音")
            refreshPlaybackControls()
            showMessage("声音不可用", message)
        }
    }
    private lazy var modeButton: UIButton = JobsLanguageLearningStyle.button("切换全表")
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            isTable.toggle()
            refresh()
        }
    private lazy var previousButton: UIButton = JobsLanguageLearningStyle.button("上一组", size: 14)
        .onTap { [weak self] _ in
            self?.move(-1)
        }
    private lazy var nextButton: UIButton = JobsLanguageLearningStyle.button("下一组", size: 14)
        .onTap { [weak self] _ in
            self?.move(1)
        }
    private lazy var selectButton: UIButton = JobsLanguageLearningStyle.button("选择辅音 б", size: 18)
        .onTap { [weak self] _ in
            self?.chooseConsonant()
        }
    private lazy var consonantButton: UIButton = JobsLanguageLearningStyle.button("单读 б")
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            read([consonant])
        }
    private lazy var rowButton: UIButton = JobsLanguageLearningStyle.button("本组连读")
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            if isReading {
                stop()
            } else {
                read(
                    JobsRussianLesson.vowels.map {
                        self.consonant + $0
                    })
            }
        }
    private lazy var speedButton: UIButton = JobsLanguageLearningStyle.button("语速：慢速", size: 14)
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            rate = rate < 0.4 ? 0.45 : rate < 0.5 ? 0.5 : 0.35
            JobsLanguageSpeechSettings.save(rate, language: "ru-RU", name: "rate")
            stop()
            refresh()
        }
    private lazy var repeatButton: UIButton = JobsLanguageLearningStyle.button("每项：1 遍", size: 14)
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            repeats = repeats % 3 + 1
            JobsLanguageSpeechSettings.save(repeats, language: "ru-RU", name: "repeats")
            stop()
            repeatButton.byTitle("每项：\(repeats) 遍")
        }
    private lazy var helpButton: UIButton = JobsLanguageLearningStyle.button("学习说明", size: 14)
        .onTap { [weak self] _ in
            self?
                .showMessage(
                    "俄语点读",
                    "卡片左侧读元音，右侧读组合。全表的上下表头也能点读。\n\n· 标记不常见或非标准拼写组合，仅作探索。系统合成声音不等同于专业语音教材；单独辅音可能读成字母名称。ъ、ь 是符号，不列为辅音。\n\n本页按课程数据、播放控制、界面拆分，后续语种可复用播放器。"
                )
        }
    private lazy var instruction =
        UILabel.jobsMake {
            JobsLanguageLearningStyle.bindText($0, key: .textSecondary)
        }
        .byText("左侧元音、右侧组合均可点读 · 辅音可单读")
        .byFont(JobsFont.systemFont(ofSize: 13))
        .byNumberOfLines(0)
    private lazy var status =
        UILabel.jobsMake {
            JobsLanguageLearningStyle.bindText($0, key: .textPrimary)
        }
        .byText("点击字母或组合开始试听")
        .byFont(JobsFont.systemFont(ofSize: 16, weight: .semibold))
        .byNumberOfLines(0)
    private lazy var hint =
        UILabel.jobsMake {
            JobsLanguageLearningStyle.bindText($0, key: .textSecondary)
        }
        .byFont(JobsFont.systemFont(ofSize: 12))
        .byNumberOfLines(0)
    private lazy var controls =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.vertical)
        .bySpacing(8)
    private lazy var selection =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.horizontal)
        .bySpacing(6)
        .byDistribution(.fillEqually)
    private lazy var modes =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.horizontal)
        .bySpacing(8)
        .byDistribution(.fillEqually)
    private lazy var actions =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.horizontal)
        .bySpacing(8)
        .byDistribution(.fillEqually)
    private lazy var options =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.horizontal)
        .bySpacing(8)
        .byDistribution(.fillEqually)
    private lazy var practice =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.horizontal)
        .bySpacing(8)
        .byDistribution(.fillEqually)
    private lazy var randomButton = JobsLanguageLearningStyle.button("随机练习", size: 14)
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            let all = JobsRussianLesson.consonants.flatMap { c in
                JobsRussianLesson.vowels
                    .filter {
                        !JobsRussianLesson.isUncommon(c, $0)
                    }
                    .map {
                        c + $0
                    }
            }
            if let text = all.randomElement() {
                read([text])
            }
        }
    private lazy var replayButton = JobsLanguageLearningStyle.button("重听 / 停止", size: 14)
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            if isReading {
                stop()
            } else {
                read([currentText])
            }
        }
    private lazy var footer =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.vertical)
        .bySpacing(8)
    private lazy var groupScroll =
        UIScrollView.jobsMake { _ in
        }
        .byShowsVerticalScrollIndicator(false)
    private lazy var grid =
        UIStackView.jobsMake { _ in
        }
        .byAxis(.vertical)
        .bySpacing(8)
    private lazy var pairs = JobsRussianLesson.vowels.map { _ in
        JobsRussianPairView.jobsMake { view in
            view.onRead = { [weak self] text in
                self?.read([text])
            }
        }
    }
    private lazy var rows: [UIStackView] = (0..<5)
        .map { index in
            UIStackView.jobsMake { _ in
            }
            .byAxis(.horizontal)
            .bySpacing(8)
            .byDistribution(.fillEqually)
            .byAddArrangedSubview(pairs[index * 2])
            .byAddArrangedSubview(pairs[index * 2 + 1])
        }
    private lazy var table = JobsRussianTableView.jobsMake { view in
        view.onRead = { [weak self] text in
            guard let self else {
                return
            }
            if let first = text.first, let index = JobsRussianLesson.consonants.firstIndex(of: String(first)) {
                consonantIndex = index
            }
            read([text])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.byBackgroundColor(JobsCor.systemGroupedBackground)
        selection.byAddArrangedSubview(selectButton)
        [previousButton, modeButton, nextButton]
            .forEach {
                modes.byAddArrangedSubview($0)
            }
        [selection, instruction]
            .forEach {
                controls.byAddArrangedSubview($0)
            }
        [consonantButton, rowButton]
            .forEach {
                actions.byAddArrangedSubview($0)
            }
        [speedButton, repeatButton]
            .forEach {
                options.byAddArrangedSubview($0)
            }
        practice.byAddArrangedSubview(randomButton)
            .byAddArrangedSubview(replayButton)
        [status, hint, modes, actions, options, practice]
            .forEach {
                footer.byAddArrangedSubview($0)
            }
        [selection, modes, actions, options, practice]
            .forEach {
                $0.snp.makeConstraints {
                    $0.height.equalTo(44)
                }
            }
        controls.byAddTo(view) { [unowned self] make in
            make.top.equalTo(gk_navigationBar.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
        }
        footer.byAddTo(view) { [unowned self] make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
        groupScroll.byAddTo(view) { [unowned self] make in
            make.top.equalTo(controls.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(footer.snp.top).offset(-12)
        }
        grid.byAddTo(groupScroll) { [unowned self] make in
            make.edges.equalTo(groupScroll.contentLayoutGuide)
            make.width.equalTo(groupScroll.frameLayoutGuide)
        }
        rows.forEach { row in
            grid.byAddArrangedSubview(row)
            row.snp.makeConstraints {
                $0.height.equalTo(62)
            }
        }
        table.byAddTo(view) { [unowned self] make in
            make.edges.equalTo(groupScroll)
        }
        NotificationCenter.default.addObserver(
            self, selector: #selector(stop), name: UIApplication.willResignActiveNotification, object: nil)
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rate = JobsLanguageSpeechSettings.rate("ru-RU")
        repeats = JobsLanguageSpeechSettings.repeats("ru-RU")
        refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func refresh() {
        speedButton.byTitle(rate < 0.4 ? "语速：慢速" : rate < 0.5 ? "语速：稍慢" : "语速：正常")
        repeatButton.byTitle("每项：\(repeats) 遍")
        selectButton.byTitle("辅音 \(consonant) ▾")
        consonantButton.byTitle("单读 \(consonant)")
        modeButton.byTitle(isTable ? "切换分组" : "切换全表")
        groupScroll.byHidden(isTable)
        table.byHidden(!isTable)
            .byHighlight(currentText)
        for (index, pair) in pairs.enumerated() {
            pair.configure(consonant: consonant, vowel: JobsRussianLesson.vowels[index], current: currentText)
        }
        hint.byText(JobsRussianLesson.hint(for: currentText))
        refreshPlaybackControls()
    }

    private func refreshPlaybackControls() {
        JobsLanguageLearningStyle.paint(consonantButton, selected: currentText == consonant)
        rowButton.byTitle(isReading ? "停止" : "本组连读")
        JobsLanguageLearningStyle.paint(rowButton, selected: isReading)
        replayButton.byTitle(isReading ? "停止朗读" : "重听当前")
    }

    private func move(_ delta: Int) {
        stop()
        consonantIndex =
            (consonantIndex + delta + JobsRussianLesson.consonants.count) % JobsRussianLesson.consonants.count
        currentText = consonant + "а"
        refresh()
    }

    private func read(_ texts: [String]) {
        guard let first = texts.first else {
            return
        }
        currentText = first
        isReading = true
        status.byText("准备朗读：\(first)")
        refresh()
        player.play(texts, language: JobsRussianLesson.language, rate: rate, repeats: repeats)
    }

    @objc private func stop() {
        player.stop()
        isReading = false
        refreshPlaybackControls()
        status.byText("已停止 · 点击即可试听")
    }

    private func chooseConsonant() {
        stop()
        let picker =
            JobsRussianConsonantPickerVC.jobsMake { _ in
            }
            .bySelectedConsonant(consonant)
            .byOnSelect { [weak self] letter in
                guard let self, let index = JobsRussianLesson.consonants.firstIndex(of: letter) else {
                    return
                }
                consonantIndex = index
                currentText = consonant + "а"
                refresh()
            }
            .byModalPresentationStyle(.pageSheet)
        present(picker, animated: true)
    }
}
