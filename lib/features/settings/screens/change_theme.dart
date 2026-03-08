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

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    String value,
    String currentValue,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => _applyTheme(context, ref, value),
      trailing: RadioGroup<String>(
        groupValue: currentValue,
        onChanged: (_) => _applyTheme(context, ref, value),
        child: Radio<String>(value: value),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final String currentTheme = settings.theme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildThemeOption(
          context,
          ref,
          "Light",
          Icons.light_mode,
          "light",
          currentTheme,
        ),
        _buildThemeOption(
          context,
          ref,
          "Dark",
          Icons.dark_mode,
          "dark",
          currentTheme,
        ),
        _buildThemeOption(
          context,
          ref,
          "System",
          Icons.devices,
          "system",
          currentTheme,
        ),
      ],
    );
  }
}
