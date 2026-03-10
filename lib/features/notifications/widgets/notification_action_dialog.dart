import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationActionDialog extends ConsumerWidget {
  final String title;
  final String content;
  final Function(bool) onAction;

  const NotificationActionDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      TextButton(
        child: const Text("Decline", style: TextStyle(color: Colors.red)),
        onPressed: () {
          onAction(false);
          Navigator.pop(context);
        },
      ),
      ElevatedButton(
        onPressed: () {
          onAction(true);
          Navigator.pop(context);
        },
        child: const Text("Accept"),
      ),
    ],
  );
}
