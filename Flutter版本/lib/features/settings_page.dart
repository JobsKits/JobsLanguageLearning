// Created by Jobs on 2026年10月2日，星期五.
import 'package:flutter/material.dart';

import '../core/services.dart';

class SettingsPage extends StatefulWidget {
  final String? language;
  const SettingsPage({this.language, super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String language;
  late Future<List<Map<String, String>>> voices;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    language = widget.language ?? 'ru-RU';
    voices = Services.of(context).speech.voices(language);
  }

  @override
  Widget build(BuildContext context) {
    final services = Services.of(context);
    final settings = services.settings;
    final voice = settings.voices[language]!;
    return Scaffold(
      appBar: AppBar(title: const Text('主题与语音设置')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (_, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('阅读主题'),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('跟随系统')),
                ButtonSegment(value: ThemeMode.light, label: Text('白天')),
                ButtonSegment(value: ThemeMode.dark, label: Text('黑夜')),
              ],
              selected: {settings.theme},
              onSelectionChanged: (value) => settings.setTheme(value.first),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: language,
              decoration: const InputDecoration(labelText: '语种'),
              items: const [
                DropdownMenuItem(value: 'ru-RU', child: Text('俄语')),
                DropdownMenuItem(value: 'en-US', child: Text('英语')),
                DropdownMenuItem(value: 'ja-JP', child: Text('日语')),
              ],
              onChanged: (value) {
                if (value == null) return;
                services.speech.stop();
                setState(() {
                  language = value;
                  voices = services.speech.voices(language);
                });
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: voices,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('无法读取系统声音：${snapshot.error}');
                }
                if (!snapshot.hasData) return const LinearProgressIndicator();
                final values = snapshot.data!;
                if (values.isEmpty) {
                  return const Text('未安装此语种声音，请到系统语音设置安装后重启。');
                }
                final selected = values.indexWhere(
                  (v) =>
                      v['name'] == voice.voice?['name'] &&
                      v['locale'] == voice.voice?['locale'],
                );
                return DropdownButtonFormField<int>(
                  key: ValueKey('$language:$selected'),
                  isExpanded: true,
                  initialValue: selected < 0 ? -1 : selected,
                  decoration: const InputDecoration(labelText: '系统声音'),
                  items: [
                    const DropdownMenuItem(value: -1, child: Text('默认声音')),
                    for (var i = 0; i < values.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(
                          '${values[i]['name']} · ${values[i]['locale']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (index) {
                    voice.voice = index == null || index < 0
                        ? null
                        : values[index];
                    settings.saveVoice(language);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Text('语速 ${voice.rate.toStringAsFixed(2)}'),
            Slider(
              min: .1,
              max: .8,
              value: voice.rate,
              onChanged: (v) {
                voice.rate = v;
                settings.saveVoice(language);
              },
            ),
            Text('音量 ${(voice.volume * 100).round()}%'),
            Slider(
              value: voice.volume,
              onChanged: (v) {
                voice.volume = v;
                settings.saveVoice(language);
              },
            ),
            Text('重复 ${voice.repeats} 次'),
            Slider(
              min: 1,
              max: 5,
              divisions: 4,
              value: voice.repeats.toDouble(),
              onChanged: (v) {
                voice.repeats = v.round();
                settings.saveVoice(language);
              },
            ),
            Wrap(
              spacing: 12,
              children: [
                FilledButton(
                  onPressed: () => services.speech.read(
                    {
                      'ru-RU': 'Привет',
                      'en-US': 'Hello',
                      'ja-JP': 'こんにちは',
                    }[language]!,
                    language,
                  ),
                  child: const Text('试听'),
                ),
                OutlinedButton(
                  onPressed: services.speech.stop,
                  child: const Text('停止'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '使用系统 TTS，不等同于专业音素录音。英语、日语词典可离线查询；未安装的声音需在系统设置下载。机器中文释义为辅助资料，词库原有缺项如实保留。',
            ),
          ],
        ),
      ),
    );
  }
}
