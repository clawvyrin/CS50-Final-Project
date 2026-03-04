import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/models/profile_model.dart';
import 'package:task_companion/providers/profiles_provider.dart';
import 'package:task_companion/services/supabase_services.dart';
import 'package:task_companion/ui/widgets/create_project.dart';
import 'package:task_companion/ui/widgets/on_error.dart';
import 'package:task_companion/ui/widgets/on_loading.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  PreferredSizeWidget? _appBar(Profile user) {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Padding(
            padding: EdgeInsetsGeometry.only(left: 10),
            child: FastCachedImage(url: user.avatarUrl),
          ),
        ),
      ),
      title: Text("Home"),
      actions: [
        PlatformIconButton(
          onPressed: () => context.goNamed('notifications'),
          icon: Icon(Icons.notifications),
        ),
        PlatformIconButton(
          onPressed: () => context.goNamed('search'),
          icon: Icon(Icons.search),
        ),
      ],
    );
  }

  Widget _projectList() {
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (data, index) {
        return ListTile(title: Text("$index"));
      },
    );
  }

  Drawer _drawer(Profile user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.displayName),
            accountEmail: Text(user.email),
            currentAccountPicture: FastCachedImage(url: user.avatarUrl),
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

  void _createNewProject(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => CreateProject(
        nameController: nameController,
        descController: descController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(profileProvider(SupabaseServices.id!))
        .when(
          data: (Profile user) {
            return Scaffold(
              appBar: _appBar(user),
              drawer: _drawer(user),
              body: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(profileProvider(SupabaseServices.id!));
                },
                child: _projectList(),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _createNewProject(context),
                child: const Icon(Icons.add),
              ),
            );
          },
          error: (e, _) => OnError(e: e),
          loading: () => const OnLoading(),
        );
  }
}
