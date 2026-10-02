import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jobs_language_learning/core/settings.dart';
import 'package:jobs_language_learning/core/phonetics.dart';
import 'package:jobs_language_learning/core/speech.dart';
import 'package:jobs_language_learning/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <String>[];
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          if (call.method == 'getVoices') {
            return [
              for (final locale in ['ru-RU', 'ja-JP', 'en-US'])
                {'name': locale, 'locale': locale},
            ];
          }
          if (call.method == 'speak') {
            calls.add(
              call.arguments is String
                  ? call.arguments as String
                  : (call.arguments as Map)['text'],
            );
          }
          return 1;
        });
  });
  test('五十音只生成有效组合，特殊音与缺位准确', () {
    expect(
      kanaRows.expand((r) => r.readings.where((v) => v.isNotEmpty)).length,
      65,
    );
    expect(kanaRows[1].readings[1], 'shi');
    expect(kanaRows[2].readings[2], 'tsu');
    expect(kanaRows[4].readings[2], 'fu');
    expect(kanaRows[6].readings[1], isEmpty);
    expect(spokenReading('イ.きる'), 'いきる');
    expect(russianConsonants.length * russianVowels.length, 210);
  });
  test('义项遵守写法、读法和纯假名限制', () {
    final word = {
      'readings': [
        {
          'text': 'なま',
          'restr': ['生'],
          'no_kanji': false,
        },
      ],
      'senses': [
        {
          'stagk': ['生'],
          'stagr': ['なま'],
        },
        {
          'stagk': [],
          'stagr': ['せい'],
        },
      ],
    };
    expect(allowedSenses(word, '生', 'なま').length, 1);
    expect(allowedSenses(word, '性', 'なま'), isEmpty);
  });
  test('语音设置与三态主题持久化', () async {
    final prefs = await SharedPreferences.getInstance();
    final settings = AppSettings(prefs);
    await settings.setTheme(ThemeMode.dark);
    settings.voices['ja-JP']!.repeats = 3;
    await settings.saveVoice('ja-JP');
    final restored = AppSettings(prefs);
    expect(restored.theme, ThemeMode.dark);
    expect(restored.voices['ja-JP']!.repeats, 3);
  });
  test('快速连续点读丢弃旧请求，重复次数生效', () async {
    final settings = AppSettings(await SharedPreferences.getInstance());
    final speech = SpeechService(settings);
    settings.voices['ja-JP']!.repeats = 2;
    final old = speech.read('あ', 'ja-JP');
    final latest = speech.read('か', 'ja-JP');
    await Future.wait([old, latest]);
    expect(calls, ['か', 'か']);
    expect(speech.playing, false);
  });
  testWidgets('三语首页、俄语分组与全表可打开', (tester) async {
    final settings = AppSettings(await SharedPreferences.getInstance());
    await tester.pumpWidget(LanguageLearningApp(settings: settings));
    await tester.pumpAndSettle();
    expect(find.text('俄语点读'), findsOneWidget);
    expect(find.text('英语分级词典'), findsOneWidget);
    expect(find.text('日语汉字点读'), findsOneWidget);
    await tester.tap(find.text('俄语点读'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('组合 ба'));
    await tester.pumpAndSettle();
    expect(calls.last, 'ба');
    await tester.tap(find.text('全表'));
    await tester.pumpAndSettle();
    expect(find.text('辅 / 元'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
