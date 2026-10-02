// Created by Jobs on 2026年10月2日，星期五.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChineseTranslation {
  static const channel = MethodChannel('jobs/chinese_translation');
  static bool get supported =>
      Platform.isMacOS || Platform.isAndroid || Platform.isIOS;
  static Future<String?> cached(String source) async {
    final prefs = await SharedPreferences.getInstance();
    final cache =
        jsonDecode(prefs.getString('chinese_translations') ?? '{}') as Map;
    return cache[source] as String?;
  }

  static Future<String> generate(String source) async {
    String result;
    if (Platform.isMacOS) {
      result = await channel.invokeMethod<String>('translate', source) ?? '';
    } else if (Platform.isAndroid || Platform.isIOS) {
      final manager = OnDeviceTranslatorModelManager();
      for (final language in [
        TranslateLanguage.english,
        TranslateLanguage.chinese,
      ]) {
        if (!await manager.isModelDownloaded(language.bcpCode)) {
          if (!await manager.downloadModel(
            language.bcpCode,
            isWifiRequired: true,
          )) {
            throw StateError('语言模型下载失败，请连接 Wi-Fi 后重试。');
          }
        }
      }
      final translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.chinese,
      );
      try {
        result = await translator.translateText(source);
      } finally {
        await translator.close();
      }
    } else {
      throw UnsupportedError('此平台保留内置中文，暂不支持按需生成。');
    }
    result = result.trim();
    if (!RegExp(r'[\u3400-\u9fff]').hasMatch(result) ||
        RegExp('[A-Za-z]').hasMatch(result)) {
      throw StateError('译文待校对，未作为中文释义保存。');
    }
    final prefs = await SharedPreferences.getInstance();
    final cache =
        jsonDecode(prefs.getString('chinese_translations') ?? '{}') as Map;
    cache[source] = result;
    await prefs.setString('chinese_translations', jsonEncode(cache));
    return result;
  }
}
