import 'package:flutter/material.dart';
import 'package:task_companion/features/home/models/enums.dart';
import 'package:task_companion/features/projects/models/milestone_model.dart';

class MilestoneRow extends StatelessWidget {
  final List<Milestone> milestones;
  const MilestoneRow({super.key, required this.milestones});

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: milestones.length,
        itemBuilder: (context, index) {
          final m = milestones[index];
          final color = m.status == MilestoneStatus.achieved
              ? Colors.green
              : Colors.orange;

          return Container(
            width: 140,
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(12),
              color: color.withValues(alpha: 0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  m.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                ),
                Text(
                  m.originalDueDate.toString().split(' ')[0],
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
