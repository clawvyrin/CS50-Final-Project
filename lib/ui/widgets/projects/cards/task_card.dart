import 'package:flutter/material.dart';
import 'package:task_companion/models/enums.dart';
import 'package:task_companion/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: _buildStatusIcon(task.status),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Échéance : ${task.dueDate.day}/${task.dueDate.month}"),
        trailing: CircleAvatar(
          radius: 14,
          backgroundImage: task.assigneeAvatarUrl != null
              ? NetworkImage(task.assigneeAvatarUrl!)
              : null,
          child: task.assigneeAvatarUrl == null
              ? const Icon(Icons.person, size: 16)
              : null,
        ),
      ),
    );
  }

  Widget _buildStatusIcon(TaskStatus status) {
    // Une petite pastille de couleur selon le statut
    final color = status == TaskStatus.done ? Colors.green : Colors.orange;
    return Icon(Icons.check_circle_outline, color: color);
  }
}
