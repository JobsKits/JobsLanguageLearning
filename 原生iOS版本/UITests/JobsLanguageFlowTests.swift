//
//  JobsLanguageFlowTests.swift
//  JobsLanguageLearningUITests
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import XCTest
import UIKit

final class JobsLanguageFlowTests: XCTestCase {

    private func swipeBack(_ app: XCUIApplication) {
        let window = app.windows.firstMatch
        let edge = window.coordinate(withNormalizedOffset: CGVector(dx: 0.005, dy: 0.45))
        let destination = window.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.45))
        edge.press(forDuration: 0.05, thenDragTo: destination)
    }

    private func assertHome(_ app: XCUIApplication) {
        XCTAssertTrue(app.staticTexts["31 个字母 · 210 个组合 · 分组与全表点读"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.tables.cells.count, 3)
        XCTAssertFalse(app.buttons["返回"].exists)
    }

    func testEdgeSwipeBackAcrossModulesAndDetails() {
        let app = launch()
        swipeBack(app)
        assertHome(app)

        for index in 0..<3 {
            app.tables.cells.element(boundBy: index).tap()
            let ready = app.buttons[index == 0 ? "切换全表" : "下一页"]
            XCTAssertTrue(ready.waitForExistence(timeout: 10))
            app.buttons["设置"].tap()
            XCTAssertTrue(
                app.tables.cells.containing(.staticText, identifier: "跟随系统").firstMatch.waitForExistence(timeout: 5))
            swipeBack(app)
            XCTAssertTrue(ready.waitForExistence(timeout: 5))

            if index == 0 {
                ready.tap()
                XCTAssertTrue(app.buttons["切换分组"].waitForExistence(timeout: 5))
            } else if index == 1 {
                let cell = app.tables.cells.firstMatch
                XCTAssertTrue(cell.waitForExistence(timeout: 10))
                cell.buttons.element(boundBy: 1).tap()
                XCTAssertTrue(app.staticTexts["例句为词条级收录，原库没有逐义对应关系。"].waitForExistence(timeout: 5))
                swipeBack(app)
                XCTAssertTrue(ready.waitForExistence(timeout: 5))
            } else {
                app.tables.cells.firstMatch.tap()
                XCTAssertTrue(app.staticTexts["音读"].waitForExistence(timeout: 10))
                swipeBack(app)
                XCTAssertTrue(ready.waitForExistence(timeout: 5))
            }
            swipeBack(app)
            assertHome(app)
            capture("手势返回-\(index)-首页", app: app)
        }

        app.tables.cells.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["切换全表"].waitForExistence(timeout: 5))
        swipeBack(app)
        assertHome(app)
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launch(mode: String = "light") -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tables.cells.element(boundBy: 2).waitForExistence(timeout: 10))
        app.buttons["设置"].tap()
        let title = ["light": "白天", "dark": "黑夜", "system": "跟随系统"][mode]!
        app.tables.cells.containing(.staticText, identifier: title).firstMatch.tap()
        app.buttons["返回"].tap()
        XCTAssertTrue(app.tables.cells.element(boundBy: 2).waitForExistence(timeout: 5))
        return app
    }

    private func changeTheme(_ title: String, page: String, app: XCUIApplication) {
        app.buttons["设置"].tap()
        let choice = app.tables.cells.containing(.staticText, identifier: title).firstMatch
        XCTAssertTrue(choice.waitForExistence(timeout: 5))
        choice.tap()
        capture("主题回归-\(page)-\(title)-设置", app: app)
        app.buttons["返回"].tap()
        XCTAssertTrue(app.buttons["设置"].waitForExistence(timeout: 5))
        capture("主题回归-\(page)-\(title)", app: app)
    }

    func testThemeAcrossLoadedModules() {
        let app = launch(mode: "system")
        XCTAssertTrue(app.tables.cells.element(boundBy: 2).waitForExistence(timeout: 10))
        capture("主题回归-首页-跟随系统", app: app)
        changeTheme("黑夜", page: "首页", app: app)
        for (index, page) in ["俄语", "英语", "日语"].enumerated() {
            app.tables.cells.element(boundBy: index).tap()
            let control = app.buttons[index == 0 ? "切换全表" : "下一页"]
            XCTAssertTrue(control.waitForExistence(timeout: 10))
            for mode in ["白天", "黑夜", "跟随系统"] {
                changeTheme(mode, page: page, app: app)
                XCTAssertTrue(control.isHittable)
                if index == 0 {
                    app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "辅音 ")).firstMatch.tap()
                    XCTAssertTrue(app.buttons["关闭"].waitForExistence(timeout: 5))
                    capture("主题回归-俄语辅音选择-\(mode)", app: app)
                    app.buttons["关闭"].tap()
                    control.tap()
                    XCTAssertTrue(app.buttons["切换分组"].waitForExistence(timeout: 5))
                    capture("主题回归-俄语矩阵-\(mode)", app: app)
                    app.buttons["切换分组"].tap()
                }
            }
            if index == 1 {
                let cell = app.tables.cells.firstMatch
                XCTAssertTrue(cell.waitForExistence(timeout: 10))
                cell.buttons.element(boundBy: 1).tap()
                XCTAssertTrue(app.staticTexts["例句为词条级收录，原库没有逐义对应关系。"].waitForExistence(timeout: 5))
                changeTheme("黑夜", page: "英语例句", app: app)
                changeTheme("白天", page: "英语例句", app: app)
                app.buttons["返回"].tap()
            } else if index == 2 {
                let search = app.searchFields.firstMatch
                search.tap()
                search.typeText("生\n")
                let cell = app.tables.cells.containing(.staticText, identifier: "生 · 5 画").firstMatch
                XCTAssertTrue(cell.waitForExistence(timeout: 10))
                cell.tap()
                let guide = app.buttons["生きる / いきる · 活着"]
                for _ in 0..<8 {
                    if guide.isHittable {
                        break
                    }
                    app.scrollViews.firstMatch.swipeUp()
                }
                XCTAssertTrue(guide.isHittable)
                changeTheme("黑夜", page: "日语读法与振假名", app: app)
                changeTheme("白天", page: "日语读法与振假名", app: app)
                app.buttons["返回"].tap()
            }
            app.buttons["返回"].tap()
            XCTAssertEqual(app.tables.cells.count, 3)
        }
    }

    func testRootAndRussianModes() {
        let app = launch()
        XCTAssertTrue(app.tables.cells.element(boundBy: 2).waitForExistence(timeout: 10))
        XCTAssertEqual(app.tables.cells.count, 3)
        XCTAssertTrue(app.staticTexts["31 个字母 · 210 个组合 · 分组与全表点读"].exists)
        capture("首页", app: app)
        app.tables.cells.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["切换全表"].waitForExistence(timeout: 5))
        capture("俄语分组", app: app)
        app.buttons["切换全表"].tap()
        XCTAssertTrue(app.buttons["切换分组"].exists)
        capture("俄语矩阵", app: app)
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeLeft
            let landscape = XCTNSPredicateExpectation(
                predicate: NSPredicate { _, _ in
                    let frame = app.windows.firstMatch.frame
                    return frame.width > frame.height
                }, object: nil)
            XCTAssertEqual(XCTWaiter.wait(for: [landscape], timeout: 10), .completed)
            XCTAssertTrue(app.buttons["下一组"].isHittable)
            XCTAssertGreaterThan(app.buttons["设置"].frame.midX, app.windows.firstMatch.frame.width * 0.85)
            capture("iPad横屏俄语矩阵", app: app)
            XCUIDevice.shared.orientation = .portrait
        }
        app.buttons["切换分组"].tap()
        app.buttons["随机练习"].tap()
        app.buttons["设置"].tap()
        app.tables.cells.containing(.staticText, identifier: "语速").firstMatch.tap()
        app.alerts.buttons["正常"].tap()
        app.tables.cells.containing(.staticText, identifier: "重复次数").firstMatch.tap()
        app.alerts.buttons["3 遍"].tap()
        app.buttons["返回"].tap()
        XCTAssertTrue(app.buttons["语速：正常"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["每项：3 遍"].exists)
    }

    func testEnglishWordAndDetail() {
        let app = launch()
        app.tables.cells.element(boundBy: 1).tap()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("book")
        let cell = app.tables.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        capture("英语词表", app: app)
        cell.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.staticTexts["例句为词条级收录，原库没有逐义对应关系。"].waitForExistence(timeout: 5))
        capture("英语例句", app: app)
    }

    func testKanjiReadingsAndTheme() {
        let app = launch()
        app.tables.cells.element(boundBy: 2).tap()
        XCTAssertTrue(app.tables.cells.firstMatch.waitForExistence(timeout: 10))
        capture("日语字表", app: app)
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("生")
        let cell = app.tables.cells.containing(.staticText, identifier: "生 · 5 画").firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        cell.tap()
        XCTAssertTrue(app.staticTexts["音读"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["训读"].exists)
        capture("日语读法", app: app)
        let guide = app.buttons["生きる / いきる · 活着"]
        for _ in 0..<8 {
            if guide.isHittable {
                break
            }
            app.scrollViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(guide.isHittable)
        capture("日语振假名", app: app)
        let words = app.searchFields.firstMatch
        for _ in 0..<12 {
            if words.isHittable {
                break
            }
            app.scrollViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(words.isHittable)
        words.tap()
        words.typeText("がくせい\n")
        XCTAssertTrue(app.buttons["学生 / がくせい · 点读"].waitForExistence(timeout: 10))
        let detail = app.buttons["查看此读法的词义 / 例句"].firstMatch
        for _ in 0..<4 {
            if detail.isHittable {
                break
            }
            app.scrollViews.firstMatch.swipeUp()
        }
        detail.tap()
        XCTAssertTrue(app.staticTexts["1、词义"].waitForExistence(timeout: 5))
        capture("日语例句", app: app)
        changeTheme("黑夜", page: "日语逐义例句", app: app)
        changeTheme("白天", page: "日语逐义例句", app: app)
        app.buttons["设置"].tap()
        app.tables.cells.containing(.staticText, identifier: "黑夜").firstMatch.tap()
        XCTAssertTrue(app.tables.cells.containing(.staticText, identifier: "跟随系统").firstMatch.exists)
        capture("主题设置", app: app)
    }
}
