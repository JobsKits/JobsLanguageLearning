// Created by Jobs on 2026年10月2日，星期五.
import 'package:flutter/material.dart';

import '../core/services.dart';
import '../core/phonetics.dart';
import '../core/translation.dart';

class RubyText extends StatelessWidget {
  final List<dynamic> tokens;
  const RubyText(this.tokens, {super.key});
  @override
  Widget build(BuildContext context) {
    final text = tokens
        .map((t) => (t[1] as String).isNotEmpty && t[1] != '未识别' ? t[1] : t[0])
        .join();
    return Semantics(
      label: tokens.map((t) => t[0]).join(),
      button: true,
      child: InkWell(
        onTap: () =>
            Services.of(context).speech.read(spokenReading(text), 'ja-JP'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              for (final token in tokens)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      token[1],
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xffff8989)
                            : const Color(0xffb02035),
                      ),
                    ),
                    Text(token[0], style: const TextStyle(fontSize: 21)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChineseText extends StatefulWidget {
  final String source;
  const ChineseText(this.source, {super.key});
  @override
  State<ChineseText> createState() => _ChineseTextState();
}

class _ChineseTextState extends State<ChineseText> {
  Future<String>? text;
  bool busy = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    text ??= Services.of(context).catalog.chinese(widget.source);
  }

  @override
  void didUpdateWidget(ChineseText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      text = Services.of(context).catalog.chinese(widget.source);
    }
  }

  Future<void> generate() async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('生成中文辅助译文'),
        content: const Text(
          '首次使用可能需要下载语言模型。macOS 使用系统翻译；iOS / Android 使用设备端 ML Kit，并仅在 Wi-Fi 下载。机器译文需人工校对，成功后会保存到本机。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('生成'),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    setState(() => busy = true);
    try {
      final result = await ChineseTranslation.generate(widget.source);
      if (mounted) setState(() => text = Future.value('$result（机器译文，待校对）'));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('中文生成失败：$error')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: text,
    builder: (_, snapshot) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(snapshot.hasError ? '中文读取失败，可返回后重试' : snapshot.data ?? '正在读取中文…'),
        if (snapshot.data == '中文译文待补充' && ChineseTranslation.supported)
          TextButton(
            onPressed: busy ? null : generate,
            child: Text(busy ? '正在生成…' : '生成 / 重试中文译文'),
          ),
      ],
    ),
  );
}
