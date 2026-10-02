//
//  JobsLanguageBaseVC.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsByUIKit
import JobsSwiftDSL
import JobsSwiftBaseDefines
import GKNavigationBarSwift

open class JobsLanguageBaseVC: UIViewController {

    open var learningTitle: String {
        "语言学习"
    }

    open var learningHelp: String {
        "选择一个学习工具；点按文字试听，使用右上角设置调整外观与声音。"
    }

    open var speechLanguage: String? {
        nil
    }

    open var showsLearningSettings: Bool {
        true
    }
    public private(set) lazy var speech =
        JobsLanguageSpeechPlayer.jobsMake { _ in
        }
        .byOnError { [weak self] message in
            self?.showMessage("声音不可用", message)
        }
    private lazy var menuButton = JobsLanguageLearningStyle.button("设置", size: 15)
        .byContentEdgeInsets(.zero)
        .onTap { [weak self] _ in
            self?.showSettings()
        }
    private lazy var emptyBackButton = UIButton.sys()
        .byHidden(true)

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.byBackgroundColor(JobsCor.systemGroupedBackground)
        let rootButton = navigationController?.viewControllers.first === self ? emptyBackButton : nil
        jobsSetupGKNav(
            title: learningTitle, leftButton: rootButton, rightButtons: showsLearningSettings ? [menuButton] : nil)
        if navigationController?.viewControllers.first === self {
            byLearningHideRootBackItem()
        } else {
            byLearningBackAccessibility("返回")
        }
        byLearningObserveAppearance {
            JobsLanguageAppearance.shared.systemDidChange()
        }
        NotificationCenter.default.addObserver(
            self, selector: #selector(stopSpeech), name: UIApplication.willResignActiveNotification, object: nil)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let navigationController else {
            return
        }
        // 自定义导航栏后恢复系统侧滑；根页面保持禁用。
        navigationController.interactivePopGestureRecognizer?
            .byDelegate(nil)
            .byEnabled(navigationController.viewControllers.count > 1)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        speech.stop()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        byLearningFitNavigationBar()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func stopSpeech() {
        speech.stop()
    }

    public func showMessage(_ title: String, _ message: String) {
        UIAlertController.makeAlert(title, message)
            .byAddCancel("知道了")
            .byPresent(self)
    }

    public func push(_ controller: UIViewController) {
        navigationController?.pushViewControllerByAnimated(controller)
    }

    public func speak(_ text: String, language: String) {
        speech.play([text], language: language)
    }

    private func showSettings() {
        speech.stop()
        let controller =
            JobsLanguageSettingsVC.jobsMake { _ in
            }
            .byLanguage(speechLanguage)
            .byHelp(learningHelp)
        push(controller)
    }
}
