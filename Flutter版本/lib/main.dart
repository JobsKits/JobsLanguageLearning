// JobsLanguageLearning Flutter. Created by Jobs on 2026年10月2日，星期五.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/repository.dart';
import 'core/services.dart';
import 'core/settings.dart';
import 'core/speech.dart';
import 'features/english_page.dart';
import 'features/japanese_page.dart';
import 'features/phonetics_page.dart';
import 'widgets/learning_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettings(await SharedPreferences.getInstance());
  runApp(LanguageLearningApp(settings: settings));
}

class PlaybackObserver extends NavigatorObserver {
  final SpeechService speech;
  PlaybackObserver(this.speech);
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    speech.stop();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    speech.stop();
  }
}

class LanguageLearningApp extends StatefulWidget {
  final AppSettings settings;
  const LanguageLearningApp({required this.settings, super.key});
  @override
  State<LanguageLearningApp> createState() => _LanguageLearningAppState();
}

class _LanguageLearningAppState extends State<LanguageLearningApp>
    with WidgetsBindingObserver {
  late final SpeechService speech;
  late final PlaybackObserver observer;
  final catalog = CatalogRepository();
  @override
  void initState() {
    super.initState();
    speech = SpeechService(widget.settings);
    observer = PlaybackObserver(speech);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) speech.stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    speech.stop();
    speech.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Services(
    settings: widget.settings,
    speech: speech,
    catalog: catalog,
    child: ListenableBuilder(
      listenable: widget.settings,
      builder: (_, _) => MaterialApp(
        title: 'Jobs语言学习',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [observer],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff146b68)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff7dd9ce),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: widget.settings.theme,
        home: const HomePage(),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => LearningPage(
    title: 'Jobs语言学习',
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '每天读一点，\n让语言开口。',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            const Text('俄语拼读 · 英语分级词典 · 日语汉字与假名'),
            const SizedBox(height: 28),
            _entry(
              context,
              '俄语点读',
              '10 元音 · 21 辅音 · 210 组合，分组与全表试听',
              const PhoneticsPage(),
            ),
            _entry(
              context,
              '英语分级词典',
              '按级别与字母检索，词义、短语及例句点读',
              const EnglishPage(),
            ),
            _entry(
              context,
              '日语汉字点读',
              '音读、训读、名乘、红字振假名，元音与辅音组合',
              const JapanesePage(),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => _about(context),
              child: const Text('数据覆盖 · 来源与使用边界'),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _entry(
    BuildContext context,
    String title,
    String description,
    Widget page,
  ) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      contentPadding: const EdgeInsets.all(24),
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(description),
      ),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    ),
  );
  void _about(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('数据与使用说明'),
      content: const SingleChildScrollView(
        child: Text(
          '内置完整来源词库：日语 13,108 字、218,844 词、26,269 不同例句。KANJIDIC2 / JMdict 依据 EDRDG CC BY-SA 4.0；Tatoeba 保留原句作者链接。英语词书来源和使用限制见 assets/english/THIRD_PARTY_NOTICES.txt。\n\n原库存在缺读音、释义、例句；中文机器译文仅辅助学习。系统 TTS 不等同于专业音素录音。辅音表头采用代表音节试听。\n\n优先使用内置中文；缺译可在 macOS / iOS / Android 生成设备端译文并缓存。Windows 缺译显示待补充。下载或安装系统语音后可离线点读。',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('知道了'),
        ),
      ],
    ),
  );
}
