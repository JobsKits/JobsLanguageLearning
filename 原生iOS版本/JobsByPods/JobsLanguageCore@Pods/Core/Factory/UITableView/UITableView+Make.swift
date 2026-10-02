//
//  UITableView+Make.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import UIKit

/// 样式带参构造留在 UI 工厂层，调用方继续使用 Jobs DSL。
public extension UITableView {

    static func make(learningStyle style: UITableView.Style = .insetGrouped) -> UITableView {
        UITableView(frame: .zero, style: style)
    }
}
