import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jobs_language_learning/main.dart' as app;
import 'package:jobs_language_learning/core/repository.dart';
import 'package:jobs_language_learning/core/phonetics.dart';
import 'package:jobs_language_learning/core/services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('真实英日词库与页面完整流程', (tester) async {
    final repository = CatalogRepository();
    await repository.initialize();
    final levels = await repository.levels();
    expect(levels.length, greaterThan(3));
    final english = await repository.englishPage('junior', '', 'apple', 0);
    expect(english.rows.any((row) => row['word'] == 'apple'), true);
    expect(english.rows.first['senses'], isNotEmpty);
    final noMatch = await repository.englishPage(
      'junior',
      '',
      "' OR 1=1 --",
      0,
    );
    expect(noMatch.total, 0);
    final kanji = await repository.kanjiPage('生', 0, 0);
    expect(kanji.rows.any((row) => row['literal'] == '生'), true);
    final all = await repository.kanjiPage('', 0, 0);
    expect(all.total, 13108);
    final entry = await repository.entry('生');
    expect(entry['readings'], isNotEmpty);
    final words = await repository.words('生', 'がくせい', 0);
    expect(words.rows, isNotEmpty);
    final word = words.rows.first;
    final reading = (word['readings'] as List).first['text'];
    final spelling = (word['spellings'] as List).first;
    expect(allowedSenses(word, spelling, reading), isNotEmpty);
    expect(await repository.chinese('country'), contains('国家'));
    debugPrint(
      'CATALOG PASS: ${all.total} kanji; ${levels.length} English levels; valid words and Chinese seed',
    );
    await app.main();
    await tester.pumpAndSettle();
    final services = Services.of(tester.element(find.byType(app.HomePage)));
    for (final pair in [('ru-RU', 'ба'), ('en-US', 'Hello'), ('ja-JP', 'か')]) {
      final available = await services.speech.voices(pair.$1);
      debugPrint('SYSTEM VOICES ${pair.$1}: ${available.length}');
      if (available.isNotEmpty) {
        await services.speech.read(pair.$2, pair.$1);
        expect(services.speech.status, '播放完成');
      }
    }
    await tester.tap(find.text('英语分级词典'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'apple');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(of: find.byType(ListTile), matching: find.text('apple'))
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('朗读 apple'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('返回'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('返回'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('日语汉字点读'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('元音 · 辅音 · 元音＋辅音点读'));
    await tester.pumpAndSettle();
    expect(find.text('あ ア\na'), findsOneWidget);
    expect(find.text('し シ\nshi'), findsOneWidget);
    await tester.tap(find.text('返回'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '生');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('生 · 5 画'));
    await tester.pumpAndSettle();
    expect(find.text('音读'), findsOneWidget);
    expect(find.text('训读'), findsOneWidget);
    expect(find.text('名乘 / 人名读法'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('黑夜'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    debugPrint(
      'UI PASS: English detail, Japanese kana, kanji detail, dark theme',
    );
  });
}
