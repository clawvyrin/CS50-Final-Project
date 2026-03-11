import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/profiles/providers/collaborators_provider.dart';
import 'package:task_companion/features/profiles/widgets/profile_picture.dart';

class InviteCollaboratorsDialog extends ConsumerStatefulWidget {
  final String projectId;
  final List<String> alreadyMemberIds;

  const InviteCollaboratorsDialog({
    super.key,
    required this.projectId,
    this.alreadyMemberIds = const [],
  });

  @override
  ConsumerState<InviteCollaboratorsDialog> createState() =>
      _InviteCollaboratorsDialogState();
}

class _InviteCollaboratorsDialogState
    extends ConsumerState<InviteCollaboratorsDialog> {
  List<String> selectedIds = [];
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final collaboratorsAsync = ref.watch(allCollaboratorProvider(searchQuery));

    return AlertDialog(
      title: const Text("Invite collaborators"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: collaboratorsAsync.when(
                data: (users) {
                  final filteredUsers = users
                      .where(
                        (u) =>
                            u.displayName.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            ) &&
                            !widget.alreadyMemberIds.contains(u.id),
                      )
                      .toList();

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isSelected = selectedIds.contains(user.id);

                      return CheckboxListTile(
                        secondary: ProfilePicture(avatarUrl: user.avatarUrl),
                        title: Text(user.displayName),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            value!
                                ? selectedIds.add(user.id)
                                : selectedIds.remove(user.id);
                          });
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text("Error : $e"),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(null),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: selectedIds.isEmpty
              ? null
              : () => context.pop(selectedIds),
          child: Text("Add (${selectedIds.length}) member(s)"),
        ),
      ],
    );
  }
}
