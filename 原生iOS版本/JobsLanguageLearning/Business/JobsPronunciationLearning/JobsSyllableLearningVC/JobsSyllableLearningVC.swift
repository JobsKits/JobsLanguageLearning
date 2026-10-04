//
//  JobsSyllableLearningVC.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月3日，星期六.
//

import UIKit
import JobsByUIKit
import JobsLanguageCore
import JobsFrenchLearning
import JobsSpanishLearning
import JobsKoreanLearning
import JobsSwiftDSL
import JobsSwiftBaseDefines
import SnapKit

final class JobsSyllableLearningVC: JobsLanguageBaseVC {

    private var course = JobsFrenchLesson.course
    private var consonantIndex = 0
    private var coda = ""
    private var currentText = ""
    private var isMatrix = false
    private var isReading = false

    @discardableResult
    func byCourse(_ value: JobsLanguageSyllableCourse) -> Self {
        course = value
        currentText = value.syllable(consonant: value.consonants[0], vowel: value.vowels[0]) ?? ""
        return self
    }

    override var learningTitle: String {
        course.title
    }

    override var speechLanguage: String? {
        course.language
    }

    override var learningHelp: String {
        course.notice
    }

    private var usesLargeScript: Bool {
        true
    }

    private lazy var instruction = JobsLanguageLearningStyle.label(
        course.isHangul
            ? "点按元音、声母或韩文音节组合即可试听"
            : "点按元音、辅音或拼读组合即可试听",
        size: 13,
        secondary: true
    )
    private lazy var status = JobsLanguageLearningStyle.label("点击字母或组合开始试听", size: 16)
    private lazy var hint = JobsLanguageLearningStyle.label(course.notice, size: 12, secondary: true)

