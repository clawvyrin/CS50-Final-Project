import 'package:flutter/material.dart';
import 'package:task_companion/features/tasks/models/resource_model.dart';

class ResourcesTab extends StatelessWidget {
  final List<Resource> resources;
  const ResourcesTab({super.key, required this.resources});

  @override
  Widget build(BuildContext context) {
    // Groupement par type
    final Map<String, List<Resource>> grouped = {};
    for (var r in resources) {
      grouped.putIfAbsent(r.type, () => []).add(r);
    }

    return ListView(
      children: grouped.entries.map((entry) {
        return ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            entry.key.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: entry.value
              .map(
                (r) => ListTile(
                  title: Text(r.name),
                  trailing: Text(
                    "${r.consumedAmount} / ${r.allocatedAmount} ${r.unit ?? ''}",
                  ),
                  subtitle: LinearProgressIndicator(
                    value: r.allocatedAmount > 0
                        ? r.consumedAmount / r.allocatedAmount
                        : 0,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              )
              .toList(),
        );
      }).toList(),
    );
  }
}
