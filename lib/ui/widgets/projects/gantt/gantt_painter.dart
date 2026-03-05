import 'package:flutter/material.dart';
import 'package:task_companion/models/enums.dart';
import 'package:task_companion/models/task_model.dart';

class GanttPainter extends CustomPainter {
  final List<Task> tasks;
  final DateTime projectStartDate;
  final double dayWidth = 40.0; // Largeur d'un jour en pixels
  final double rowHeight = 40.0; // Hauteur d'une ligne de tâche

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

      // 1. Calculer la position X (Début de la tâche par rapport au projet)
      // Note: Pour ce MVP, on utilise la date d'échéance moins 3 jours comme début fictif
      // car ton modèle actuel n'a qu'une 'dueDate'.
      final taskStart = task.dueDate.subtract(const Duration(days: 3));
      final startOffset =
          taskStart.difference(projectStartDate).inDays * dayWidth;
      final taskWidth = 3 * dayWidth; // Durée fixe de 3 jours pour l'exemple

      // 2. Dessiner la barre de la tâche
      paintBar.color = _getStatusColor(task.status);
      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(startOffset, yOffset, taskWidth, 20),
        const Radius.circular(4),
      );
      canvas.drawRRect(rRect, paintBar);

      // 3. Dessiner le texte du titre
      // 3. Dessiner le texte du titre
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
        ..layout() // On garde la cascade ici pour pouvoir appeler paint juste après
        ..paint(canvas, Offset(startOffset, yOffset - 15));

      // 4. Ligne de séparation horizontale
      canvas.drawLine(
        Offset(0, yOffset + 25),
        Offset(size.width, yOffset + 25),
        paintLine,
      );
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
