import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/projects/models/project_model.dart';
import 'package:task_companion/features/projects/providers/project_member_provider.dart';
import 'package:task_companion/features/projects/providers/project_providers.dart';
import 'package:task_companion/features/resources/services/resource_services.dart';
import 'package:task_companion/features/resources/widgets/add_resource_dialog.dart';
import 'package:task_companion/features/projects/widgets/alert%20dialogs/invite_collaborators_dialog.dart';
import 'package:task_companion/features/tasks/widgets/alert%20dialogs/add_task_dialog.dart';

class ProjectFloatingActionButton extends ConsumerWidget {
  final Project project;
  final TabController tabController;

  const ProjectFloatingActionButton({
    super.key,
    required this.project,
    required this.tabController,
  });

  void _showAddTaskDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AddTaskDialog(project: project),
    );
  }

  void _showAddMemberDialog(
    String projectId,
    BuildContext context,
    WidgetRef ref,
  ) async {
    final currentMemberIds =
        project.members?.map((m) => m.user.id).toList() ?? [];

    final List<String>? selectedIds = await showDialog<List<String>>(
      context: context,
      builder: (context) => InviteCollaboratorsDialog(
        projectId: projectId,
        alreadyMemberIds: currentMemberIds,
      ),
    );

    if (selectedIds != null && selectedIds.isNotEmpty) {
      await ref
          .read(projectMembersProvider(projectId).notifier)
          .addMembers(selectedIds);

      ref.invalidate(projectDetailsProvider(projectId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${selectedIds.length} added member(s)")),
        );
      }
    }
  }

  void _showAddResourceDialog(BuildContext context, WidgetRef ref) async {
    final Map<String, dynamic>? resource = await showDialog(
      context: context,
      builder: (context) => AddResourceDialog(),
    );

    if (resource == null) return null;

    resource["project_id"] = project.id;
    bool success = await ref
        .read(resourceServiceProvider)
        .addResource(resource);

    if (success) ref.invalidate(projectDetailsProvider(project.id));
  }

  Widget _buildFAB(int index, BuildContext context, WidgetRef ref) {
    switch (index) {
      case 1:
        return FloatingActionButton(
          key: const ValueKey('add_task'),
          onPressed: () => _showAddTaskDialog(context),
          child: const Icon(Icons.add_task),
        );
      case 2:
        return FloatingActionButton(
          key: const ValueKey('add_resource'),
          onPressed: () => _showAddResourceDialog(context, ref),
          child: const Icon(Icons.add_to_photos_outlined),
        );
      case 3:
        return FloatingActionButton(
          key: const ValueKey('add_member'),
          onPressed: () => _showAddMemberDialog(project.id, context, ref),
          child: const Icon(Icons.person_add),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(currentTabProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _buildFAB(index, context, ref),
    );
  }
}
