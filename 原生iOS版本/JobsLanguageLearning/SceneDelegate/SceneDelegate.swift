//
//  SceneDelegate.swift
//  JobsLanguageLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit
import JobsByUIKit
import JobsSwiftDSL
import JobsLanguageCore

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private lazy var navigation =
        UINavigationController.jobsMake { _ in
        }
        .byViewControllers([
            JobsLanguageHomeVC.jobsMake { _ in
            }
        ])

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        window = UIWindow.jobsMake(scene: windowScene, root: navigation, makeKeyVisible: false)
        if let window {
            JobsLanguageAppearance.shared.attach(window)
            window.byMakeKeyAndVisible()
        }
    }
}
