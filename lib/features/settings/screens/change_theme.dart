import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/settings/providers/settings_provider.dart';

class ChangeTheme extends ConsumerWidget {
  const ChangeTheme({super.key});

  Future<void> _applyTheme(
    BuildContext context,
    WidgetRef ref,
    String newTheme,
  ) async {
    await ref.read(settingsProvider.notifier).updateSettings(theme: newTheme);
    if (context.mounted) context.pop();
  }

  StatelessWidget _isCurrentThemeCheck(
    ThemeMode themeOption,
    String currentTheme,
  ) {
    return themeOption.name.toLowerCase() == currentTheme
        ? Icon(Icons.check)
        : Container();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);

    String theme = settings.theme;
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.light_mode),
          title: Text("Light"),
          onTap: () async => _applyTheme(context, ref, "light"),
          trailing: _isCurrentThemeCheck(ThemeMode.light, theme),
        ),
        ListTile(
          leading: Icon(Icons.dark_mode),
          title: Text("Dark"),
          onTap: () async => _applyTheme(context, ref, "dark"),
          trailing: _isCurrentThemeCheck(ThemeMode.dark, theme),
        ),
        ListTile(
          leading: Icon(Icons.devices),
          title: Text("System"),
          onTap: () async => _applyTheme(context, ref, "system"),
          trailing: _isCurrentThemeCheck(ThemeMode.system, theme),
        ),
      ],
    );
  }
}
