//
//  JobsLanguageRepositoryTests.swift
//  JobsLanguageLearningTests
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import XCTest
import UIKit
import JobsByUIKit
import JobsSwiftDSL
import JobsSwiftBaseDefines
import JobsLanguageCore
@testable import JobsLanguageLearning
@testable import JobsRussianLearning
@testable import JobsEnglishLearning
@testable import JobsKanjiLearning

final class JobsLanguageRepositoryTests: XCTestCase {

    @MainActor func testButtonsRefreshBackgroundAndTextTogether() {
        let appearance = JobsLanguageAppearance.shared
        let initialMode = appearance.mode
        defer {
            appearance.choose(initialMode)
        }
        appearance.choose("light")
        let titles = ["上一页", "下一页", "切换全表", "本组连读", "查看例句", "生成 / 重试中文译文"]
        let buttons = titles.map {
            JobsLanguageLearningStyle.button($0)
        }
        buttons[0].byEnabled(false)
        let uncommon = JobsLanguageLearningStyle.button("йа·")
        JobsLanguageLearningStyle.paint(uncommon, selected: false, uncommon: true)
        let selected = JobsLanguageLearningStyle.button("ба")
        JobsLanguageLearningStyle.paint(selected, selected: true)

        for mode in ["dark", "light", "dark"] {
            appearance.choose(mode)
            for (button, title) in zip(buttons, titles) {
                button.byUpdateConfig()
                XCTAssertEqual(button.configuration?.title, title)
                assertColor(
                    button.configuration?.background.backgroundColor,
                    equals: JobsThemeCenter.shared.resolvedColor(.backgroundGroupedSecondary))
                assertColor(
                    button.configuration?.baseForegroundColor,
                    equals: JobsThemeCenter.shared.resolvedColor(button.isEnabled ? .textPrimary : .textSecondary))
            }
            assertColor(
                uncommon.configuration?.background.backgroundColor,
                equals: JobsThemeCenter.shared.resolvedColor(.backgroundGroupedTertiary))
            assertColor(selected.configuration?.background.backgroundColor, equals: JobsCor.systemBlue)
            assertColor(selected.configuration?.baseForegroundColor, equals: JobsCor.white)
        }
        JobsLanguageLearningStyle.paint(selected, selected: false)
        appearance.choose("light")
        assertColor(
            selected.configuration?.background.backgroundColor,
            equals: JobsThemeCenter.shared.resolvedColor(.backgroundGroupedSecondary))
        assertColor(
            selected.configuration?.baseForegroundColor, equals: JobsThemeCenter.shared.resolvedColor(.textPrimary))
    }

    @MainActor func testRubyTextRefreshesBeforeWindowAttachment() {
        let appearance = JobsLanguageAppearance.shared
        let initialMode = appearance.mode
        defer {
            appearance.choose(initialMode)
        }
        appearance.choose("light")
        let text =
            JobsKanjiRubyText.jobsMake { _ in
            }
            .byTokens([["生", "せい"]])
        let originalTrait = text.traitCollection.userInterfaceStyle
        for mode in ["dark", "light"] {
            appearance.choose(mode)
            XCTAssertNil(text.window)
            XCTAssertEqual(text.traitCollection.userInterfaceStyle, originalTrait)
            let color = text.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
            assertColor(color, equals: JobsThemeCenter.shared.resolvedColor(.textPrimary))
        }
    }

