//
//  JobsKanjiEntry.swift
//  JobsKanjiLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

public struct JobsKanjiEntry: Decodable, Sendable {
    public let literal: String
    public let readings: [JobsKanjiReading]
    public let nanori: [String]
    public let meanings: [String]
}
