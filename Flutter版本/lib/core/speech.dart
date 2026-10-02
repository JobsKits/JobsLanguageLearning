// Created by Jobs on 2026年10月2日，星期五.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'settings.dart';

class SpeechService extends ChangeNotifier {
  final FlutterTts engine;
  final AppSettings settings;
  String status = '点击读音播放';
  String current = '';
  bool playing = false;
  int _generation = 0;
  Future<void> _commands = Future.value();
  SpeechService(this.settings, {FlutterTts? engine})
    : engine = engine ?? FlutterTts() {
    this.engine.setErrorHandler((message) {
      _generation++;
      _update('发音失败：$message', false);
    });
  }
  void _update(String text, bool active) {
    status = text;
    playing = active;
    notifyListeners();
  }

  Future<void> stop() async {
    _generation++;
    _update('已停止', false);
    try {
      await engine.stop();
    } catch (error) {
      _update('无法停止语音：$error', false);
    }
  }

  Future<List<Map<String, String>>> voices(String language) async {
    final values = await engine.getVoices;
    if (values is! List) return [];
    return values
        .whereType<Map>()
        .where((item) {
          final locale = (item['locale'] ?? '').toString().replaceAll('_', '-');
          return locale.split('-').first == language.split('-').first;
        })
        .map(
          (item) => {
            'name': (item['name'] ?? '').toString(),
            'locale': (item['locale'] ?? '').toString(),
          },
        )
        .toList();
  }

  Future<void> read(String text, String language) => readAll([text], language);
  Future<void> readAll(List<String> texts, String language) async {
    final token = ++_generation;
    // 配置与停止按顺序执行，快速点读只允许最新一次开始播放。
    final preparation = _commands.then((_) async {
      if (token != _generation) return;
      await engine.stop();
      if (token != _generation) return;
      final available = await voices(language);
      if (available.isEmpty) {
        throw StateError(
          '未安装${{'ru-RU': '俄语', 'en-US': '英语', 'ja-JP': '日语'}[language]}语音，请在系统语音设置安装后重启。',
        );
      }
      final config = settings.voices[language]!;
      await engine.setLanguage(language);
      if (config.voice != null &&
          available.any((v) => v['name'] == config.voice!['name'])) {
        await engine.setVoice(config.voice!);
      } else {
        await engine.setVoice(available.first);
      }
      await engine.setSpeechRate(config.rate);
      await engine.setVolume(config.volume);
      await engine.awaitSpeakCompletion(true);
    });
    _commands = preparation.catchError((_) {});
    try {
      await preparation;
      if (token != _generation) return;
      final repeats = settings.voices[language]!.repeats;
      for (final text in texts.where((value) => value.trim().isNotEmpty)) {
        for (var i = 0; i < repeats; i++) {
          if (token != _generation) return;
          current = text;
          _update('正在朗读：$text · ${i + 1}/$repeats', true);
          final result = await engine
              .speak(text)
              .timeout(const Duration(seconds: 90));
          if (token != _generation) return;
          if (result == 0) throw StateError('系统语音未开始播放');
        }
      }
      if (token == _generation) _update('播放完成', false);
    } catch (error) {
      if (token == _generation) {
        await engine.stop();
        _update('发音暂不可用：$error', false);
      }
    }
  }
}
