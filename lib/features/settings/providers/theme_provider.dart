import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/settings/providers/settings_provider.dart';

final themeProvider = Provider<ThemeMode>((ref) {
  final settingsAsync = ref.watch(settingsProvider);

  switch (settingsAsync.theme) {
    case "dark":
      return ThemeMode.dark;
    case "light":
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
});
