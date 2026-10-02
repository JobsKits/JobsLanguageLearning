//
//  JobsEnglishWord.swift
//  JobsEnglishLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

public struct JobsEnglishWord: Sendable {
    public let id: Int
    public let word: String
    public let phonetic: String
    public let senses: [JobsEnglishSense]
    public let examples: [JobsEnglishExample]
    public let phrases: [JobsEnglishPhrase]
}
