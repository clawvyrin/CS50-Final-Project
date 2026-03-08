import 'package:flutter/material.dart';
import 'package:task_companion/features/home/models/enums.dart';
import 'package:task_companion/features/tasks/models/task_model.dart';

class GanttPainter extends CustomPainter {
  final List<Task> tasks;
  final DateTime projectStartDate;
  final double dayWidth = 40.0;
  final double rowHeight = 40.0;

  GanttPainter({required this.tasks, required this.projectStartDate});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBar = Paint()..style = PaintingStyle.fill;
    final paintLine = Paint()
      ..color = Colors.grey.withValues(alpha: .3)
      ..strokeWidth = 1.0;

    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final yOffset = i * rowHeight + 20;

      final taskStart = task.dueDate.subtract(const Duration(days: 3));
      final startOffset =
          taskStart.difference(projectStartDate).inDays * dayWidth;
      final taskWidth = 3 * dayWidth;

      paintBar.color = _getStatusColor(task.status);
      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(startOffset, yOffset, taskWidth, 20),
        const Radius.circular(4),
      );
      canvas.drawRRect(rRect, paintBar);

      TextPainter(
          text: TextSpan(
            text: task.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout()
        ..paint(canvas, Offset(startOffset, yOffset - 15));

      canvas.drawLine(
        Offset(0, yOffset + 25),
        Offset(size.width, yOffset + 25),
        paintLine,
      );

      final arrowPaint = Paint()
        ..color = Colors.black54
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        if (task.dependencies == null || task.dependencies!.isEmpty) continue;

        for (var dep in task.dependencies!) {
          final parentIndex = tasks.indexWhere(
            (t) => t.id == dep.dependency.id,
          );
          if (parentIndex == -1) continue;

          final parentTask = tasks[parentIndex];
          final parentStart = parentTask.dueDate.subtract(
            const Duration(days: 3),
          );
          final parentX =
              (parentStart.difference(projectStartDate).inDays + 3) * dayWidth;
          final parentY =
              parentIndex * rowHeight + 20 + 10;

          final childStart = task.dueDate.subtract(const Duration(days: 3));
          final childX =
              childStart.difference(projectStartDate).inDays * dayWidth;
          final childY = i * rowHeight + 20 + 10;

          final path = Path()
            ..moveTo(parentX, parentY)
            ..lineTo(parentX + 10, parentY)
            ..lineTo(parentX + 10, childY)
            ..lineTo(childX, childY); 

          canvas.drawPath(path, arrowPaint);

          final arrowHead = Path()
            ..moveTo(childX, childY)
            ..lineTo(childX - 5, childY - 3)
            ..lineTo(childX - 5, childY + 3)
            ..close();
          canvas.drawPath(arrowHead, Paint()..color = Colors.black54);
        }
      }
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.done:
        return Colors.green;
      case TaskStatus.inProgress:
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
