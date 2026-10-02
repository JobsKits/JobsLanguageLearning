//
//  JobsKanjiWord.swift
//  JobsKanjiLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

public struct JobsKanjiWord: Decodable, Sendable {
    public let spellings: [String]
    public let readings: [JobsKanjiReading]
    public let senses: [JobsKanjiSense]

    public func validSpellings(literal: String, reading: JobsKanjiReading) -> [String] {
        spellings.filter {
            $0.contains(literal) && (reading.restr?.isEmpty != false || reading.restr?.contains($0) == true)
        }
    }

    public func allowedSenses(spelling: String, reading: String) -> [JobsKanjiSense] {
        senses.filter {
            ($0.stagk.isEmpty || $0.stagk.contains(spelling)) && ($0.stagr.isEmpty || $0.stagr.contains(reading))
        }
    }
}
