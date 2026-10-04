//
//  JobsLanguageSyllableCourse.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月3日，星期六.
//

import Foundation

public enum JobsLanguageSyllableFormat: Equatable {
    case alphabetic
    case hangul
}

public struct JobsLanguageSyllableCourse {
    public let title: String
    public let language: String
    public let vowels: [String]
    public let consonants: [String]
    public let codas: [String]
    public let notice: String
    private let format: JobsLanguageSyllableFormat
    private let unavailableCombinations: Set<String>
    private let uncommonConsonants: Set<String>
    private let syllableOverrides: [String: String]

    public init(
        title: String,
        language: String,
        vowels: [String],
        consonants: [String],
        codas: [String] = [],
        notice: String,
        format: JobsLanguageSyllableFormat = .alphabetic,
        unavailableCombinations: Set<String> = [],
        uncommonConsonants: Set<String> = [],
        syllableOverrides: [String: String] = [:]
    ) {
        self.title = title
        self.language = language
        self.vowels = vowels
        self.consonants = consonants
        self.codas = codas
        self.notice = notice
        self.format = format
        self.unavailableCombinations = unavailableCombinations
        self.uncommonConsonants = uncommonConsonants
        self.syllableOverrides = syllableOverrides
    }

    public var isHangul: Bool {
        format == .hangul
    }

    public func displayVowel(_ vowel: String) -> String {
        language == "ar-SA" ? "◌" + vowel : vowel
    }

    public func speechText(forVowel vowel: String) -> String {
        guard language == "ar-SA" else {
            return vowel
        }
        return "ء" + vowel
    }

    public func syllable(consonant: String, vowel: String, coda: String = "") -> String? {
        let key = "\(consonant)|\(vowel)"
        guard !unavailableCombinations.contains(key) else {
            return nil
        }
        if format == .alphabetic {
            return syllableOverrides[key] ?? "\(consonant)\(vowel)"
        }
        guard
            let initial = Self.hangulInitials.firstIndex(of: consonant),
            let medial = Self.hangulVowels.firstIndex(of: vowel),
            let final = Self.hangulFinals.firstIndex(of: coda)
        else {
            return nil
        }
        let value = UInt32(0xAC00 + ((initial * 21 + medial) * 28) + final)
        guard let scalar = UnicodeScalar(value) else {
            return nil
        }
        return String(scalar)
    }

    public func isUncommon(_ consonant: String) -> Bool {
        uncommonConsonants.contains(consonant)
    }

    public func pronunciationHint(forVowel vowel: String) -> String {
        if language == "ar-SA" {
            return "\(Self.arabicRomanVowels[vowel] ?? vowel) /\(Self.arabicIPAVowels[vowel] ?? vowel)/"
        }
        if isHangul {
            return "\(Self.koreanRomanVowels[vowel] ?? vowel) /\(Self.koreanIPAVowels[vowel] ?? vowel)/"
        }
        if language == "ru-RU" {
            return "\(Self.russianRomanVowels[vowel] ?? vowel) /\(Self.russianIPAVowels[vowel] ?? vowel)/"
        }
        if language == "fr-FR" {
            return "/\(Self.frenchIPAVowels[vowel] ?? vowel)/"
        }
        if language == "es-ES" {
            return "/\(Self.spanishIPAVowels[vowel] ?? vowel)/"
        }
        if language == "de-DE" {
            return "\(vowel) /\(Self.germanIPAVowels[vowel] ?? vowel)/"
        }
        return vowel
    }

    public func pronunciationHint(forConsonant consonant: String, vowel: String? = nil) -> String {
        if language == "ar-SA" {
            let roman = Self.arabicRomanConsonants[consonant] ?? consonant
            let ipa = Self.arabicIPAConsonants[consonant] ?? consonant
            return "\(roman) /\(ipa)/"
        }
        if isHangul {
            let roman = Self.koreanRomanInitials[consonant] ?? consonant
            let ipa = Self.koreanIPAInitials[consonant] ?? consonant
            return roman.isEmpty ? "不发音 /∅/" : "\(roman) /\(ipa)/"
        }
        if language == "ru-RU" {
            let roman = Self.russianRomanConsonants[consonant] ?? consonant
            let ipa = Self.russianIPAConsonants[consonant] ?? consonant
            return "\(roman) /\(ipa)/"
        }
        if language == "fr-FR" {
            switch consonant {
            case "c": return "/k~s/"
            case "g": return "/ɡ~ʒ/"
            case "h": return "不发音 /∅/"
            case "q": return "/k/"
            case "ch": return "/ʃ/"
            case "gn": return "/ɲ/"
            case "ph": return "/f/"
            case "r": return "/ʁ/"
            case "w": return "/w~v/"
            case "x": return "/ks/"
            default: return "/\(Self.frenchIPAConsonants[consonant] ?? consonant)/"
            }
        }
        if language == "es-ES" {
            switch consonant {
            case "c": return "/k~θ/"
            case "g": return "/ɡ~x/"
            case "h": return "不发音 /∅/"
            case "q": return "/k/"
            case "r": return "词首颤音 /r/"
            case "v": return "/b/"
            case "ch": return "/tʃ/"
            case "j": return "/x/"
            case "x": return "/ks/"
            case "y", "ll": return "/ʝ/"
            case "z": return "/θ/"
            default: return "/\(Self.spanishIPAConsonants[consonant] ?? consonant)/"
            }
        }
        if language == "de-DE" {
            return "/\(Self.germanIPAConsonants[consonant] ?? consonant)/"
        }
        return consonant
    }

