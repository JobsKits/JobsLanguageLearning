//
//  JobsLanguageError.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

public enum JobsLanguageError: LocalizedError {
    case message(String)

    public var errorDescription: String? {
        switch self {
        /// 返回可直接展示的本地错误
        case .message(let text): return text
        }
    }
}
