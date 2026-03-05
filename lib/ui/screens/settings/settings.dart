import 'package:flutter/material.dart';
import 'package:task_companion/services/auth_services.dart';
import 'package:task_companion/ui/widgets/settings/delete_account.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.sunny),
            title: Text("Edit theme"),
            onTap: () async => await AuthServices().signOut(),
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
