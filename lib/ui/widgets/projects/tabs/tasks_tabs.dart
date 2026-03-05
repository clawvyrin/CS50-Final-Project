import 'package:flutter/material.dart';
import 'package:task_companion/models/task_model.dart';

class TasksTab extends StatelessWidget {
  final List<Task> tasks;
  const TasksTab({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final t = tasks[index];
        return ExpansionTile(
          leading: CircleAvatar(child: Text(t.title[0])),
          title: Text(t.title),
          subtitle: Text("Status: ${t.status.name}"),
          children: [
            ListTile(title: Text("Description: ${t.description ?? 'N/A'}")),
            ListTile(
              title: Text("Deadline: ${t.dueDate.toString().split(' ')[0]}"),
            ),
          ],
        );
      },
    );
  }
}
