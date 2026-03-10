import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';
import 'package:task_companion/features/projects/models/project_member_model.dart';
import 'package:task_companion/features/projects/providers/project_member_provider.dart';

class MembersTab extends ConsumerWidget {
  final String projectId;
  final bool isOwner;
  const MembersTab({super.key, required this.projectId, required this.isOwner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(projectMembersProvider(projectId));

    return membersAsync.when(
      data: (members) => ListView.builder(
        shrinkWrap: true,
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(member.user.avatarUrl!),
            ),
            title: Text(member.user.displayName),
            subtitle: Text("Role : ${member.role.name.toUpperCase()}"),
            trailing: isOwner
                ? IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () => _confirmDeletion(context, ref, member),
                  )
                : SizedBox.shrink(),
          );
        },
      ),
      loading: () => OnLoading(),
      error: (e, _) => OnError(e: e),
    );
  }

  void _confirmDeletion(
    BuildContext context,
    WidgetRef ref,
    ProjectMember member,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove from project ?"),
        content: Text(
          "Do you really want to remove ${member.user.displayName} from this project ? "
          "He will no longer have access to tasks or reports.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref
                  .read(projectMembersProvider(projectId).notifier)
                  .removeMember(member.user.id);

              if (context.mounted) context.pop(context);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Collaborateur retiré")),
                );
              }
            },
            child: const Text("Retirer"),
          ),
        ],
      ),
    );
  }
}
