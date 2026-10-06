// JobsLanguageLearning Flutter. Created by Jobs on 2026年10月2日，星期五.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/repository.dart';
import 'core/phonetics.dart';
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
    actions: const [_HomeThemeButton()],
    child: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '每天读一点，\n让语言开口。',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 12),
                    const Text('俄语、阿拉伯语、法语、西班牙语、朝鲜语、德语拼读 · 英语词典 · 日语'),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: PinnedSectionHeader(
            height: 56,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '选择一个学习工具',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            for (final entry in [
              _entry(
                context,
                '🇬🇧 英语分级词典',
                '按级别与字母检索，词义、短语及例句点读',
                const EnglishPage(),
              ),
              _entry(
                context,
                '🇷🇺 俄语点读',
                '10 元音 · 21 辅音 · 210 组合，分组与全表试听',
                const PhoneticsPage(),
              ),
              _entry(
                context,
                '🇫🇷 法语拼读',
                '6 个元音字母 · 辅音组合试听 · 拼写例外提示',
                const PhoneticsPage(course: frenchCourse),
              ),
              _entry(
                context,
                '🇪🇸 西班牙语拼读',
                '5 个元音 · 22 个辅音字母 · 常见拼写规则提示',
                const PhoneticsPage(course: spanishCourse),
              ),
              _entry(
                context,
                '🇰🇷 朝鲜语拼读',
                '19 个声母 · 21 个元音 · 27 种收音组合',
                const PhoneticsPage(course: koreanCourse),
              ),
              _entry(
                context,
                '🇩🇪 德语拼读',
                '8 个基础元音 · 外来词 y · 辅音组合点读',
                const PhoneticsPage(course: germanCourse),
              ),
              _entry(
                context,
                '🇯🇵 日语汉字点读',
                '音读、训读、名乘、红字振假名，元音与辅音组合',
                const JapanesePage(),
              ),
              _entry(
                context,
                '阿拉伯语短元音拼读',
                '28 个辅音 · 3 个短元音 · 简化拉丁注音与 IPA',
                const PhoneticsPage(course: arabicCourse),
                flagAsset: "assets/flags/arab_league.png",
              ),
            ])
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: entry,
                  ),
                ),
              ),
          ]),
        ),
      ],
    ),
  );
  Widget _entry(
    BuildContext context,
    String title,
    String description,
    Widget page, {
    String? flagAsset,
  }) => Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      contentPadding: const EdgeInsets.all(24),
      title: Row(
        children: [
          if (flagAsset != null) ...[
            Image.asset(
              flagAsset,
              width: 36,
              height: 24,
              fit: BoxFit.contain,
              semanticLabel: '阿拉伯联盟旗帜',
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(description),
      ),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    ),
  );
}

class _HomeThemeButton extends StatefulWidget {
  const _HomeThemeButton();

  @override
  State<_HomeThemeButton> createState() => _HomeThemeButtonState();
}

class _HomeThemeButtonState extends State<_HomeThemeButton> {
  bool _menuOpen = false;

  String _label(ThemeMode mode) => switch (mode) {
    ThemeMode.system => '跟随系统',
    ThemeMode.light => '白天',
    ThemeMode.dark => '黑夜',
  };

  @override
  Widget build(BuildContext context) {
    final settings = Services.of(context).settings;
    return ListenableBuilder(
      listenable: settings,
      builder: (_, _) {
        return Semantics(
          label: '选择主题',
          value: _label(settings.theme),
          hint: '展开白天、黑夜、跟随系统选项',
          child: PopupMenuButton<ThemeMode>(
            tooltip: '展开主题选项',
            position: PopupMenuPosition.under,
            offset: const Offset(-12, 6),
            constraints: const BoxConstraints.tightFor(width: 210),
            menuPadding: EdgeInsets.zero,
            color: Theme.of(context).colorScheme.surfaceContainer,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            onOpened: () => setState(() => _menuOpen = true),
            onCanceled: () => setState(() => _menuOpen = false),
            onSelected: (mode) {
              setState(() => _menuOpen = false);
              settings.setTheme(mode);
            },
            itemBuilder: (_) => [
              for (final mode in const [
                ThemeMode.light,
                ThemeMode.dark,
                ThemeMode.system,
              ]) ...[
                PopupMenuItem<ThemeMode>(
                  value: mode,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Semantics(
                    checked: settings.theme == mode,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _label(mode),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (settings.theme == mode)
                          const ExcludeSemantics(child: Text('✓')),
                      ],
                    ),
                  ),
                ),
                if (mode != ThemeMode.system)
                  PopupMenuDivider(
                    height: 0.5,
                    thickness: 0.5,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            ],
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    _menuOpen ? '主题 ▴' : '主题 ▾',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
