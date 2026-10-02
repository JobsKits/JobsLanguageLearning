//
//  JobsChineseTranslation.swift
//  JobsLanguageLearningFlutter
//
//  Created by Jobs on 2026年10月2日，星期五.
//

import Cocoa
import FlutterMacOS
import SwiftUI

@MainActor
final class JobsChineseTranslation: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private var pending: FlutterResult?
    private let channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "jobs/chinese_translation", binaryMessenger: messenger)
        super.init()
        channel.setMethodCallHandler { [weak self] call, result in
            guard call.method == "translate", let source = call.arguments as? String else {
                result(FlutterMethodNotImplemented)
                return
            }
            self?.translate(source, result: result)
        }
    }

    private func translate(_ source: String, result: @escaping FlutterResult) {
        guard #available(macOS 15.0, *) else {
            result(FlutterError(code: "unavailable", message: "中文生成需要 macOS 15 或更高版本。", details: nil))
            return
        }
        guard pending == nil else {
            result(FlutterError(code: "busy", message: "已有翻译任务，请完成或关闭翻译窗口后重试。", details: nil))
            return
        }
        pending = result
        let view = JobsTranslationView(source: source) { [weak self] response in
            Task { @MainActor in
                self?.finish(response)
            }
        }
        let window = NSWindow(contentViewController: NSHostingController(rootView: view))
        window.title = "中文辅助翻译"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.delegate = self
        self.window = window
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    private func finish(_ response: Result<String, Error>) {
        guard let result = pending else {
            return
        }
        pending = nil
        window?.close()
        window = nil
        switch response {
        /// 返回系统中文译文。
        case .success(let text):
            result(text)
        /// 下载、取消或系统翻译失败。
        case .failure(let error):
            result(FlutterError(code: "translation", message: error.localizedDescription, details: nil))
        }
    }

    func windowWillClose(_ notification: Notification) {
        guard let result = pending else {
            return
        }
        pending = nil
        window = nil
        result(FlutterError(code: "cancelled", message: "翻译已取消，可以重试。", details: nil))
    }
}