    public func pronunciationHint(consonant: String, vowel: String, coda: String = "") -> String {
        if language == "ar-SA" {
            let roman = (Self.arabicRomanConsonants[consonant] ?? consonant)
                + (Self.arabicRomanVowels[vowel] ?? vowel)
            let ipa = (Self.arabicIPAConsonants[consonant] ?? consonant)
                + (Self.arabicIPAVowels[vowel] ?? vowel)
            return "\(roman) /\(ipa)/"
        }
        if isHangul {
            let romanInitial = Self.koreanRomanInitials[consonant] ?? consonant
            let romanVowel = Self.koreanRomanVowels[vowel] ?? vowel
            let romanCoda = Self.koreanRomanCodas[coda] ?? coda
            let ipaInitial = Self.koreanIPAInitials[consonant] ?? consonant
            let ipaVowel = Self.koreanIPAVowels[vowel] ?? vowel
            let ipaCoda = Self.koreanIPACodas[coda] ?? ""
            let roman = romanInitial + romanVowel + romanCoda
            let ipa = ipaInitial + ipaVowel + ipaCoda
            return "\(roman.isEmpty ? "∅" : roman) /\(ipa.isEmpty ? "∅" : ipa)/"
        }
        if language == "ru-RU" {
            let roman = (Self.russianRomanConsonants[consonant] ?? consonant)
                + (Self.russianRomanVowels[vowel] ?? vowel)
            var ipaInitial = Self.russianIPAConsonants[consonant] ?? consonant
            if "яёюеи".contains(vowel), !"жшцйчщ".contains(consonant) {
                ipaInitial += "ʲ"
            }
            let ipaVowel = "жшц".contains(consonant) && vowel == "и"
                ? "ɨ"
                : Self.russianIPAVowels[vowel] ?? vowel
            return "\(roman) /\(ipaInitial)\(ipaVowel)/"
        }
        if language == "fr-FR" {
            let initial: String
            switch consonant {
            case "c": initial = "eiy".contains(vowel) ? "s" : "k"
            case "g": initial = "eiy".contains(vowel) ? "ʒ" : "ɡ"
            case "ch": initial = "ʃ"
            case "gn": initial = "ɲ"
            case "ph": initial = "f"
            case "h": initial = ""
            case "j": initial = "ʒ"
            case "q": initial = "k"
            case "r": initial = "ʁ"
            case "w": initial = "w~v"
            case "x": initial = "ks"
            default: initial = Self.frenchIPAConsonants[consonant] ?? consonant
            }
            let vowelIPA = consonant == "q" && vowel == "e"
                ? "ə"
                : Self.frenchIPAVowels[vowel] ?? vowel
            return "/\(initial)\(vowelIPA)/"
        }
        if language == "es-ES" {
            let initial: String
            switch consonant {
            case "c": initial = "ei".contains(vowel) ? "θ" : "k"
            case "g": initial = "ei".contains(vowel) ? "x" : "ɡ"
            case "ch": initial = "tʃ"
            case "h": initial = ""
            case "j": initial = "x"
            case "q": initial = "k"
            case "r": initial = "r"
            case "v": initial = "b"
            case "x": initial = "ks"
            case "y", "ll": initial = "ʝ"
            case "z": initial = "θ"
            default: initial = Self.spanishIPAConsonants[consonant] ?? consonant
            }
            return "/\(initial)\(Self.spanishIPAVowels[vowel] ?? vowel)/"
        }
        if language == "de-DE" {
            let initial = Self.germanConsonantIPA(consonant, before: vowel)
            let vowelIPA = Self.germanIPAVowels[vowel] ?? vowel
            let soundSequence: String
            if consonant == "ch" {
                soundSequence = "\(initial) \(vowelIPA)"
            } else {
                soundSequence = "\(initial)\(vowelIPA)"
            }
            return "\(consonant)\(vowel) /\(soundSequence)/"
        }
        return ""
    }

