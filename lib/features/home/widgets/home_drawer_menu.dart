import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/profiles/models/profile_model.dart';
import 'package:task_companion/features/profiles/widgets/profile_picture.dart';

class HomeDrawerMenu extends StatelessWidget {
  final Profile user;
  const HomeDrawerMenu({super.key, required this.user});

  @override
  Widget build(BuildContext context) => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(user.displayName),
          accountEmail: Text(user.email),
          currentAccountPicture: ProfilePicture(
            avatarUrl: user.avatarUrl,
            radius: 40,
          ),
          decoration: BoxDecoration(color: Colors.deepPurple),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ListTile(
            leading: Icon(PlatformIcons(context).settings),
            title: const Text('Settings'),
            onTap: () => context.goNamed('settings'),
          ),
        ),
      ],
    ),
  );
}
