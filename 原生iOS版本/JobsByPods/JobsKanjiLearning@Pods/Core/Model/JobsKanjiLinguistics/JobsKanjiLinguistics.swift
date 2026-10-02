//
//  JobsKanjiLinguistics.swift
//  JobsKanjiLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation

public enum JobsKanjiLinguistics {

    public static func hiragana(_ text: String) -> String {
        String(
            String.UnicodeScalarView(
                text.unicodeScalars.map { scalar in
                    if (0x30A1...0x30F6).contains(scalar.value), let value = UnicodeScalar(scalar.value - 0x60) {
                        return value
                    }
                    return scalar
                }))
    }

    public static func spoken(_ text: String) -> String {
        hiragana(text.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: ""))
    }
}
