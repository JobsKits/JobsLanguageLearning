//
//  NSAttributedString+Make.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

public extension NSAttributedString {

    static func make(learningText text: String, learningAttributes attributes: [NSAttributedString.Key: Any])
        -> NSAttributedString
    {
        NSAttributedString(string: text, attributes: attributes)
    }
}
