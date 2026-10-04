// Created by Jobs on 2026年10月2日，星期五.
import 'dart:async';

import 'package:flutter/material.dart';

import '../core/repository.dart';
import '../core/services.dart';
import '../widgets/learning_page.dart';

class EnglishPage extends StatefulWidget {
  const EnglishPage({super.key});
  @override
  State<EnglishPage> createState() => _EnglishPageState();
}

class _EnglishPageState extends State<EnglishPage> {
  final TextEditingController searchController = TextEditingController();
  List<CatalogRecord> levels = [];
  String level = 'junior';
  String letter = '';
  String query = '';
  int offset = 0;
  Future<CatalogPage>? page;
  Timer? debounce;
  bool initialized = false;
  String? error;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      initialized = true;
      loadLevels();
    }
  }

  Future<void> loadLevels() async {
    try {
      final result = await Services.of(context).catalog.levels();
      if (!mounted) return;
      setState(() {
        levels = result;
        level = levels.first['id'];
        error = null;
        reload();
      });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  void reload() {
    page = Services.of(context).catalog
        .englishPage(level, letter, query, offset);
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LearningPage(
    title: '英语分级词典',
    titleWidget: LearningSearchField(
      controller: searchController,
      hint: '搜索单词或中文释义',
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
    language: 'en-US',
    child: Column(
      children: [
        if (error != null) ...[
          Notice('词库读取失败：$error'),
          TextButton(onPressed: loadLevels, child: const Text('重试')),
        ],
        if (levels.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              initialValue: level,
              isExpanded: true,
              decoration: const InputDecoration(labelText: '学习级别'),
              items: [
                for (final value in levels)
                  DropdownMenuItem(
                    value: value['id'] as String,
                    child: Text(value['name']),
                  ),
              ],
              onChanged: (value) => setState(() {
                level = value!;
                offset = 0;
                reload();
              }),
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final value in [
                '',
                ...'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''),
              ])
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: ChoiceChip(
                    label: Text(value.isEmpty ? '全部' : value),
                    selected: letter == value,
                    onSelected: (_) => setState(() {
                      letter = value;
                      offset = 0;
                      reload();
                    }),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: page == null
              ? (error == null
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox.shrink())
              : FutureBuilder(
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
                              ? const Center(child: Text('没有匹配单词'))
                              : ListView.builder(
                                  itemCount: result.rows.length,
                                  itemBuilder: (context, index) {
                                    final word = result.rows[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          word['word'],
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                        subtitle: Text(
                                          '${word['phonetic']}\n${(word['senses'] as List).take(2).map((s) => s['meaning']).join('；')}',
                                        ),
                                        trailing: ReadButton(
                                          '点读',
                                          word['word'],
                                          'en-US',
                                        ),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EnglishDetail(word: word),
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
                          size: 40,
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

class EnglishDetail extends StatelessWidget {
  final CatalogRecord word;
  const EnglishDetail({required this.word, super.key});
  @override
  Widget build(BuildContext context) => LearningPage(
    title: word['word'],
    language: 'en-US',
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(word['phonetic'], style: Theme.of(context).textTheme.titleLarge),
        ReadButton('朗读 ${word['word']}', word['word'], 'en-US'),
        const SizedBox(height: 16),
        for (final sense in word['senses'])
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${sense['pos']} · ${sense['meaning']}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if ((sense['english'] as String).isNotEmpty)
                    Text(sense['english']),
                ],
              ),
            ),
          ),
        const Notice('以下为词条级关联例句，不保证逐一对应上方每个义项。'),
        for (final example in word['examples'])
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReadButton(example['en'], example['en'], 'en-US'),
                  Text(example['zh']),
                ],
              ),
            ),
          ),
        for (final phrase in word['phrases'])
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReadButton(phrase['en'] ?? '', phrase['en'] ?? '', 'en-US'),
                  Text(phrase['zh'] ?? ''),
                ],
              ),
            ),
          ),
        if ((word['examples'] as List).isEmpty) const Notice('原词库未收录例句。'),
      ],
    ),
  );
}
