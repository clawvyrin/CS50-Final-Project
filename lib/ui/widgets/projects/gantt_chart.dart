import 'package:flutter/material.dart';
import 'package:task_companion/models/task_model.dart';

class GanttChartWidget extends StatelessWidget {
  final List<Task> tasks;
  const GanttChartWidget({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text("No tasks found."));
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          width: 150,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue),
          ),
          child: Center(child: Text(task.title, textAlign: TextAlign.center)),
        );
      },
    );
  }
}
