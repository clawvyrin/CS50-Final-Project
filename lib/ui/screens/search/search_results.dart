import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/providers/search_provider.dart';

class UsersSearchResultsList extends ConsumerWidget {
  const UsersSearchResultsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userSearchProvider);

    if (users.value!.isEmpty) {
      return const Center(child: Text("Aucun collaborateur trouvé."));
    }

    return ListView.builder(
      itemCount: users.value!.length,
      itemBuilder: (context, index) {
        final user = users.value![index];
        return ListTile(
          leading: CircleAvatar(child: Text(user.displayName)),
          title: Text(user.firstName),
          onTap: () => context.goNamed(
            'direct_chat',
            pathParameters: {'userId': user.id},
          ),
        );
      },
    );
  }
}

class ProjectsSearchResultsList extends ConsumerWidget {
  const ProjectsSearchResultsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectSearchProvider);

    if (projects.value!.isEmpty) {
      return const Center(child: Text("Aucun projet trouvé."));
    }

    return ListView.builder(
      itemCount: projects.value!.length,
      itemBuilder: (context, index) {
        final project = projects.value![index];
        return ListTile(
          leading: const Icon(Icons.folder_open, color: Colors.blue),
          title: Text(project.name),
          onTap: () => context.goNamed(
            'project_dashboard',
            pathParameters: {'projectId': project.id},
          ),
        );
      },
    );
  }
}
