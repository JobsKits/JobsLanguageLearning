//
//  JobsEnglishRepository.swift
//  JobsEnglishLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation
import JobsLanguageCore

public actor JobsEnglishRepository {

    public init() {
    }
    private var database: JobsSQLiteDatabase?

    private func db() throws -> JobsSQLiteDatabase {
        if let database {
            return database
        }
        let bundle = try JobsLanguageResources.bundle("JobsEnglishLearningResources", owner: JobsEnglishRepository.self)
        let database = try JobsSQLiteDatabase(
            url: JobsLanguageResources.file("catalog", extension: "sqlite3", bundle: bundle))
        self.database = database
        return database
    }

    public func levels() throws -> [JobsEnglishLevel] {
        try db().rows("SELECT * FROM levels ORDER BY position")
            .map {
                JobsEnglishLevel(id: $0["id"] ?? "", name: $0["name"] ?? "", description: $0["description"] ?? "")
            }
    }

    public func page(level: String, letter: String, query: String, offset: Int) throws -> JobsEnglishPage {
        let db = try db()
        var clause = "m.level_id=?"
        var arguments = [level]
        if !letter.isEmpty {
            clause += " AND w.initial=?"
            arguments.append(letter)
        }
        if !query.isEmpty {
            clause += " AND (w.word LIKE ? ESCAPE '\\' OR w.search_text LIKE ? ESCAPE '\\')"
            let term = "%" + JobsSQLiteDatabase.escapeLike(query) + "%"
            arguments += [term, term]
        }
        let base = " FROM words w JOIN membership m ON m.word_id=w.id WHERE " + clause
        let total = try db.scalar("SELECT COUNT(*)" + base, arguments)
        let rows = try db.rows(
            "SELECT w.*" + base + " ORDER BY w.word COLLATE NOCASE,w.id LIMIT 40 OFFSET ?", arguments + [String(offset)]
        )
        let words = try rows.map { row in
            JobsEnglishWord(
                id: Int(row["id"] ?? "0") ?? 0, word: row["word"] ?? "", phonetic: row["phonetic"] ?? "",
                senses: try JobsSQLiteDatabase.decode([JobsEnglishSense].self, row["senses"] ?? "[]"),
                examples: try JobsSQLiteDatabase.decode([JobsEnglishExample].self, row["examples"] ?? "[]"),
                phrases: try JobsSQLiteDatabase.decode([JobsEnglishPhrase].self, row["phrases"] ?? "[]"))
        }
        return JobsEnglishPage(words: words, total: total)
    }
}
