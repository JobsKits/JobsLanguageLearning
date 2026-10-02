//
//  JobsKanjiGuide.swift
//  JobsKanjiLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

public struct JobsKanjiGuide: Decodable, Sendable {
    public let meaning: String
    public let examples: [Example]
    public struct Example: Decodable, Sendable {
        public let word: String
        public let reading: String
        public let meaning: String
        public let tokens: [[String]]
        public let zh: String
    }
}
