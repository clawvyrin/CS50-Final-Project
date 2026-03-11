import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/profiles/widgets/profile_picture.dart';
import 'package:task_companion/features/projects/models/project_model.dart';
import 'package:task_companion/features/tasks/providers/tasks_provider.dart';
import 'package:task_companion/features/activity/widgets/add_activity_dialog.dart';
import 'package:task_companion/features/tasks/widgets/alert%20dialogs/task_depencies_picker.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  final Project project;
  const AddTaskDialog({super.key, required this.project});

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  DateTime selectedDueDate = DateTime.now().add(const Duration(days: 7));
  DateTime selectedStartDate = DateTime.now().add(const Duration(days: 7));

  String? selectedAssigneeId;
  List<Map<String, dynamic>> selectedDependencies = [];
  List<Map<String, dynamic>> selectedActivities = [];
  List<Map<String, dynamic>> projectResources = [];
  DateTime? furthestDepencyDeadline;
  late final Project project;

  @override
  void initState() {
    super.initState();
    project = widget.project;
    furthestDepencyDeadline = project.startDate;
    projectResources = project.resources!
        .map(
          (r) => {
            "name": r.name,
            "amount": r.allocatedAmount - r.consumedAmount,
            "id": r.id,
            "unit": r.unit,
          },
        )
        .toList();
  }

  TextField _textField(bool isTitle) {
    return TextField(
      controller: isTitle ? titleController : descController,
      decoration: InputDecoration(labelText: isTitle ? "Title" : "Description"),
    );
  }

  DropdownButtonFormField<String> _assigneePicker() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: "Assigned to"),
      // ignore: deprecated_member_use
      value: selectedAssigneeId,
      items: project.members
          ?.map(
            (m) => DropdownMenuItem(
              value: m.user.id,
              child: SizedBox(
                width: 200,
                child: ListTile(
                  leading: SizedBox(
                    height: 30,
                    width: 30,
                    child: ProfilePicture(avatarUrl: m.user.avatarUrl!),
                  ),
                  title: Text(m.user.displayName),
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (val) => setState(() => selectedAssigneeId = val),
    );
  }

  ListTile _manageDependencies() {
    return ListTile(
      title: const Text("Task dependencies"),
      subtitle: Text("${selectedDependencies.length} selected"),
      onTap: () async {
        List<String> currentIds = selectedDependencies
            .map((dep) => dep["id"].toString())
            .toList();

        final List<Map<String, dynamic>>? result = await showDialog(
          context: context,
          builder: (context) =>
              TaskDepenciesPicker(project: project, selected: currentIds),
        );

        if (result != null) {
          setState(() {
            selectedDependencies = result;
          });
        }
      },
    );
  }

  void _removeActivity(int index) {
    setState(() {
      final removedAct = selectedActivities.removeAt(index);
      final resourcesToReturn =
          removedAct["resources"] as List<Map<String, dynamic>>;

      for (var res in resourcesToReturn) {
        final prIndex = projectResources.indexWhere(
          (pr) => pr["id"] == res["id"],
        );
        if (prIndex != -1) {
          projectResources[prIndex]["amount"] += res["amount"];
        }
      }
    });
  }

  Widget _showCreatedActivities() {
    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text("Activities"),
        content: ListView.builder(
          shrinkWrap: true,
          itemCount: selectedActivities.length,
          itemBuilder: (context, index) {
            if (selectedActivities.isEmpty) return SizedBox.shrink();

            final activity = selectedActivities[index];
            List<Map<String, dynamic>> resources = activity["resources"];

            return ListTile(
              title: Text(activity["description"]),
              subtitle: Text(resources.map((r) => r["name"]).join(",")),
              trailing: IconButton(
                onPressed: () {
                  _removeActivity(index);
                  setDialogState(() {});
                  if (selectedActivities.isEmpty) context.pop();
                  setState(() {});
                },
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
            );
          },
        ),
      ),
    );
  }

  ListTile _activitiesManager() {
    return ListTile(
      // leading: const Icon(Icons.directions_run),
      title: const Text("Activities"),
      subtitle: Text(
        selectedActivities.isEmpty
            ? "No activities added"
            : "${selectedActivities.length} defined activities",
      ),
      trailing: IconButton(
        onPressed: () async {
          final Map<String, dynamic>? result = await showDialog(
            context: context,
            builder: (context) =>
                AddActivityDialog(availableResources: projectResources),
          );

          if (result != null) {
            setState(() {
              selectedActivities.add(result);

              final resourcesUsed =
                  result["resources"] as List<Map<String, dynamic>>;

              for (var usedRes in resourcesUsed) {
                final index = projectResources.indexWhere(
                  (pr) => pr["id"] == usedRes["id"],
                );

                if (index != -1) {
                  projectResources[index]["amount"] -= usedRes["amount"];
                }
              }
            });
          }
        },
        icon: Icon(Icons.add),
      ),
      onTap: () async {
        if (selectedActivities.isEmpty) return;
        await showDialog(
          context: context,
          builder: (context) => _showCreatedActivities(),
        );
      },
    );
  }

  ListTile _datePicker(bool isStartDate) {
    DateTime selectedDate = isStartDate ? selectedStartDate : selectedDueDate;

    return ListTile(
      title: Text("${isStartDate ? "Start" : "End"} date"),
      subtitle: Text(selectedDate.toString().split(' ')[0]),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: project.startDate!,
          firstDate: furthestDepencyDeadline ?? project.startDate!,
          lastDate: project.endDate!,
        );

        if (date != null) {
          setState(() {
            isStartDate ? selectedStartDate = date : selectedDueDate = date;
          });
        }
      },
    );
  }

  List<Widget>? _actionButtons() {
    final taskState = ref.watch(taskActionsProvider);
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Cancel"),
      ),
      ElevatedButton(
        onPressed: taskState.isLoading
            ? null
            : () async => _handleTaskCreation(),
        child: taskState.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text("Create"),
      ),
    ];
  }

  Future _handleTaskCreation() async {
    final Map<String, dynamic> taskData = {
      "project_id": project.id,
      "title": titleController.text.trim(),
      "description": descController.text.trim(),
      "start_date": selectedStartDate.toIso8601String(),
      "due_date": selectedDueDate.toIso8601String(),
      "assigned_to": selectedAssigneeId,
      "dependencies": selectedDependencies,
      "selected_activities": selectedActivities,
    };

    await ref.read(taskActionsProvider.notifier).createTask(taskData: taskData);

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text("New Task"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textField(true),
                _textField(false),
                _assigneePicker(),
                const SizedBox(height: 10),
                _manageDependencies(),
                _activitiesManager(),
                _datePicker(true),
                _datePicker(false),
              ],
            ),
          ),
        ),
        actions: _actionButtons(),
      ),
    );
  }
}
