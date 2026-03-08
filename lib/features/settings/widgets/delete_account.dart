import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';

class DeleteAccount extends ConsumerWidget {
  final TextEditingController confirmController;
  const DeleteAccount({super.key, required this.confirmController});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
    title: Text("Are you sure ?", style: TextStyle(color: Colors.red)),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: confirmController,
          decoration: const InputDecoration(
            labelText: "Enter 'DELETE' to confirm",
          ),
        ),
      ],
    ),
    actions: [
      TextButton(onPressed: () => context.pop(), child: const Text("Cancel")),
      ElevatedButton(
        onPressed: () async {
          if (confirmController.text.trim().toLowerCase() != "delete") return;

          await ref.read(authServicesProvider).deleteAccount();
          await ref.read(authServicesProvider).signOut();
          if (context.mounted) {
            context.pop(context);
            context.goNamed("auth");
          }
        },
        child: const Text("Delete", style: TextStyle(color: Colors.red)),
      ),
    ],
  );
}
