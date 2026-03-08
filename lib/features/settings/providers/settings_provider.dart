import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/settings/models/settings_model.dart';
import 'package:task_companion/core/data/shared_preferences_service.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(() {
  throw UnimplementedError("Must be overridden at startup");
});

class SettingsNotifier extends Notifier<Settings> {
  final Settings initialSettings;

  SettingsNotifier(this.initialSettings);

  @override
  Settings build() => initialSettings;

  Future<bool> updateSettings({
    String? theme,
    MutedNotifications? mutedNotifications,
  }) async {
    final current = state;

    final updated = current.copyWith(
      theme: theme ?? current.theme,
      mutedNotifications: mutedNotifications ?? current.mutedNotifications,
    );

    final success = await SharedPreferencesService().setSettings(updated);

    if (!success) return false;

    state = updated;

    return true;
  }
}
