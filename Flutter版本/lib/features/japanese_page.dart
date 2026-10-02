// Created by Jobs on 2026年10月2日，星期五.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/phonetics.dart';
import '../core/repository.dart';
import '../core/services.dart';
import '../widgets/learning_page.dart';
import '../widgets/ruby_text.dart';
import 'phonetics_page.dart';

class JapanesePage extends StatefulWidget {
  const JapanesePage({super.key});
  @override
  State<JapanesePage> createState() => _JapanesePageState();
}

class _JapanesePageState extends State<JapanesePage> {
  String query = '';
  int group = 0;
  int offset = 0;
  Future<CatalogPage>? page;
  Timer? debounce;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    page ??= fetch();
  }

  Future<CatalogPage> fetch() =>
      Services.of(context).catalog.kanjiPage(query, group, offset);
  void reload() {
    page = fetch();
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LearningPage(
    title: '日语汉字点读',
    language: 'ja-JP',
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PhoneticsPage(japanese: true),
              ),
            ),
            child: const Text('元音 · 辅音 · 元音＋辅音点读'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            decoration: const InputDecoration(
              labelText: '搜索汉字、词语、假名或中文',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 250), () {
                if (mounted) {
                  setState(() {
                    query = value.trim();
                    offset = 0;
                    reload();
                  });
                }
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('全部')),
              ButtonSegment(value: 1, label: Text('常用')),
              ButtonSegment(value: 2, label: Text('人名用')),
            ],
            selected: {group},
            onSelectionChanged: (value) => setState(() {
              group = value.first;
              offset = 0;
              reload();
            }),
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: page,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Notice('查询失败：${snapshot.error}'),
                      TextButton(
                        onPressed: () => setState(reload),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final result = snapshot.data!;
              return Column(
                children: [
                  Expanded(
                    child: result.rows.isEmpty
                        ? const Center(child: Text('没有匹配汉字'))
                        : ListView.builder(
                            itemCount: result.rows.length,
                            itemBuilder: (_, i) {
                              final row = result.rows[i];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  title: Text(
                                    '${row['literal']} · ${row['strokes']} 画',
                                    style: const TextStyle(fontSize: 23),
                                  ),
                                  subtitle: Text(row['zh'] ?? '原库缺释义'),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => KanjiDetail(summary: row),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  PageControls(
                    offset: offset,
                    total: result.total,
                    size: 50,
                    onPage: (value) => setState(() {
                      offset = value;
                      reload();
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

class KanjiDetail extends StatefulWidget {
  final CatalogRecord summary;
  const KanjiDetail({required this.summary, super.key});
  @override
  State<KanjiDetail> createState() => _KanjiDetailState();
}

class _KanjiDetailState extends State<KanjiDetail> {
  Future<CatalogRecord>? entry;
  Future<CatalogPage>? words;
  int offset = 0;
  String query = '';
  Timer? debounce;
  CatalogRepository get catalog => Services.of(context).catalog;
  String get literal => widget.summary['literal'];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    entry ??= catalog.entry(literal);
    words ??= catalog.words(literal, query, offset);
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LearningPage(
    title: '$literal · 读音与词语',
    language: 'ja-JP',
    child: FutureBuilder(
      future: entry,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Notice('字库读取失败：${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final guide = catalog.guides[literal] as Map?;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(literal, style: const TextStyle(fontSize: 64)),
            Text(guide?['meaning'] ?? widget.summary['zh'] ?? '原字库缺释义'),
            const Notice('音读、训读、名乘均可点读；“.”分隔送假名，不参与朗读。读法需结合具体词语。'),
            for (final type in ['ja_on', 'ja_kun']) ...[
              Text(
                type == 'ja_on' ? '音读' : '训读',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final reading in data['readings'])
                    if (reading['type'] == type)
                      ReadButton(
                        reading['text'],
                        spokenReading(reading['text']),
                        'ja-JP',
                      ),
                ],
              ),
            ],
            if ((data['nanori'] as List).isNotEmpty) ...[
              const Text('名乘 / 人名读法'),
              Wrap(
                spacing: 8,
                children: [
                  for (final reading in data['nanori'])
                    ReadButton(reading, spokenReading(reading), 'ja-JP'),
                ],
              ),
            ],
            if ((data['readings'] as List).isEmpty) const Notice('原字库没有收录读音。'),
            if (guide != null) ...[
              const SizedBox(height: 16),
              Text('中文学习示例', style: Theme.of(context).textTheme.titleLarge),
              for (final example in guide['examples'])
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReadButton(
                          '${example['word']} / ${example['reading']} · ${example['meaning']}',
                          example['reading'],
                          'ja-JP',
                        ),
                        RubyText(example['tokens']),
                        Text(example['zh']),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            Text('关联词语', style: Theme.of(context).textTheme.titleLarge),
            TextField(
              decoration: const InputDecoration(labelText: '筛选词语或假名'),
              onChanged: (value) {
                debounce?.cancel();
                debounce = Timer(const Duration(milliseconds: 250), () {
                  if (mounted) {
                    setState(() {
                      query = value.trim();
                      offset = 0;
                      words = catalog.words(literal, query, offset);
                    });
                  }
                });
              },
            ),
            FutureBuilder(
              future: words,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Notice('词语读取失败：${snapshot.error}');
                }
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LinearProgressIndicator();
                }
                final page = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (page.rows.isEmpty) const Notice('原字库没有匹配词语。'),
                    for (final word in page.rows) _wordCard(word),
                    PageControls(
                      offset: offset,
                      total: page.total,
                      size: 15,
                      onPage: (value) => setState(() {
                        offset = value;
                        words = catalog.words(literal, query, offset);
                      }),
                    ),
                  ],
                );
              },
            ),
            const Notice('译文是辅助资料，未全量人工校对。原库缺读音、释义或例句，不使用自动造句填补。'),
          ],
        );
      },
    ),
  );
  Widget _wordCard(CatalogRecord word) {
    final pairs = <(String, String)>[];
    for (final reading in word['readings']) {
      final text = reading['text'] as String;
      final spellings =
          reading['no_kanji'] == true || (word['spellings'] as List).isEmpty
          ? [text]
          : word['spellings'] as List;
      for (final spelling in spellings) {
        final restriction = reading['restr'] as List;
        if (restriction.isEmpty || restriction.contains(spelling)) {
          pairs.add((spelling, text));
        }
      }
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (spelling, reading) in pairs)
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JapaneseWordDetail(
                      word: word,
                      spelling: spelling,
                      reading: reading,
                    ),
                  ),
                ),
                child: Text('$spelling / $reading'),
              ),
          ],
        ),
      ),
    );
  }
}

