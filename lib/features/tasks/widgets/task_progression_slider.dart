import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/tasks/models/task_model.dart';
import 'package:task_companion/features/tasks/services/task_services.dart';

class TaskProgressSlider extends ConsumerStatefulWidget {
  final Task task;
  const TaskProgressSlider({super.key, required this.task});

  @override
  ConsumerState<TaskProgressSlider> createState() => _TaskProgressSliderState();
}

class _TaskProgressSliderState extends ConsumerState<TaskProgressSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.task.progression;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("${_currentValue.toInt()}% achevé"),
        Slider(
          value: _currentValue,
          min: 0,
          max: 100,
          divisions: 10, // Par paliers de 10% pour aller vite
          label: "${_currentValue.toInt()}%",
          onChanged: widget.task.canEditProgress
              ? (value) => setState(() => _currentValue = value)
              : null,
          onChangeEnd: (value) async {
            if (!widget.task.canEditProgress) return;
            await ref
                .read(taskServiceProvider)
                .updateProgress(widget.task.id, value);

            // // Si 100%, on peut proposer de passer le statut en 'done'
            // if (value == 100) {
            //   _confirmTaskCompletion(context);
            // }
          },
        ),
        if (!widget.task.canEditProgress)
          const Text(
            "Read Only (Only asignee and owner can edit)",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
      ],
    );
  }
}
