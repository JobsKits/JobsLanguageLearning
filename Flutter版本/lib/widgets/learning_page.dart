// Created by Jobs on 2026年10月2日，星期五.
import 'package:flutter/material.dart';

import '../core/services.dart';
import '../features/settings_page.dart';

class LearningPage extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final Widget child;
  final String? language;
  const LearningPage({
    required this.title,
    required this.child,
    this.titleWidget,
    this.language,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final speech = Services.of(context).speech;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        leadingWidth: 66,
        leading: Navigator.canPop(context)
            ? TextButton(
                onPressed: () => Navigator.maybePop(context),
                child: const Text('返回'),
              )
            : null,
        titleSpacing: 8,
        title: titleWidget == null
            ? Text(title)
            : Transform.translate(
                offset: const Offset(0, -6),
                child: titleWidget,
              ),
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

class LearningSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const LearningSearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: 1,
    textInputAction: TextInputAction.search,
    onChanged: onChanged,
    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    decoration: InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class PinnedSectionHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  const PinnedSectionHeader({required this.child, this.height = 48});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Material(
    color: Theme.of(context).colorScheme.surface,
    elevation: overlapsContent ? 2 : 0,
    child: SizedBox(height: height, child: child),
  );

  @override
  bool shouldRebuild(covariant PinnedSectionHeader oldDelegate) =>
      height != oldDelegate.height || child != oldDelegate.child;
}

class ReadButton extends StatelessWidget {
  final String title;
  final String text;
  final String language;
  final String? annotation;
  final double? titleFontSize;
  final double? annotationFontSize;
  final double? minimumHeight;
  const ReadButton(
    this.title,
    this.text,
    this.language, {
    this.annotation,
    this.titleFontSize,
    this.annotationFontSize,
    this.minimumHeight,
    super.key,
  });
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: text.isEmpty
        ? null
        : () => Services.of(context).speech.read(text, language),
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: minimumHeight ?? 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: titleFontSize == null
                ? null
                : Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
          ),
          if (annotation != null) ...[
            const SizedBox(height: 2),
            Text(
              annotation!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: annotationFontSize,
              ),
            ),
          ],
        ],
      ),
    ),
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
  final bool showTotal;
  const PageControls({
    required this.offset,
    required this.total,
    required this.size,
    required this.onPage,
    this.showTotal = true,
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
        if (showTotal)
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
