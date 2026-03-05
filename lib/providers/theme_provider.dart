import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    // On pourrait charger ici de manière asynchrone,
    // mais pour le build synchrone de Riverpod,
    // on initialise souvent par défaut et on met à jour ensuite.
    return ThemeMode.system;
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveTheme();
  }

  // Optionnel : charger depuis les SharedPreferences au démarrage
  Future<void> loadTheme(SharedPreferences prefs) async {
    final savedTheme = prefs.getString(_key);
    if (savedTheme == 'dark') state = ThemeMode.dark;
    if (savedTheme == 'light') state = ThemeMode.light;
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state == ThemeMode.dark ? 'dark' : 'light');
  }
}
