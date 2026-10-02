// Created by Jobs on 2026年10月2日，星期五.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceSettings {
  double rate;
  double volume;
  int repeats;
  Map<String, String>? voice;
  VoiceSettings({
    this.rate = .4,
    this.volume = 1,
    this.repeats = 1,
    this.voice,
  });
  Map<String, Object?> toJson() => {
    'rate': rate,
    'volume': volume,
    'repeats': repeats,
    'voice': voice,
  };
}

class AppSettings extends ChangeNotifier {
  final SharedPreferences preferences;
  ThemeMode theme = ThemeMode.system;
  final Map<String, VoiceSettings> voices = {};
  AppSettings(this.preferences) {
    final index = preferences.getInt('theme') ?? 0;
    theme = ThemeMode.values[index.clamp(0, 2)];
    for (final language in ['ru-RU', 'en-US', 'ja-JP']) {
      try {
        final data = jsonDecode(preferences.getString(language) ?? '{}') as Map;
        voices[language] = VoiceSettings(
          rate: ((data['rate'] ?? .4) as num).toDouble().clamp(.1, .8),
          volume: ((data['volume'] ?? 1) as num).toDouble().clamp(0, 1),
          repeats: ((data['repeats'] ?? 1) as num).toInt().clamp(1, 5),
          voice: data['voice'] == null
              ? null
              : Map<String, String>.from(data['voice']),
        );
      } catch (_) {
        voices[language] = VoiceSettings();
      }
    }
  }
  Future<void> setTheme(ThemeMode value) async {
    theme = value;
    notifyListeners();
    await preferences.setInt('theme', value.index);
  }

  Future<void> saveVoice(String language) async {
    notifyListeners();
    await preferences.setString(
      language,
      jsonEncode(voices[language]!.toJson()),
    );
  }
}