class JapaneseWordDetail extends StatelessWidget {
  final CatalogRecord word;
  final String spelling;
  final String reading;
  const JapaneseWordDetail({
    required this.word,
    required this.spelling,
    required this.reading,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final catalog = Services.of(context).catalog;
    final senses = allowedSenses(word, spelling, reading);
    return LearningPage(
      title: spelling,
      language: 'ja-JP',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(spelling, style: const TextStyle(fontSize: 32)),
          ReadButton('$reading · 点击朗读', reading, 'ja-JP'),
          const Notice('这里只显示适用于当前写法和读法的义项。自动振假名可能存在歧义；例句并不覆盖每个读法。'),
          if (senses.isEmpty) const Notice('原词库未提供适用于当前读法的义项。'),
          for (final sense in senses)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (sense['pos'] as List)
                          .map((p) => catalog.pos[p] ?? '词性待校对')
                          .join(' · '),
                    ),
                    ChineseText((sense['gloss'] as List).join('; ')),
                    for (final example in sense['examples']) ...[
                      if ((example['tokens'] as List).isNotEmpty)
                        RubyText(example['tokens'])
                      else
                        ReadButton(example['jp'], example['jp'], 'ja-JP'),
                      ChineseText(example['en']),
                      if ((example['source'] as String).isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            final uri = Uri.parse(
                              'https://tatoeba.org/ja/sentences/show/${example['source']}',
                            );
                            if (!await launchUrl(uri) && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('无法打开原句链接')),
                              );
                            }
                          },
                          child: const Text('查看 Tatoeba 原句与作者'),
                        ),
                    ],
                    if ((sense['examples'] as List).isEmpty)
                      const Notice('此义项未收录例句。'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
