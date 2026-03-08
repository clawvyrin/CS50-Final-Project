import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/profiles/models/profile_model.dart';
import 'package:task_companion/features/projects/models/project_member_model.dart';
import 'package:task_companion/features/projects/providers/project_member_provider.dart';

class MembersTab extends ConsumerWidget {
  final String projectId;
  const MembersTab({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(projectMembersProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Équipe du projet"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddMemberSearch(context, ref),
          ),
        ],
      ),
      body: membersAsync.when(
        data: (members) => ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(member.user.avatarUrl!),
              ),
              title: Text(member.user.displayName),
              subtitle: Text("Rôle : ${member.role.name.toUpperCase()}"),
              trailing: IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                ),
                onPressed: () => _confirmDeletion(context, ref, member),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur : $e")),
      ),
    );
  }

  void _showAddMemberSearch(BuildContext context, WidgetRef ref) {
    context.pushNamed(
      'global_search',
      extra: (Profile selectedProfile) {
        ref
            .read(projectMembersProvider(projectId).notifier)
            .addMember(selectedProfile.id, 'worker');
        context.pop(context);
      },
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
        title: const Text("Retirer du projet ?"),
        content: Text(
          "Voulez-vous vraiment retirer ${member.user.displayName} de ce projet ? "
          "Il n'aura plus accès aux tâches ni aux rapports.",
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
