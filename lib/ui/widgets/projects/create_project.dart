import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/providers/project_list_providers.dart';
import 'package:task_companion/services/supabase_services.dart';

class CreateProject extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController descController;

  const CreateProject({
    super.key,
    required this.nameController,
    required this.descController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
    title: Text("New Project"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Nom"),
        ),
        TextField(
          controller: descController,
          decoration: const InputDecoration(labelText: "Description"),
        ),
      ],
    ),
    actions: [
      TextButton(onPressed: () => context.pop(), child: const Text("Cancel")),
      ElevatedButton(
        onPressed: () async {
          await SupabaseServices().createProject(
            nameController.text.trim(),
            descController.text.trim(),
          );
          if (context.mounted) {
            context.pop(context);
            ref.invalidate(projectListProvider);
          }
        },
        child: const Text("Créer"),
      ),
    ],
  );
}
