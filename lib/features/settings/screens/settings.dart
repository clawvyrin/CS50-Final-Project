import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/core/utils/string_extensions.dart';
import 'package:task_companion/features/settings/providers/settings_provider.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/settings/screens/change_theme.dart';
import 'package:task_companion/features/settings/widgets/delete_account.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  Future _changeTheme(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (builder) => ChangeTheme(),
    );
  }

  Icon getThemeIcon(String currentTheme) {
    switch (currentTheme) {
      case "light":
        return Icon(Icons.light_mode);

      case "dark":
        return Icon(Icons.dark_mode);

      default:
        return Icon(Icons.devices);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            leading: getThemeIcon(settings.theme),
            title: Text("Edit theme"),
            subtitle: Text(settings.theme.capitalize()),
            onTap: () async => await _changeTheme(context),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Log out"),
            onTap: () async {
              await ref.read(authServicesProvider).signOut();
              if (context.mounted) {
                context.pop();
                context.goNamed("auth");
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text("Delete account", style: TextStyle(color: Colors.red)),
            onTap: () async => await showDialog(
              context: context,
              builder: (context) =>
                  DeleteAccount(confirmController: TextEditingController()),
            ),
          ),
        ],
      ),
    );
  }
}
