// Created by Jobs on 2026年10月2日，星期五.
import 'package:flutter/material.dart';

import 'repository.dart';
import 'settings.dart';
import 'speech.dart';

class Services extends InheritedWidget {
  final AppSettings settings;
  final SpeechService speech;
  final CatalogRepository catalog;
  const Services({
    required this.settings,
    required this.speech,
    required this.catalog,
    required super.child,
    super.key,
  });
  static Services of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Services>()!;
  @override
  bool updateShouldNotify(Services oldWidget) => settings != oldWidget.settings;
}
