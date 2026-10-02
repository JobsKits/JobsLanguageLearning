//
//  NSMutableAttributedString+Make.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

public extension NSMutableAttributedString {

    static func make(learningText text: String) -> NSMutableAttributedString {
        NSMutableAttributedString(string: text)
    }
}
