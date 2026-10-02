//
//  JobsSQLiteDatabase.swift
//  JobsLanguageCore
//
//  Created by Jobs on 2026年10月1日，星期四.
//

import Foundation
import JobsSwiftBlock
import SQLite3

/// 每个 Repository actor 独占连接；查询绑定参数，数据文件只读。
public final class JobsSQLiteDatabase {
    private var handle: OpaquePointer?

    public init(url: URL, writable: Bool = false) throws {
        let flags = writable ? SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE : SQLITE_OPEN_READONLY
        guard sqlite3_open_v2(url.path, &handle, flags | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK else {
            let message =
                handle.map {
                    String(cString: sqlite3_errmsg($0))
                } ?? "无法打开词库"
            if handle != nil {
                sqlite3_close(handle)
            }
            handle = nil
            throw JobsLanguageError.message(message)
        }
    }

    deinit {
        sqlite3_close(handle)
    }

    public func rows(_ sql: String, _ arguments: [String] = []) throws -> [[String: String]] {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            throw JobsLanguageError.message(String(cString: sqlite3_errmsg(handle)))
        }
        defer {
            sqlite3_finalize(statement)
        }
        for (index, value) in arguments.enumerated() {
            let result = value.withCString {
                sqlite3_bind_text(
                    statement, Int32(index + 1), $0, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            }
            guard result == SQLITE_OK else {
                throw JobsLanguageError.message("词库查询参数绑定失败")
            }
        }
        var result: [[String: String]] = []
        while true {
            let status = sqlite3_step(statement)
            if status == SQLITE_DONE {
                break
            }
            guard status == SQLITE_ROW else {
                throw JobsLanguageError.message(String(cString: sqlite3_errmsg(handle)))
            }
            var row: [String: String] = [:]
            for index in 0..<sqlite3_column_count(statement) {
                let name = String(cString: sqlite3_column_name(statement, index))
                if let text = sqlite3_column_text(statement, index) {
                    row[name] = String(cString: text)
                }
            }
            result.append(row)
        }
        return result
    }

    public func scalar(_ sql: String, _ arguments: [String] = []) throws -> Int {
        Int(try rows(sql, arguments).first?.values.first ?? "0") ?? 0
    }

    public static func escapeLike(_ value: String) -> String {
        value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
    }

    public static func decode<T: Decodable>(_ type: T.Type, _ text: String) throws -> T {
        try JSONDecoder.make { _ in
        }
        .decode(type, from: Data(text.utf8))
    }
}
