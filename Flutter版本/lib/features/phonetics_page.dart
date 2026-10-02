// Created by Jobs on 2026年10月2日，星期五.
import 'package:flutter/material.dart';

import '../core/phonetics.dart';
import '../core/services.dart';
import '../widgets/learning_page.dart';

class PhoneticsPage extends StatefulWidget {
  final bool japanese;
  const PhoneticsPage({this.japanese = false, super.key});
  @override
  State<PhoneticsPage> createState() => _PhoneticsPageState();
}

class _PhoneticsPageState extends State<PhoneticsPage> {
  bool matrix = false;
  String consonant = russianConsonants.first;
  String get language => widget.japanese ? 'ja-JP' : 'ru-RU';
  @override
  Widget build(BuildContext context) => LearningPage(
    title: widget.japanese ? '日语元音 · 辅音 · 组合' : '俄语点读',
    language: language,
    child: widget.japanese ? _kana() : _russian(),
  );
  Widget _kana() => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      const Notice(
        '上方元音、左侧辅音行、内部组合都可点读。辅音以代表音节试听，不是孤立音素。し shi、ち chi、つ tsu、ふ fu 为特殊读法；を读 o；— 表示不存在的组合。',
      ),
      LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < 600 ? 600 : constraints.maxWidth,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: Center(child: Text('辅 / 元'))),
                    for (var i = 0; i < 5; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: ReadButton(
                            '${japaneseVowels[i]} ${katakana(japaneseVowels[i])}\n${romanVowels[i]}',
                            japaneseVowels[i],
                            language,
                          ),
                        ),
                      ),
                  ],
                ),
                for (final row in kanaRows)
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: ReadButton(
                            '${row.consonant} 行\n${row.kana[0]}',
                            row.kana[0],
                            language,
                          ),
                        ),
                      ),
                      for (var i = 0; i < 5; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: ReadButton(
                              row.readings[i].isEmpty
                                  ? '—'
                                  : '${row.kana[i]} ${katakana(row.kana[i])}\n${row.readings[i]}',
                              row.readings[i].isEmpty ? '' : row.kana[i],
                              language,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      const ReadButton('ん ン / n · 独立鼻音', 'ん', 'ja-JP'),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: () => Services.of(context).speech.readAll([
          ...japaneseVowels,
          for (final row in kanaRows)
            for (var i = 0; i < 5; i++)
              if (row.readings[i].isNotEmpty) row.kana[i],
          'ん',
        ], language),
        child: const Text('按顺序播放全表'),
      ),
    ],
  );
  Widget _russian() => Column(
    children: [
      const Notice(
        '10 元音、21 辅音、210 组合均可点读。· 为少见拼写，仅供探索；ъ、ь 为符号，不列入辅音。单个辅音可能读字母名称。',
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('分组')),
                ButtonSegment(value: true, label: Text('全表')),
              ],
              selected: {matrix},
              onSelectionChanged: (value) =>
                  setState(() => matrix = value.first),
            ),
            DropdownButton<String>(
              value: consonant,
              items: [
                for (final c in russianConsonants)
                  DropdownMenuItem(value: c, child: Text('辅音 $c')),
              ],
              onChanged: (c) => setState(() => consonant = c!),
            ),
            ReadButton('试听 $consonant', consonant, language),
            FilledButton(
              onPressed: () => Services.of(context).speech.readAll([
                for (final c in matrix ? russianConsonants : [consonant])
                  for (final v in russianVowels) c + v,
              ], language),
              child: Text(matrix ? '顺序播放全表' : '顺序播放本组'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: matrix
            ? _russianMatrix()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 10,
                itemBuilder: (_, i) {
                  final vowel = russianVowels[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ReadButton('元音 $vowel', vowel, language),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ReadButton(
                              '组合 $consonant$vowel${uncommon(consonant, vowel) ? ' ·' : ''}',
                              consonant + vowel,
                              language,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    ],
  );
  Widget _russianMatrix() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SizedBox(
      width: 1000,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 80, child: Center(child: Text('辅 / 元'))),
              for (final v in russianVowels)
                Expanded(child: ReadButton(v, v, language)),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                for (final c in russianConsonants)
                  Row(
                    children: [
                      SizedBox(width: 80, child: ReadButton(c, c, language)),
                      for (final v in russianVowels)
                        Expanded(
                          child: ReadButton(
                            '$c$v${uncommon(c, v) ? '·' : ''}',
                            c + v,
                            language,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
