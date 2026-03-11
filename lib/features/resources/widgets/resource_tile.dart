import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/projects/providers/project_providers.dart';
import 'package:task_companion/features/resources/models/resource_model.dart';
import 'package:task_companion/features/resources/services/resource_services.dart';
import 'package:task_companion/features/resources/widgets/edit_resource_dialog.dart';

class ResourceTile extends ConsumerWidget {
  final Resource resource;
  final String projectId;

  const ResourceTile({
    super.key,
    required this.resource,
    required this.projectId,
  });

  Future<bool> _editResource(BuildContext context, Resource resource) async {
    return await showDialog(
      context: context,
      builder: (context) => EditResourceDialog(resource: resource),
    );
  }

  Future _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete resource: ${resource.name}"),
          content: Text("Are you sure ?"),
          actions: [
            TextButton(
              onPressed: () => context.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(resourceServiceProvider)
                    .deleteResource(resource.id);

                ref.invalidate(projectDetailsProvider(projectId));

                if (context.mounted) context.pop();
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () async {
        bool updated = await _editResource(context, resource);

        if (updated) ref.invalidate(projectDetailsProvider(projectId));
      },
      onLongPress: () async => await _showDeleteDialog(context, ref),
      title: Text.rich(
        TextSpan(
          text: resource.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: " (${resource.type})",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      subtitle: Text.rich(
        TextSpan(
          text:
              "${resource.consumedAmount.toString()} / ${resource.allocatedAmount.toString()} ",
          children: [TextSpan(text: resource.unit)],
        ),
      ),
    );
  }
}