    private static func germanConsonantIPA(_ consonant: String, before vowel: String) -> String {
        switch consonant {
        case "c":
            return "eiyäöü".contains(vowel) ? "ts" : "k"
        case "ch":
            return "ç~x"
        default:
            return germanIPAConsonants[consonant] ?? consonant
        }
    }

    private static let russianRomanConsonants = [
        "б": "b", "в": "v", "г": "g", "д": "d", "ж": "zh", "з": "z",
        "й": "y", "к": "k", "л": "l", "м": "m", "н": "n", "п": "p",
        "р": "r", "с": "s", "т": "t", "ф": "f", "х": "kh", "ц": "ts",
        "ч": "ch", "ш": "sh", "щ": "shch"
    ]
    private static let russianRomanVowels = [
        "а": "a", "я": "ya", "о": "o", "ё": "yo", "у": "u", "ю": "yu",
        "ы": "y", "и": "i", "э": "e", "е": "e"
    ]
    private static let russianIPAConsonants = [
        "б": "b", "в": "v", "г": "ɡ", "д": "d", "ж": "ʐ", "з": "z",
        "й": "j", "к": "k", "л": "l", "м": "m", "н": "n", "п": "p",
        "р": "r", "с": "s", "т": "t", "ф": "f", "х": "x", "ц": "t͡s",
        "ч": "t͡ɕ", "ш": "ʂ", "щ": "ɕː"
    ]
    private static let russianIPAVowels = [
        "а": "a", "я": "a", "о": "o", "ё": "o", "у": "u", "ю": "u",
        "ы": "ɨ", "и": "i", "э": "e", "е": "e"
    ]
    private static let frenchIPAVowels = [
        "a": "a", "e": "ə~ɛ", "i": "i", "o": "o", "u": "y", "y": "i"
    ]
    private static let frenchIPAConsonants = [
        "b": "b", "d": "d", "f": "f", "k": "k", "l": "l", "m": "m",
        "n": "n", "p": "p", "s": "s", "t": "t", "v": "v", "z": "z"
    ]
    private static let spanishIPAVowels = [
        "a": "a", "e": "e", "i": "i", "o": "o", "u": "u"
    ]
    private static let spanishIPAConsonants = [
        "b": "b", "d": "d", "f": "f", "k": "k", "l": "l", "m": "m",
        "n": "n", "ñ": "ɲ", "p": "p", "s": "s", "t": "t", "v": "b",
        "w": "w", "y": "ʝ"
    ]
    private static let germanIPAVowels = [
        "a": "aː~a", "ä": "ɛː~ɛ", "e": "eː~ɛ", "i": "iː~ɪ",
        "o": "oː~ɔ", "ö": "øː~œ", "u": "uː~ʊ", "ü": "yː~ʏ", "y": "i~y"
    ]
    private static let germanIPAConsonants = [
        "b": "b", "c": "k~ts", "d": "d", "f": "f", "g": "ɡ", "h": "h",
        "j": "j",
        "k": "k", "l": "l", "m": "m", "n": "n", "p": "p", "q": "kv",
        "r": "ʁ", "s": "z~s", "t": "t", "v": "f~v", "w": "v", "x": "ks",
        "z": "ts", "ch": "ç~x", "sch": "ʃ", "sp": "ʃp", "st": "ʃt",
        "pf": "pf", "qu": "kv", "tsch": "tʃ"
    ]
    private static let arabicRomanConsonants = [
        "ء": "ʾ", "ب": "b", "ت": "t", "ث": "th", "ج": "j", "ح": "ḥ", "خ": "kh",
        "د": "d", "ذ": "dh", "ر": "r", "ز": "z", "س": "s", "ش": "sh", "ص": "ṣ",
        "ض": "ḍ", "ط": "ṭ", "ظ": "ẓ", "ع": "ʿ", "غ": "gh", "ف": "f", "ق": "q",
        "ك": "k", "ل": "l", "م": "m", "ن": "n", "ه": "h", "و": "w", "ي": "y"
    ]
    private static let arabicIPAConsonants = [
        "ء": "ʔ", "ب": "b", "ت": "t", "ث": "θ", "ج": "d͡ʒ", "ح": "ħ", "خ": "x",
        "د": "d", "ذ": "ð", "ر": "r", "ز": "z", "س": "s", "ش": "ʃ", "ص": "sˤ",
        "ض": "dˤ", "ط": "tˤ", "ظ": "ðˤ", "ع": "ʕ", "غ": "ɣ", "ف": "f", "ق": "q",
        "ك": "k", "ل": "l", "م": "m", "ن": "n", "ه": "h", "و": "w", "ي": "j"
    ]
    private static let arabicRomanVowels = ["َ": "a", "ِ": "i", "ُ": "u"]
    private static let arabicIPAVowels = ["َ": "a", "ِ": "i", "ُ": "u"]
    private static let koreanRomanInitials = [
        "ㄱ": "g", "ㄲ": "kk", "ㄴ": "n", "ㄷ": "d", "ㄸ": "tt", "ㄹ": "r",
        "ㅁ": "m", "ㅂ": "b", "ㅃ": "pp", "ㅅ": "s", "ㅆ": "ss", "ㅇ": "",
        "ㅈ": "j", "ㅉ": "jj", "ㅊ": "ch", "ㅋ": "k", "ㅌ": "t", "ㅍ": "p",
        "ㅎ": "h"
    ]
    private static let koreanIPAInitials = [
        "ㄱ": "k", "ㄲ": "k͈", "ㄴ": "n", "ㄷ": "t", "ㄸ": "t͈", "ㄹ": "ɾ",
        "ㅁ": "m", "ㅂ": "p", "ㅃ": "p͈", "ㅅ": "s", "ㅆ": "s͈", "ㅇ": "",
        "ㅈ": "t͡ɕ", "ㅉ": "t͡ɕ͈", "ㅊ": "t͡ɕʰ", "ㅋ": "kʰ", "ㅌ": "tʰ",
        "ㅍ": "pʰ", "ㅎ": "h"
    ]
    private static let koreanRomanVowels = [
        "ㅏ": "a", "ㅐ": "ae", "ㅑ": "ya", "ㅒ": "yae", "ㅓ": "eo", "ㅔ": "e",
        "ㅕ": "yeo", "ㅖ": "ye", "ㅗ": "o", "ㅘ": "wa", "ㅙ": "wae", "ㅚ": "oe",
        "ㅛ": "yo", "ㅜ": "u", "ㅝ": "wo", "ㅞ": "we", "ㅟ": "wi", "ㅠ": "yu",
        "ㅡ": "eu", "ㅢ": "ui", "ㅣ": "i"
    ]
    private static let koreanIPAVowels = [
        "ㅏ": "a", "ㅐ": "ɛ~e", "ㅑ": "ja", "ㅒ": "jɛ~je", "ㅓ": "ʌ", "ㅔ": "e",
        "ㅕ": "jʌ", "ㅖ": "je", "ㅗ": "o", "ㅘ": "wa", "ㅙ": "wɛ~we", "ㅚ": "we",
        "ㅛ": "jo", "ㅜ": "u", "ㅝ": "wʌ", "ㅞ": "we", "ㅟ": "wi", "ㅠ": "ju",
        "ㅡ": "ɯ", "ㅢ": "ɯi", "ㅣ": "i"
    ]
    private static let koreanRomanCodas = [
        "": "", "ㄱ": "g", "ㄲ": "kk", "ㄳ": "gs", "ㄴ": "n", "ㄵ": "nj",
        "ㄶ": "nh", "ㄷ": "d", "ㄹ": "l", "ㄺ": "lg", "ㄻ": "lm", "ㄼ": "lb",
        "ㄽ": "ls", "ㄾ": "lt", "ㄿ": "lp", "ㅀ": "lh", "ㅁ": "m", "ㅂ": "b",
        "ㅄ": "bs", "ㅅ": "s", "ㅆ": "ss", "ㅇ": "ng", "ㅈ": "j", "ㅊ": "ch",
        "ㅋ": "k", "ㅌ": "t", "ㅍ": "p", "ㅎ": "h"
    ]
    private static let koreanIPACodas = [
        "": "", "ㄱ": "k̚", "ㄲ": "k̚", "ㄳ": "k̚", "ㄴ": "n", "ㄵ": "n",
        "ㄶ": "n", "ㄷ": "t̚", "ㄹ": "l", "ㄺ": "k̚", "ㄻ": "m", "ㄼ": "p̚",
        "ㄽ": "l", "ㄾ": "l", "ㄿ": "p̚", "ㅀ": "l", "ㅁ": "m", "ㅂ": "p̚",
        "ㅄ": "p̚", "ㅅ": "t̚", "ㅆ": "t̚", "ㅇ": "ŋ", "ㅈ": "t̚", "ㅊ": "t̚",
        "ㅋ": "k̚", "ㅌ": "t̚", "ㅍ": "p̚", "ㅎ": "t̚"
    ]

    private static let hangulInitials = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ",
        "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    private static let hangulVowels = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ",
        "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"
    ]
    private static let hangulFinals = [
        "", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ",
        "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ",
        "ㅍ", "ㅎ"
    ]
}
