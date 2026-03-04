import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/providers/profiles_provider.dart';
import 'package:task_companion/providers/project_list_providers.dart';
import 'package:task_companion/services/supabase_services.dart';
import 'package:task_companion/ui/widgets/on_error.dart';
import 'package:task_companion/ui/widgets/on_loading.dart';
import 'package:task_companion/ui/widgets/projects/project_tile.dart';

class ProjectList extends ConsumerWidget {
  const ProjectList({super.key});

  Widget list(WidgetRef ref) {
    return ref
        .watch(projectListProvider)
        .when(
          data: (projects) {
            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return ProjectTile(project: projects[index]);
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
      ref.invalidate(profileProvider(SupabaseServices.id!));
    },
    child: list(ref),
  );
}
