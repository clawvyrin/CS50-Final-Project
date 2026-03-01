import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/models/profile_model.dart';
import 'package:task_companion/providers/profiles_provider.dart';
import 'package:task_companion/services/supabase_services.dart';
import 'package:task_companion/ui/widgets/on_error.dart';
import 'package:task_companion/ui/widgets/on_loading.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  PreferredSizeWidget? appBar(Profiles user) {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Padding(
            padding: EdgeInsetsGeometry.only(left: 10),
            child: CircleAvatar(
              radius: 30,
              foregroundImage: NetworkImage(user.avatarUrl),
            ),
          ),
        ),
      ),
      title: Text("Home"),
      actions: [
        PlatformIconButton(
          onPressed: () async {
            bool success = await SupabaseServices().signOut();
            if (mounted && success) {
              context.goNamed('auth');
            }
          },
          icon: Icon(Icons.logout, color: Colors.red),
        ),
      ],
    );
  }

  Widget projectList() {
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (data, index) {
        return ListTile(title: Text("$index"));
      },
    );
  }

  Drawer drawer(Profiles user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.displayName),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              foregroundImage: NetworkImage(user.avatarUrl),
            ),
            decoration: BoxDecoration(color: Colors.deepPurple),
          ),
          ListTile(
            leading: Icon(PlatformIcons(context).settings),
            title: const Text('Paramètres'),
            onTap: () => {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(profileProvider(SupabaseServices.id!))
        .when(
          data: (Profiles user) {
            return Scaffold(
              appBar: appBar(user),
              drawer: drawer(user),
              body: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(profileProvider(SupabaseServices.id!));
                },
                child: projectList(),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => [],
                child: const Icon(Icons.add),
              ),
            );
          },
          error: (e, _) => OnError(e: e),
          loading: () => const OnLoading(),
        );
  }
}
