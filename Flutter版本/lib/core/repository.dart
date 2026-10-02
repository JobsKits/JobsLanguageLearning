// Created by Jobs on 2026年10月2日，星期五.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

import 'phonetics.dart';
import 'translation.dart';

typedef CatalogRecord = Map<String, dynamic>;

class CatalogPage {
  final List<CatalogRecord> rows;
  final int total;
  const CatalogPage(this.rows, this.total);
}

class CatalogRepository {
  Database? _english;
  Database? _japanese;
  Future<void>? _initialization;
  Map<String, dynamic> guides = {};
  Map<String, dynamic> pos = {};
  Future<void> initialize() async {
    final pending = _initialization ??= _open();
    try {
      await pending;
    } catch (_) {
      if (identical(_initialization, pending)) {
        await _english?.close();
        await _japanese?.close();
        _english = null;
        _japanese = null;
        _initialization = null;
      }
      rethrow;
    }
  }

  Future<String> _copy(String asset, String directory) async {
    final path = '$directory/${asset.split('/').last}';
    if (!await File(path).exists()) {
      final data = await rootBundle.load(asset);
      final staging = File('$path.tmp');
      await staging.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
      await staging.rename(path);
    }
    return path;
  }

  Future<void> _open() async {
    if (Platform.isWindows) {
      ffi.sqfliteFfiInit();
      databaseFactory = ffi.databaseFactoryFfi;
    }
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/catalog-v1');
    await directory.create(recursive: true);
    final english = await _copy(
      'assets/english/catalog.sqlite3',
      directory.path,
    );
    final japanese = await _copy(
      'assets/japanese/catalog.sqlite',
      directory.path,
    );
    final seed = await _copy(
      'assets/japanese/chinese_seed.sqlite',
      directory.path,
    );
    _english = await openDatabase(
      english,
      readOnly: true,
      singleInstance: false,
    );
    _japanese = await openDatabase(
      japanese,
      readOnly: true,
      singleInstance: false,
    );
    await _japanese!.execute('ATTACH DATABASE ? AS zh', [seed]);
    guides = jsonDecode(
      await rootBundle.loadString('assets/japanese/guides.json'),
    );
    pos = jsonDecode(
      await rootBundle.loadString('assets/japanese/pos_zh.json'),
    );
  }

  Future<List<CatalogRecord>> levels() async {
    await initialize();
    return _english!.rawQuery('SELECT * FROM levels ORDER BY position');
  }

  static String escapeLike(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll('%', '\\%')
      .replaceAll('_', '\\_');
  Future<CatalogPage> englishPage(
    String level,
    String letter,
    String query,
    int offset,
  ) async {
    await initialize();
    var where = 'm.level_id=?';
    final args = <Object?>[level];
    if (letter.isNotEmpty) {
      where += ' AND w.initial=?';
      args.add(letter);
    }
    if (query.isNotEmpty) {
      where += " AND (w.word LIKE ? ESCAPE '\\' OR w.search_text LIKE ? ESCAPE '\\')";
      args.addAll(['%${escapeLike(query)}%', '%${escapeLike(query)}%']);
    }
    final base =
        ' FROM words w JOIN membership m ON m.word_id=w.id WHERE $where';
    final total = Sqflite.firstIntValue(
      await _english!.rawQuery('SELECT COUNT(*)$base', args),
    )!;
    final rows = await _english!.rawQuery(
      'SELECT w.*$base ORDER BY w.word COLLATE NOCASE,w.id LIMIT 40 OFFSET ?',
      [...args, offset],
    );
    return CatalogPage(
      rows
          .map(
            (r) => {
              ...r,
              'senses': jsonDecode(r['senses'] as String),
              'examples': jsonDecode(r['examples'] as String),
              'phrases': jsonDecode(r['phrases'] as String),
            },
          )
          .toList(),
      total,
    );
  }

  Future<CatalogPage> kanjiPage(String query, int group, int offset) async {
    await initialize();
    final clauses = <String>[];
    final args = <Object?>[];
    if (group == 1) clauses.add('k.grade BETWEEN 1 AND 8');
    if (group == 2) clauses.add('k.grade IN (9,10)');
    if (query.isNotEmpty) {
      clauses.add(
        '(instr(?,k.literal)>0 OR instr(k.data,?)>0 OR instr(z.zh,?)>0 OR k.literal IN (SELECT kw.literal FROM kanji_words kw JOIN forms f ON f.word_id=kw.word_id WHERE f.spelling=? OR f.reading=?))',
      );
      args.addAll([query, hiragana(query), query, query, hiragana(query)]);
    }
    final base =
        ' FROM kanji k LEFT JOIN zh.kanji_zh z ON z.literal=k.literal${clauses.isEmpty ? '' : ' WHERE ${clauses.join(' AND ')}'}';
    final total = Sqflite.firstIntValue(
      await _japanese!.rawQuery('SELECT COUNT(*)$base', args),
    )!;
    final rows = await _japanese!.rawQuery(
      'SELECT k.literal,k.grade,k.strokes,z.zh$base ORDER BY k.freq,k.literal LIMIT 50 OFFSET ?',
      [...args, offset],
    );
    return CatalogPage(rows, total);
  }

  Future<CatalogRecord> entry(String literal) async {
    await initialize();
    final rows = await _japanese!.rawQuery(
      'SELECT data FROM kanji WHERE literal=?',
      [literal],
    );
    if (rows.isEmpty) throw StateError('字库未收录此字');
    return jsonDecode(rows.first['data'] as String);
  }

  Future<CatalogPage> words(String literal, String query, int offset) async {
    await initialize();
    final extra = query.isEmpty
        ? ''
        : ' AND EXISTS (SELECT 1 FROM forms f WHERE f.word_id=w.id AND (instr(f.spelling,?)>0 OR instr(f.reading,?)>0))';
    final args = <Object?>[
      literal,
      if (query.isNotEmpty) ...[query, hiragana(query)],
    ];
    final base =
        ' FROM words w JOIN kanji_words k ON w.id=k.word_id WHERE k.literal=?$extra';
    final total = Sqflite.firstIntValue(
      await _japanese!.rawQuery('SELECT COUNT(*)$base', args),
    )!;
    final rows = await _japanese!.rawQuery(
      "SELECT w.id,w.data$base ORDER BY w.priority,length(json_extract(w.data,'\$.spellings[0]')),w.id LIMIT 15 OFFSET ?",
      [...args, offset],
    );
    return CatalogPage(
      rows
          .map(
            (r) => {
              'id': r['id'],
              ...jsonDecode(r['data'] as String) as Map<String, dynamic>,
            },
          )
          .toList(),
      total,
    );
  }

  Future<String> chinese(String source) async {
    await initialize();
    if (source.isEmpty) return '原字库未收录释义';
    final saved = await ChineseTranslation.cached(source);
    if (saved != null) return '$saved（机器译文，待校对）';
    final rows = await _japanese!.rawQuery(
      'SELECT zh FROM zh.translations WHERE source=? LIMIT 1',
      [source],
    );
    return rows.isEmpty ? '中文译文待补充' : '${rows.first['zh']}（辅助译文，待校对）';
  }
}
