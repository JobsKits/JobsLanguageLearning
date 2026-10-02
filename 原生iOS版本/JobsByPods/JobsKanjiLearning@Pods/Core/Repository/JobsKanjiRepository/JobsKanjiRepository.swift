//
//  JobsKanjiRepository.swift
//  JobsKanjiLearning
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation
import JobsSwiftBlock
import JobsLanguageCore

public actor JobsKanjiRepository {

    public init() {
    }
    private var database: JobsSQLiteDatabase?
    private var guides: [String: JobsKanjiGuide]?

    private func db() throws -> JobsSQLiteDatabase {
        if let database {
            return database
        }
        let bundle = try JobsLanguageResources.bundle("JobsKanjiLearningResources", owner: JobsKanjiRepository.self)
        let database = try JobsSQLiteDatabase(
            url: JobsLanguageResources.file("catalog", extension: "sqlite", bundle: bundle))
        let seed = try JobsLanguageResources.file("chinese_seed", extension: "sqlite", bundle: bundle)
        _ = try database.rows("ATTACH DATABASE ? AS zh", [seed.path])
        self.database = database
        return database
    }

    public func page(query: String, group: Int, offset: Int) throws -> JobsKanjiPage {
        var clauses: [String] = []
        var arguments: [String] = []
        if group == 1 {
            clauses.append("k.grade BETWEEN 1 AND 8")
        }
        if group == 2 {
            clauses.append("k.grade IN (9,10)")
        }
        if !query.isEmpty {
            clauses.append(
                "(instr(?,k.literal)>0 OR instr(k.data,?)>0 OR instr(z.zh,?)>0 OR k.literal IN (SELECT kw.literal FROM kanji_words kw JOIN forms f ON f.word_id=kw.word_id WHERE f.spelling=? OR f.reading=?))"
            )
            arguments += [
                query, JobsKanjiLinguistics.hiragana(query), query, query, JobsKanjiLinguistics.hiragana(query)
            ]
        }
        let base =
            " FROM kanji k LEFT JOIN zh.kanji_zh z ON z.literal=k.literal"
            + (clauses.isEmpty ? "" : " WHERE " + clauses.joined(separator: " AND "))
        let db = try db()
        let total = try db.scalar("SELECT COUNT(*)" + base, arguments)
        let rows = try db.rows(
            "SELECT k.literal,k.grade,k.strokes,z.zh" + base + " ORDER BY k.freq,k.literal LIMIT 50 OFFSET ?",
            arguments + [String(offset)])
        let summaries = rows.map {
            JobsKanjiSummary(
                literal: $0["literal"] ?? "", grade: Int($0["grade"] ?? "0") ?? 0,
                strokes: Int($0["strokes"] ?? "0") ?? 0, chinese: $0["zh"] ?? "原字库缺释义")
        }
        return JobsKanjiPage(entries: summaries, total: total)
    }

    public func entry(_ literal: String) throws -> JobsKanjiEntry {
        guard let text = try db().rows("SELECT data FROM kanji WHERE literal=?", [literal]).first?["data"] else {
            throw JobsLanguageError.message("字库没有收录此字")
        }
        return try JobsSQLiteDatabase.decode(JobsKanjiEntry.self, text)
    }

    public func guide(_ literal: String) throws -> JobsKanjiGuide? {
        if guides == nil {
            let bundle = try JobsLanguageResources.bundle("JobsKanjiLearningResources", owner: JobsKanjiRepository.self)
            guides =
                try JSONDecoder.make { _ in
                }
                .decode(
                    [String: JobsKanjiGuide].self,
                    from: Data(contentsOf: JobsLanguageResources.file("guides", extension: "json", bundle: bundle)))
        }
        return guides?[literal]
    }

    public func words(_ literal: String, query: String, offset: Int) throws -> JobsKanjiWordPage {
        let db = try db()
        var args = [literal]
        var extra = ""
        if !query.isEmpty {
            extra =
                " AND EXISTS (SELECT 1 FROM forms f WHERE f.word_id=w.id AND (instr(f.spelling,?)>0 OR instr(f.reading,?)>0))"
            args += [query, JobsKanjiLinguistics.hiragana(query)]
        }
        let base = " FROM words w JOIN kanji_words k ON w.id=k.word_id WHERE k.literal=?" + extra
        let total = try db.scalar("SELECT COUNT(*)" + base, args)
        let rows = try db.rows(
            "SELECT w.data" + base
                + " ORDER BY w.priority,length(json_extract(w.data,'$.spellings[0]')),w.id LIMIT 15 OFFSET ?",
            args + [String(offset)])
        return JobsKanjiWordPage(
            words: try rows.map {
                try JobsSQLiteDatabase.decode(JobsKanjiWord.self, $0["data"] ?? "{}")
            }, total: total)
    }
}
