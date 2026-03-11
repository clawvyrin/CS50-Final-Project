import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/projects/models/project_model.dart';

class TaskDepenciesPicker extends StatefulWidget {
  final Project project;
  final List<String> selected;

  const TaskDepenciesPicker({
    super.key,
    required this.project,
    required this.selected,
  });

  @override
  State<TaskDepenciesPicker> createState() => _TaskDepenciesPickerState();
}

class _TaskDepenciesPickerState extends State<TaskDepenciesPicker> {
  List<String> _tempSelectedIds = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List<String>.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select dependencies"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.project.tasks?.length ?? 0,
          itemBuilder: (context, index) {
            final task = widget.project.tasks![index];
            final isSelected = _tempSelectedIds.contains(task.id);

            return CheckboxListTile(
              title: Text(task.title),
              subtitle: Text("Deadline: ${task.dueDate}"),
              value: isSelected,
              onChanged: (val) {
                setState(() {
                  if (isSelected) {
                    _tempSelectedIds.remove(task.id);
                  } else {
                    _tempSelectedIds.add(task.id);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(null),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _tempSelectedIds.isEmpty
              ? null
              : () {
                  final result = _tempSelectedIds.map((id) {
                    final t = widget.project.tasks!.firstWhere(
                      (task) => task.id == id,
                    );
                    return {"id": t.id, "dueDate": t.dueDate};
                  }).toList();
                  context.pop(result);
                },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
