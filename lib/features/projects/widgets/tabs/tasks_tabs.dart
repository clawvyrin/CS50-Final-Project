import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/core/utils/string_extensions.dart';
import 'package:task_companion/features/profiles/widgets/profile_picture.dart';
import 'package:task_companion/features/tasks/models/task_model.dart';

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
          trailing: IconButton(
            onPressed: () => context.pushNamed(
              'conversation',
              pathParameters: {'conversationId': t.conversationId},
            ),
            icon: Icon(Icons.open_in_new),
          ),
          leading: ProfilePicture(avatarUrl: t.assignee.avatarUrl!),
          title: Text(
            t.title.capitalize(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
