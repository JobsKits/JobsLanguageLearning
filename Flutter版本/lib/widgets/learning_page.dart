// Created by Jobs on 2026年10月2日，星期五.
import 'package:flutter/material.dart';

import '../core/services.dart';
import '../features/settings_page.dart';

class LearningPage extends StatelessWidget {
  final String title;
  final Widget child;
  final String? language;
  const LearningPage({
    required this.title,
    required this.child,
    this.language,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final speech = Services.of(context).speech;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 66,
        leading: Navigator.canPop(context)
            ? TextButton(
                onPressed: () => Navigator.maybePop(context),
                child: const Text('返回'),
              )
            : null,
        title: Text(title),
        actions: [
          TextButton(onPressed: speech.stop, child: const Text('停止')),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsPage(language: language),
              ),
            ),
            child: const Text('设置'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: child),
            if (language != null)
              ListenableBuilder(
                listenable: speech,
                builder: (_, _) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: Text(
                    speech.status,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReadButton extends StatelessWidget {
  final String title;
  final String text;
  final String language;
  const ReadButton(this.title, this.text, this.language, {super.key});
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: text.isEmpty
        ? null
        : () => Services.of(context).speech.read(text, language),
    child: Text(title, textAlign: TextAlign.center),
  );
}

class Notice extends StatelessWidget {
  final String text;
  const Notice(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      text,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

class PageControls extends StatelessWidget {
  final int offset;
  final int total;
  final int size;
  final ValueChanged<int> onPage;
  const PageControls({
    required this.offset,
    required this.total,
    required this.size,
    required this.onPage,
    super.key,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: offset > 0 ? () => onPage(offset - size) : null,
          child: const Text('上一页'),
        ),
        Flexible(
          child: Text(
            '共 $total 条 · ${total == 0 ? 0 : offset + 1}–${(offset + size).clamp(0, total)}',
          ),
        ),
        TextButton(
          onPressed: offset + size < total ? () => onPage(offset + size) : null,
          child: const Text('下一页'),
        ),
      ],
    ),
  );
}
