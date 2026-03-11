import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';
import 'package:task_companion/features/profiles/widgets/profile_card.dart';
import 'package:task_companion/features/profiles/widgets/profile_picture.dart';
import 'package:task_companion/features/search/providers/search_provider.dart';

class UsersSearchResultsList extends ConsumerWidget {
  const UsersSearchResultsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSearchAsync = ref.watch(userSearchProvider);

    return userSearchAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text("No user found."));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: ProfilePicture(avatarUrl: user.avatarUrl, radius: 20),
              title: Text(user.displayName),
              onTap: () => showDialog(
                context: context,
                builder: (context) {
                  return ProfileCard(user: user);
                },
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
    final projectSearchAsync = ref.watch(projectSearchProvider);

    return projectSearchAsync.when(
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
              onTap: () => context.pushNamed(
                'project',
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
    final taskSearchAsync = ref.watch(taskSearchProvider);

    return taskSearchAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(child: Text("No task found."));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              leading: const Icon(Icons.task, color: Colors.blue),
              title: Text(task.title),
              subtitle: Text(task.project.name),
              onTap: () => context.goNamed(
                'task_details',
                pathParameters: {
                  'projectId': task.project.id,
                  "taskId": task.id,
                },
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
