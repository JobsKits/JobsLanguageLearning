//
//  JobsKanjiReading.swift
//  JobsKanjiLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

public struct JobsKanjiReading: Decodable, Sendable {
    public let text: String
    public let restr: [String]?
    public let no_kanji: Bool?
    public let info: [String]?
    public let type: String?
    public let status: String?
    public let on_type: String?
}
