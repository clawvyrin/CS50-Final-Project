import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/services/supabase_services.dart';

class CreateProject extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;

  const CreateProject({
    super.key,
    required this.nameController,
    required this.descController,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
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
            // Optionnel : ref.invalidate(projectsProvider) pour rafraîchir la liste
          }
        },
        child: const Text("Créer"),
      ),
    ],
  );
}
