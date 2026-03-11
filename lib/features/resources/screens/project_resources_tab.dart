import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/resources/models/resource_model.dart';
import 'package:task_companion/features/resources/widgets/resource_tile.dart';

class ResourcesTab extends ConsumerWidget {
  final List<Resource> resources;
  final String projectId;

  const ResourcesTab({
    super.key,
    required this.resources,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return ResourceTile(resource: resource, projectId: projectId);
      },
    );
  }
}
