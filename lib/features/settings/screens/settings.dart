import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.light_mode),
            title: Text("Edit theme"),
            subtitle: Text(settings.theme),
            onTap: () async => await _changeTheme(context),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Log out"),
            onTap: () async => await AuthServices().signOut(),
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
