//
//  MainFlutterWindow.swift
//  JobsLanguageLearningFlutter
//
//  Created by Jobs on 2026年10月2日，星期五.
//

import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var chineseTranslation: JobsChineseTranslation?
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    chineseTranslation = JobsChineseTranslation(messenger: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }
}