    @MainActor private func assertColor(
        _ actual: UIColor?, equals expected: UIColor, file: StaticString = #filePath, line: UInt = #line
    ) {
        guard let actual else {
            XCTFail("缺少颜色", file: file, line: line)
            return
        }
        var actualRed: CGFloat = 0
        var actualGreen: CGFloat = 0
        var actualBlue: CGFloat = 0
        var actualAlpha: CGFloat = 0
        var expectedRed: CGFloat = 0
        var expectedGreen: CGFloat = 0
        var expectedBlue: CGFloat = 0
        var expectedAlpha: CGFloat = 0
        XCTAssertTrue(
            actual.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha), file: file,
            line: line)
        XCTAssertTrue(
            expected.getRed(&expectedRed, green: &expectedGreen, blue: &expectedBlue, alpha: &expectedAlpha),
            file: file, line: line)
        for (value, expectedValue) in zip(
            [actualRed, actualGreen, actualBlue, actualAlpha], [expectedRed, expectedGreen, expectedBlue, expectedAlpha]
        ) {
            XCTAssertEqual(value, expectedValue, accuracy: 0.001, file: file, line: line)
        }
    }

    func testRussianMatrixAndSpellingHints() {
        XCTAssertEqual(JobsRussianLesson.consonants.count, 21)
        XCTAssertEqual(JobsRussianLesson.vowels.count, 10)
        XCTAssertEqual(
            Set(
                JobsRussianLesson.consonants.flatMap { c in
                    JobsRussianLesson.vowels.map {
                        c + $0
                    }
                }
            )
            .count, 210)
        XCTAssertTrue(JobsRussianLesson.isUncommon("й", "а"))
        XCTAssertFalse(JobsRussianLesson.isUncommon("б", "а"))
    }

    func testEnglishRealCatalogAndPagination() async throws {
        let repository = JobsEnglishRepository()
        let levels = try await repository.levels()
        XCTAssertEqual(levels.count, 12)
        let first = try await repository.page(level: "junior", letter: "", query: "", offset: 0)
        let second = try await repository.page(level: "junior", letter: "", query: "", offset: 40)
        XCTAssertEqual(first.total, 1418)
        XCTAssertEqual(first.words.count, 40)
        XCTAssertTrue(Set(first.words.map(\.id)).isDisjoint(with: Set(second.words.map(\.id))))
        let search = try await repository.page(level: "junior", letter: "B", query: "book", offset: 0)
        XCTAssertGreaterThan(search.total, 0)
        XCTAssertTrue(
            search.words.allSatisfy {
                $0.word.uppercased().hasPrefix("B")
            })
        let percent = try await repository.page(level: "junior", letter: "", query: "%", offset: 0)
        XCTAssertEqual(percent.total, 0)
    }

    func testKanjiRealCatalogAndChineseSearch() async throws {
        let repository = JobsKanjiRepository()
        let page = try await repository.page(query: "", group: 0, offset: 0)
        XCTAssertEqual(page.total, 13108)
        XCTAssertEqual(page.entries.count, 50)
        let chinese = try await repository.page(query: "山", group: 0, offset: 0)
        XCTAssertGreaterThan(chinese.total, 0)
        let entry = try await repository.entry("生")
        XCTAssertTrue(
            entry.readings.contains {
                $0.text == "セイ"
            })
        let guide = try await repository.guide("生")
        XCTAssertFalse(guide?.examples.isEmpty ?? true)
        let words = try await repository.words("生", query: "がくせい", offset: 0)
        XCTAssertGreaterThan(words.total, 0)
        XCTAssertTrue(
            words.words.contains {
                $0.spellings.contains("学生")
            })
    }

    func testReadingAndSenseRestrictions() throws {
        let source = """
            {"spellings":["生","性"],"readings":[{"text":"せい","restr":["性"],"no_kanji":false,"info":[]}],"senses":[{"pos":[],"stagk":["性"],"stagr":["せい"],"gloss":["nature"],"info":[],"examples":[]}]}
            """
        let word = try JobsSQLiteDatabase.decode(JobsKanjiWord.self, source)
        XCTAssertEqual(word.validSpellings(literal: "生", reading: word.readings[0]), [])
        XCTAssertEqual(word.allowedSenses(spelling: "生", reading: "せい").count, 0)
        XCTAssertEqual(word.allowedSenses(spelling: "性", reading: "せい").count, 1)
        XCTAssertEqual(JobsKanjiLinguistics.spoken("おこな.う"), "おこなう")
        XCTAssertEqual(JobsKanjiLinguistics.hiragana("ガクセイ"), "がくせい")
    }
}
