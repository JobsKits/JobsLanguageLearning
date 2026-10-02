//
//  JobsKanjiExample.swift
//  JobsKanjiLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

public struct JobsKanjiExample: Decodable, Sendable {
    public let jp: String
    public let en: String
    public let tokens: [[String]]
    public let source: String
    public let form: String?
}
