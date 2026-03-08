import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/profiles/providers/profiles_provider.dart';
import 'package:task_companion/features/projects/providers/project_providers.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';
import 'package:task_companion/features/projects/widgets/cards/project_card.dart';

class ProjectList extends ConsumerWidget {
  const ProjectList({super.key});

  Widget list(WidgetRef ref) {
    return ref
        .watch(projectsListProvider)
        .when(
          data: (projects) {
            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return ProjectCard(project: projects[index]);
              },
            );
          },
          error: (e, _) => OnError(e: e),
          loading: () => const OnLoading(),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => RefreshIndicator(
    onRefresh: () async {
      ref.invalidate(profileProvider(AuthServices.id!));
    },
    child: list(ref),
  );
}
