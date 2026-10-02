//
//  JobsKanjiSense.swift
//  JobsKanjiLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

public struct JobsKanjiSense: Decodable, Sendable {
    public let pos: [String]
    public let stagk: [String]
    public let stagr: [String]
    public let gloss: [String]
    public let info: [String]
    public let examples: [JobsKanjiExample]
}
