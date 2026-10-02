//
//  Bundle+Make.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

extension Bundle {

    static func make(learningOwner owner: AnyClass) -> Bundle {
        Bundle(for: owner)
    }

    static func make(learningURL url: URL) -> Bundle? {
        Bundle(url: url)
    }
}