    private lazy var previousButton = JobsLanguageLearningStyle.button("上一组", size: 14)
        .onTap { [weak self] _ in
            self?.move(-1)
        }
    private lazy var nextButton = JobsLanguageLearningStyle.button("下一组", size: 14)
        .onTap { [weak self] _ in
            self?.move(1)
        }
    private lazy var selectButton = JobsLanguageLearningStyle.button(
        course.isHangul ? "选择声母" : "选择辅音",
        size: usesLargeScript ? 20 : 16
    )
        .onTap { [weak self] _ in
            self?.chooseConsonant()
        }
    private lazy var codaButton = JobsLanguageLearningStyle.button("无收音", size: 14)
        .onTap { [weak self] _ in
            self?.chooseCoda()
        }
    private lazy var modeButton = JobsLanguageLearningStyle.button("切换全表", size: 14)
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            isMatrix.toggle()
            refresh()
        }
    private lazy var rowButton = JobsLanguageLearningStyle.button("本组连读", size: 14)
        .onTap { [weak self] _ in
            self?.readRow()
        }
    private lazy var randomButton = JobsLanguageLearningStyle.button("随机练习", size: 14)
        .onTap { [weak self] _ in
            self?.readRandom()
        }
    private lazy var replayButton = JobsLanguageLearningStyle.button("重听当前", size: 14)
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            if isReading {
                stop()
            } else if !currentText.isEmpty {
                read([currentText])
            }
        }
    private lazy var helpButton = JobsLanguageLearningStyle.button("学习说明", size: 14)
        .onTap { [weak self] _ in
            guard let self else {
                return
            }
            showMessage(
                "\(course.title)点读",
                course.notice + "\n\n系统 TTS 仅供试听，不等同于专业音素录音。"
            )
        }

    private lazy var selection = UIStackView.jobsMake { _ in
    }
    .byAxis(.horizontal)
    .bySpacing(6)
    .byDistribution(.fillEqually)
    private lazy var modes = UIStackView.jobsMake { _ in
    }
    .byAxis(.horizontal)
    .bySpacing(8)
    .byDistribution(.fillEqually)
    private lazy var actions = UIStackView.jobsMake { _ in
    }
    .byAxis(.horizontal)
    .bySpacing(8)
    .byDistribution(.fillEqually)
    private lazy var controls = UIStackView.jobsMake { _ in
    }
    .byAxis(.vertical)
    .bySpacing(8)
    private lazy var footer = UIStackView.jobsMake { _ in
    }
    .byAxis(.vertical)
    .bySpacing(8)
    private lazy var scroll = UIScrollView.jobsMake { _ in
    }
    .byShowsHorizontalScrollIndicator(false)
    private lazy var grid = UIStackView.jobsMake { _ in
    }
    .byAxis(.vertical)
    .bySpacing(4)
    private lazy var vowelButtons = course.vowels.map { vowel in
        pronunciationButton(
            course.displayVowel(vowel),
            annotation: course.pronunciationHint(forVowel: vowel)
        )
            .onTap { [weak self] _ in
                guard let self else {
                    return
                }
                self.read([self.course.speechText(forVowel: vowel)])
            }
    }
    private lazy var onsetButtons = course.consonants.enumerated().map { index, consonant in
        pronunciationButton(
            consonant,
            annotation: course.pronunciationHint(forConsonant: consonant)
        )
            .onTap { [weak self] _ in
                guard let self else {
                    return
                }
                self.consonantIndex = index
                if let syllable = self.course.syllable(
                    consonant: consonant,
                    vowel: self.course.vowels[0],
                    coda: self.coda
                ) {
                    self.currentText = syllable
                }
                self.refresh()
                self.read([consonant])
            }
    }
    private lazy var syllableButtons = course.consonants.map { consonant in
        course.vowels.map { vowel in
            let syllable = course.syllable(consonant: consonant, vowel: vowel, coda: coda)
            let title = syllable.map { $0 + (course.isUncommon(consonant) ? "·" : "") } ?? "—"
            let annotation = syllable.map { _ in
                course.pronunciationHint(consonant: consonant, vowel: vowel, coda: coda)
            }
            return pronunciationButton(title, annotation: annotation)
                .byEnabled(syllable != nil)
                .onTap { [weak self] _ in
                    self?.readCell(consonant: consonant, vowel: vowel)
                }
        }
    }
    private lazy var vowelHeader = makeHeader()
    private lazy var rows = course.consonants.enumerated().map { index, _ in
        makeRow(index: index)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.byBackgroundColor(JobsCor.systemGroupedBackground)
        speech.byOnStart { [weak self] text in
            guard let self else {
                return
            }
            currentText = text
            isReading = true
            status.byText("正在朗读：\(text)")
            refresh()
        }
        .byOnFinish { [weak self] in
            guard let self else {
                return
            }
            isReading = false
            status.byText("朗读完成 · 点击即可再听")
            refreshPlaybackControls()
        }
        selection.byAddArrangedSubview(selectButton)
        selection.byAddArrangedSubview(codaButton)
        [previousButton, modeButton, nextButton]
            .forEach { modes.byAddArrangedSubview($0) }
        [rowButton, randomButton, replayButton]
            .forEach { actions.byAddArrangedSubview($0) }
        [selection, instruction, modes, actions]
            .forEach { controls.byAddArrangedSubview($0) }
        [selection, modes, actions]
            .forEach {
                $0.snp.makeConstraints {
                    $0.height.equalTo(44)
                }
            }
        [status, hint, helpButton]
            .forEach { footer.byAddArrangedSubview($0) }
        controls.byAddTo(view) { [unowned self] make in
            make.top.equalTo(gk_navigationBar.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
        }
        footer.byAddTo(view) { [unowned self] make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
        }
        scroll.byAddTo(view) { [unowned self] make in
            make.top.equalTo(controls.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(footer.snp.top).offset(-12)
        }
        grid.byAddTo(scroll) { [unowned self] make in
            make.edges.equalTo(scroll.contentLayoutGuide)
            make.width.equalTo(max(360, 62 + CGFloat(course.vowels.count) * 76))
        }
        grid.byAddArrangedSubview(vowelHeader)
        vowelHeader.snp.makeConstraints {
            $0.height.equalTo(usesLargeScript ? 60 : 48)
        }
        rows.forEach { row in
            grid.byAddArrangedSubview(row)
            row.snp.makeConstraints {
                $0.height.equalTo(usesLargeScript ? 60 : 50)
            }
        }
        codaButton.byHidden(course.codas.isEmpty)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stop),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        refresh()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func makeHeader() -> UIStackView {
        let header = UIStackView.jobsMake { _ in
        }
        .byAxis(.horizontal)
        .bySpacing(4)
        .byDistribution(.fill)
        .byAddArrangedSubview(
            JobsLanguageLearningStyle.label(
                course.isHangul ? "声 / 元" : "辅 / 元",
                size: 11,
                secondary: true
            )
        )
        for button in vowelButtons {
            header.byAddArrangedSubview(button)
            button.snp.makeConstraints {
                $0.width.equalTo(72)
            }
        }
        header.arrangedSubviews.first?.snp.makeConstraints {
            $0.width.equalTo(58)
        }
        return header
    }

    private func makeRow(index: Int) -> UIStackView {
        let row = UIStackView.jobsMake { _ in
        }
        .byAxis(.horizontal)
        .bySpacing(4)
        .byDistribution(.fill)
        .byAddArrangedSubview(onsetButtons[index])
        onsetButtons[index].snp.makeConstraints {
            $0.width.equalTo(58)
        }
        for button in syllableButtons[index] {
            row.byAddArrangedSubview(button)
            button.snp.makeConstraints {
                $0.width.equalTo(72)
            }
        }
        return row
    }

    private func refresh() {
        selectButton.byTitle("\(course.isHangul ? "声母" : "辅音") \(course.consonants[consonantIndex]) ▾")
        modeButton.byTitle(isMatrix ? "切换分组" : "切换全表")
        codaButton.byTitle(coda.isEmpty ? "无收音 ▾" : "收音 \(coda) ▾")
        scroll.byScrollEnabled(true)
        for (index, row) in rows.enumerated() {
            row.byHidden(!isMatrix && index != consonantIndex)
            paintCourseButton(onsetButtons[index], selected: index == consonantIndex)
            for (column, button) in syllableButtons[index].enumerated() {
                let vowel = course.vowels[column]
                let syllable = course.syllable(
                    consonant: course.consonants[index],
                    vowel: vowel,
                    coda: coda
                )
                button.byTitle(syllable.map { $0 + (course.isUncommon(course.consonants[index]) ? "·" : "") } ?? "—")
                button.byEnabled(syllable != nil)
                paintCourseButton(
                    button,
                    selected: syllable == currentText,
                    uncommon: course.isUncommon(course.consonants[index])
                )
            }
        }
        hint.byText(course.notice)
        refreshPlaybackControls()
    }

    private func pronunciationButton(_ title: String, annotation: String?) -> UIButton {
        let size: CGFloat
        if course.isHangul || course.language == "ar-SA" {
            size = 26
        } else if title.count <= 2 {
            size = 26
        } else if title.count == 3 {
            size = 22
        } else {
            size = 18
        }
        let button = JobsLanguageLearningStyle.button(title, size: size)
            .byNumberOfLines(2)
        guard let annotation else {
            return button
        }
        return button
            .bySubTitle(annotation)
            .bySubTitleFont(JobsFont.systemFont(ofSize: 11))
            .bySubTitleColor(JobsCor.secondaryLabel)
    }

    private func paintCourseButton(_ button: UIButton, selected: Bool, uncommon: Bool = false) {
        JobsLanguageLearningStyle.paint(button, selected: selected, uncommon: uncommon)
        button.bySubTitleColor(selected ? JobsCor.white : JobsCor.secondaryLabel)
    }

    private func refreshPlaybackControls() {
        rowButton.byTitle(isReading ? "停止" : "本组连读")
        JobsLanguageLearningStyle.paint(rowButton, selected: isReading)
        replayButton.byTitle(isReading ? "停止朗读" : "重听当前")
    }

    private func readCell(consonant: String, vowel: String) {
        guard let syllable = course.syllable(consonant: consonant, vowel: vowel, coda: coda),
              let index = course.consonants.firstIndex(of: consonant) else {
            return
        }
        consonantIndex = index
        currentText = syllable
        refresh()
        read([syllable])
    }

    private func readRow() {
        let consonant = course.consonants[consonantIndex]
        let syllables = course.vowels.compactMap {
            course.syllable(consonant: consonant, vowel: $0, coda: coda)
        }
        read(syllables)
    }

    private func readRandom() {
        let choices = course.consonants.flatMap { consonant in
            course.vowels.compactMap { vowel -> (String, String)? in
                guard let syllable = course.syllable(consonant: consonant, vowel: vowel, coda: coda),
                      !course.isUncommon(consonant) else {
                    return nil
                }
                return (consonant, syllable)
            }
        }
        guard let choice = choices.randomElement(),
              let index = course.consonants.firstIndex(of: choice.0) else {
            return
        }
        consonantIndex = index
        currentText = choice.1
        refresh()
        read([choice.1])
    }

    private func move(_ delta: Int) {
        stop()
        consonantIndex = (consonantIndex + delta + course.consonants.count) % course.consonants.count
        currentText = course.syllable(
            consonant: course.consonants[consonantIndex],
            vowel: course.vowels[0],
            coda: coda
        ) ?? ""
        refresh()
    }

    private func chooseConsonant() {
        choose(
            title: "选择辅音 / 声母",
            values: course.consonants,
            selected: course.consonants[consonantIndex]
        ) { [weak self] value in
            guard let self, let index = course.consonants.firstIndex(of: value) else {
                return
            }
            consonantIndex = index
            currentText = course.syllable(consonant: value, vowel: course.vowels[0], coda: coda) ?? ""
            refresh()
        }
    }

    private func chooseCoda() {
        guard !course.codas.isEmpty else {
            return
        }
        choose(title: "选择收音", values: course.codas, selected: coda) { [weak self] value in
            guard let self else {
                return
            }
            coda = value
            currentText = course.syllable(
                consonant: course.consonants[consonantIndex],
                vowel: course.vowels[0],
                coda: value
            ) ?? ""
            refresh()
        }
    }

    private func choose(
        title: String,
        values: [String],
        selected: String,
        onSelect: @escaping (String) -> Void
    ) {
        stop()
        let picker = JobsLanguageSyllablePickerVC.jobsMake { _ in
        }
        .byValues(values)
        .bySelectedValue(selected)
        .byPickerTitle(title)
        .byOnSelect(onSelect)
        .byModalPresentationStyle(.pageSheet)
        present(picker, animated: true)
    }

    private func read(_ texts: [String]) {
        guard let first = texts.first else {
            return
        }
        currentText = first
        isReading = true
        status.byText("准备朗读：\(first)")
        refresh()
        speech.play(texts, language: course.language)
    }

    @objc private func stop() {
        speech.stop()
        isReading = false
        refreshPlaybackControls()
        status.byText("已停止 · 点击即可试听")
    }
}
