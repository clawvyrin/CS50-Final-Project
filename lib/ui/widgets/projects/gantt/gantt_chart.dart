import 'package:flutter/material.dart';
import 'package:task_companion/models/task_model.dart';
import 'package:task_companion/ui/widgets/projects/gantt/gantt_painter.dart';

class GanttChartWidget extends StatelessWidget {
  final List<Task> tasks;
  final DateTime projectStart;

  const GanttChartWidget({
    super.key,
    required this.tasks,
    required this.projectStart,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text("Aucune donnée temporelle"));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        width:
            2000, // Largeur fixe pour le scroll temporel (à rendre dynamique plus tard)
        child: CustomPaint(
          size: Size(2000, tasks.length * 40.0 + 50),
          painter: GanttPainter(tasks: tasks, projectStartDate: projectStart),
        ),
      ),
    );
  }
}
