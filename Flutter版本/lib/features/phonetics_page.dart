// Created by Jobs on 2026年10月2日，星期五.
import 'package:flutter/material.dart';

import '../core/phonetics.dart';
import '../core/services.dart';
import '../widgets/learning_page.dart';

class PhoneticsPage extends StatefulWidget {
  final bool japanese;
  final PronunciationCourse? course;
  const PhoneticsPage({this.japanese = false, this.course, super.key});
  @override
  State<PhoneticsPage> createState() => _PhoneticsPageState();
}

class _PhoneticsPageState extends State<PhoneticsPage> {
  bool matrix = false;
  String consonant = russianConsonants.first;
  String coda = '';
  String get language =>
      widget.course?.language ?? (widget.japanese ? 'ja-JP' : 'ru-RU');

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    if (course != null) {
      consonant = course.consonants.first;
      if (course.codas.isNotEmpty) coda = course.codas.first;
    }
  }

  @override
  Widget build(BuildContext context) => LearningPage(
    title:
        widget.course?.title ?? (widget.japanese ? '日语元音 · 辅音 · 组合' : '俄语点读'),
    language: language,
    child: widget.japanese
        ? _kana()
        : widget.course == null
        ? _russian()
        : _additionalCourse(),
  );
  Widget _kana() => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      const Notice(
        '上方元音、左侧辅音行、内部组合都可点读。每格附 Hepburn 罗马字与宽式 IPA；辅音以代表音节试听，不是孤立音素。し shi、ち chi、つ tsu、ふ fu 为特殊读法；を读 o，ん会随语境变化。— 表示不存在的组合。',
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
                            '${japaneseVowels[i]} ${katakana(japaneseVowels[i])}',
                            japaneseVowels[i],
                            language,
                            annotation:
                                '${romanVowels[i]} /${kanaIpaFor(japaneseVowels[i])}/',
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
                            annotation:
                                '${row.readings[0]} /${kanaIpaFor(row.kana[0])}/',
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
                                  : '${row.kana[i]} ${katakana(row.kana[i])}',
                              row.readings[i].isEmpty ? '' : row.kana[i],
                              language,
                              annotation: row.readings[i].isEmpty
                                  ? null
                                  : '${row.readings[i]} /${kanaIpaFor(row.kana[i])}/',
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
      const ReadButton('ん ン · 独立鼻音', 'ん', 'ja-JP', annotation: 'n /ɴ/'),
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
            ReadButton(
              '试听 $consonant',
              consonant,
              language,
              annotation: russianHintForConsonant(consonant),
            ),
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
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Expanded(child: Center(child: Text('元音'))),
                              SizedBox(width: 12),
                              Expanded(child: Center(child: Text('辅音 + 元音'))),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _russianButton(
                                  vowel,
                                  vowel,
                                  russianHintForVowel(vowel),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _russianButton(
                                  '$consonant$vowel${uncommon(consonant, vowel) ? ' ·' : ''}',
                                  consonant + vowel,
                                  russianHintForSyllable(consonant, vowel),
                                ),
                              ),
                            ],
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
                Expanded(child: _russianButton(v, v, russianHintForVowel(v))),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                for (final c in russianConsonants)
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: _russianButton(c, c, russianHintForConsonant(c)),
                      ),
                      for (final v in russianVowels)
                        Expanded(
                          child: _russianButton(
                            '$c$v${uncommon(c, v) ? '·' : ''}',
                            c + v,
                            russianHintForSyllable(c, v),
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

  Widget _russianButton(String title, String text, String annotation) =>
      ReadButton(
        title,
        text,
        language,
        annotation: annotation,
        titleFontSize: _glyphFontSize(title),
        annotationFontSize: 11,
        minimumHeight: 64,
      );

  double _glyphFontSize(String value) {
    final count = value.runes.length;
    if (count <= 2) return 26;
    if (count == 3) return 22;
    return 18;
  }

  Widget _additionalCourse() {
    final course = widget.course!;
    final onsetName = course.isHangul ? '声母' : '辅音';
    return Column(
      children: [
        Notice(course.notice),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
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
                  for (final value in course.consonants)
                    DropdownMenuItem(
                      value: value,
                      child: Text('$onsetName $value'),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => consonant = value);
                },
              ),
              if (course.codas.isNotEmpty)
                DropdownButton<String>(
                  value: coda,
                  items: [
                    for (final value in course.codas)
                      DropdownMenuItem(
                        value: value,
                        child: Text(value.isEmpty ? '无收音' : '收音 $value'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => coda = value);
                  },
                ),
              FilledButton(
                onPressed: () => Services.of(context).speech.readAll([
                  for (final onset in matrix ? course.consonants : [consonant])
                    for (final vowel in course.vowels)
                      ?course.syllable(onset, vowel, coda),
                ], course.language),
                child: Text(matrix ? '顺序播放全表' : '顺序播放本组'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: matrix ? _courseMatrix(course) : _courseRows(course)),
      ],
    );
  }

  Widget _courseRows(PronunciationCourse course) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: course.vowels.length,
      itemBuilder: (context, index) {
        final vowel = course.vowels[index];
        final syllable = course.syllable(consonant, vowel, coda);
        final marker = course.isRare(consonant) ? ' ·' : '';
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: ReadButton(
                    course.displayVowel(vowel),
                    course.speechTextForVowel(vowel),
                    language,
                    annotation: course.pronunciationHintForVowel(vowel),
                    titleFontSize: _glyphFontSize(course.displayVowel(vowel)),
                    annotationFontSize: 11,
                    minimumHeight: 64,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ReadButton(
                    '${syllable ?? '—'}$marker',
                    syllable ?? '',
                    language,
                    annotation: syllable == null
                        ? null
                        : course.pronunciationHint(consonant, vowel, coda),
                    titleFontSize: _glyphFontSize('${syllable ?? '—'}$marker'),
                    annotationFontSize: 11,
                    minimumHeight: 64,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _courseMatrix(PronunciationCourse course) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 88 + course.vowels.length * 84,
          height: constraints.maxHeight,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Center(
                      child: Text(course.isHangul ? '声 / 元' : '辅 / 元'),
                    ),
                  ),
                  for (final vowel in course.vowels)
                    Expanded(
                      child: ReadButton(
                        course.displayVowel(vowel),
                        course.speechTextForVowel(vowel),
                        language,
                        annotation: course.pronunciationHintForVowel(vowel),
                        titleFontSize: _glyphFontSize(
                          course.displayVowel(vowel),
                        ),
                        annotationFontSize: 11,
                        minimumHeight: 64,
                      ),
                    ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final onset in course.consonants)
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: ReadButton(
                              onset,
                              onset,
                              language,
                              annotation: course.pronunciationHintForConsonant(
                                onset,
                              ),
                              titleFontSize: _glyphFontSize(onset),
                              annotationFontSize: 11,
                              minimumHeight: 64,
                            ),
                          ),
                          for (final vowel in course.vowels)
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final syllable = course.syllable(
                                    onset,
                                    vowel,
                                    coda,
                                  );
                                  final marker = course.isRare(onset)
                                      ? '·'
                                      : '';
                                  return ReadButton(
                                    '${syllable ?? '—'}$marker',
                                    syllable ?? '',
                                    language,
                                    annotation: syllable == null
                                        ? null
                                        : course.pronunciationHint(
                                            onset,
                                            vowel,
                                            coda,
                                          ),
                                    titleFontSize: _glyphFontSize(
                                      '${syllable ?? '—'}$marker',
                                    ),
                                    annotationFontSize: 11,
                                    minimumHeight: 64,
                                  );
                                },
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
      ),
    );
  }
}
