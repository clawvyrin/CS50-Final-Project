import 'package:flutter/material.dart';
import 'package:task_companion/models/activity_model.dart';

class ActivitiesTab extends StatelessWidget {
  final List<Activity> activities;
  const ActivitiesTab({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: activities.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final a = activities[index];
        return ListTile(
          leading: const Icon(Icons.history_toggle_off),
          title: Text(a.description ?? "Description less activity"),
          subtitle: Text(a.createdAt?.toLocal().toString().split('.')[0] ?? ""),
        );
      },
    );
  }
}
