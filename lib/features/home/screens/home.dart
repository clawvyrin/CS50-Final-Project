import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/profiles/models/profile_model.dart';
import 'package:task_companion/features/profiles/providers/profiles_provider.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/home/widgets/home_drawer_menu.dart';
import 'package:task_companion/features/home/widgets/project_list.dart';
import 'package:task_companion/features/profiles/widgets/profile_picture.dart';
import 'package:task_companion/features/projects/widgets/create_project.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';

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
          child: ProfilePicture(avatarUrl: user.avatarUrl),
        ),
      ),
      title: Text("Projects"),
      actions: [
        Stack(
          children: [
            PlatformIconButton(
              onPressed: () => context.goNamed('notifications'),
              icon: Icon(Icons.notifications),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.red,
                child: Text('9', style: const TextStyle(fontSize: 10)),
              ),
            ),
          ],
        ),
        PlatformIconButton(
          onPressed: () => context.goNamed('search'),
          icon: Icon(Icons.search),
        ),
      ],
    );
  }

  void _createNewProject(BuildContext context) {
    showDialog(context: context, builder: (context) => CreateProject());
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(profileProvider(AuthServices.id!))
        .when(
          data: (Profile user) {
            return Scaffold(
              appBar: _appBar(user),
              drawer: HomeDrawerMenu(user: user),
              body: ProjectList(),
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
