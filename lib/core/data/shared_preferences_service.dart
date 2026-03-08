import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_companion/core/log/logger.dart';
import 'package:task_companion/features/settings/models/settings_model.dart';

class SharedPreferencesService {
  String themeKey = "theme";
  String settingsKey = "settings";

  Future<bool> setTheme(String theme) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(themeKey, theme);
      return success;
    } catch (e, st) {
      appLogger.e(
        "Error setting theme",
        error: e,
        stackTrace: st,
        time: DateTime.now(),
      );
      return false;
    }
  }

  Future<String> loadTheme() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String theme = prefs.getString(themeKey) ?? "light";
      return theme;
    } catch (e, st) {
      appLogger.e(
        "Error loading theme",
        error: e,
        stackTrace: st,
        time: DateTime.now(),
      );
      return "light";
    }
  }

  Future<bool> setSettings(Settings settings) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(
        settingsKey,
        jsonEncode(settings.toJson()),
      );
      return success;
    } catch (e, st) {
      appLogger.e(
        "Error updating settings",
        error: e,
        stackTrace: st,
        time: DateTime.now(),
      );
      return false;
    }
  }

  Future<Settings> loadSettings() async {
    Map<String, dynamic> settings = {
      "theme": "system",
      "mute_notifications_from": {"users": [], "tasks": [], "projects": []},
    };

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String encodedSettings =
          prefs.getString(settingsKey) ?? jsonEncode(settings);

      return Settings.fromJson(jsonDecode(encodedSettings));
    } catch (e, st) {
      appLogger.e(
        "Error loading settings",
        error: e,
        stackTrace: st,
        time: DateTime.now(),
      );
      return Settings.fromJson(settings);
    }
  }
}
