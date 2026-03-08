import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';
import 'package:task_companion/features/search/providers/search_provider.dart';

class UsersSearchResultsList extends ConsumerWidget {
  const UsersSearchResultsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(userSearchProvider)
        .when(
          data: (users) {
            if (users.isEmpty) {
              return const Center(child: Text("No user found."));
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(user.displayName)),
                  title: Text(user.displayName),
                  onTap: () => context.goNamed(
                    'direct_chat',
                    pathParameters: {'userId': user.id},
                  ),
                );
              },
            );
          },
          error: (e, _) => OnError(e: e),
          loading: () => OnLoading(),
        );
  }
}

class ProjectsSearchResultsList extends ConsumerWidget {
  const ProjectsSearchResultsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(projectSearchProvider)
        .when(
          data: (projects) {
            if (projects.isEmpty) {
              return const Center(child: Text("No project found."));
            }

            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
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
          },
          error: (e, _) => OnError(e: e),
          loading: () => OnLoading(),
        );
  }
}

class TasksSearchResultsList extends ConsumerWidget {
  const TasksSearchResultsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(taskSearchProvider)
        .when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return const Center(child: Text("No task found."));
            }

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  leading: const Icon(Icons.folder_open, color: Colors.blue),
                  title: Text(task.title),
                  onTap: () => context.goNamed(
                    'project_dashboard',
                    pathParameters: {'projectId': task.project.id},
                  ),
                );
              },
            );
          },
          error: (e, _) => OnError(e: e),
          loading: () => OnLoading(),
        );
  }
}
