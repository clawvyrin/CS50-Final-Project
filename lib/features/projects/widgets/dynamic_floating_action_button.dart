import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/profiles/widgets/profile_picture.dart';
import 'package:task_companion/features/projects/models/project_model.dart';
import 'package:task_companion/features/projects/providers/project_providers.dart';
import 'package:task_companion/features/tasks/models/task_model.dart';
import 'package:task_companion/features/tasks/providers/tasks_provider.dart';

class ProjectFloatingActionButton extends ConsumerWidget {
  final Project project;
  final TabController tabController;

  const ProjectFloatingActionButton({
    super.key,
    required this.project,
    required this.tabController,
  });

  void _showAddTaskDialog(
    String projectId,
    BuildContext context,
    WidgetRef ref,
  ) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    final taskState = ref.watch(taskActionsProvider);

    String? selectedAssigneeId;
    List<String> selectedDependencies = [];
    DateTime? furthestDepenceyDeadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("New Task"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  DropdownButtonFormField<String>(
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
                                  child: ProfilePicture(
                                    avatarUrl: m.user.avatarUrl!,
                                  ),
                                ),
                                title: Text(m.user.displayName),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedAssigneeId = val),
                  ),

                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: (project.tasks ?? []).map((t) {
                      final isSelected = selectedDependencies.contains(t.id);
                      return FilterChip(
                        label: Text(
                          t.title,
                          style: const TextStyle(fontSize: 10),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            selected
                                ? selectedDependencies.add(t.id)
                                : selectedDependencies.remove(t.id);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  ListTile(
                    title: const Text("Start date"),
                    subtitle: Text(selectedDate.toString().split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                            furthestDepenceyDeadline ?? project.startDate!,
                        lastDate: project.endDate!,
                      );
                      if (date != null) {
                        setDialogState(() => selectedDate = date);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text("Deadline"),
                    subtitle: Text(selectedDate.toString().split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                            furthestDepenceyDeadline ?? project.startDate!,
                        lastDate: project.endDate!,
                      );
                      if (date != null) {
                        setDialogState(() => selectedDate = date);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: taskState.isLoading
                  ? null
                  : () async {
                      await ref
                          .read(taskActionsProvider.notifier)
                          .createTask(
                            projectId: projectId,
                            title: titleController.text,
                            description: descController.text,
                            dueDate: selectedDate,
                            assignedTo: selectedAssigneeId,
                            dependencies: selectedDependencies,
                          );
                      if (context.mounted) context.pop();
                    },
              child: taskState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }

  void showDailyReportForm(
    String projectId,
    BuildContext context,
    Task task,
    WidgetRef ref,
  ) {
    final summaryController = TextEditingController();
    List<Map<String, dynamic>> tempActivities = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Rapport : ${task.title}"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: summaryController,
                    decoration: const InputDecoration(
                      labelText: "Résumé global de la journée",
                      hintText: "Ex: Progression conforme au planning...",
                    ),
                    maxLines: 2,
                  ),
                  const Divider(height: 30),
                  const Text(
                    "Actions effectuées (Activités)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  ...tempActivities.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var act = entry.value;
                    return Card(
                      color: Colors.blue.shade50,
                      child: ListTile(
                        title: Text(act['description']),
                        subtitle: Text(
                          "Ressources: ${act['resources'].length}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => setDialogState(
                            () => tempActivities.removeAt(idx),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 10),

                  TextButton.icon(
                    onPressed: () =>
                        _openAddActivitySubDialog(setDialogState, (newAct) {
                          tempActivities.add(newAct);
                        }, context),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Ajouter une action précise"),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: tempActivities.isEmpty
                  ? null
                  : () async {
                      // await ref
                      //     .read(taskActionsProvider.notifier)
                      //     .submitDailyReport(
                      //       taskId: task.id,
                      //       summary: summaryController.text,
                      //       activities: tempActivities,
                      //     );
                      // if (mounted) Navigator.pop(context);
                    },
              child: const Text("Envoyer le Rapport"),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddActivitySubDialog(
    Function setParentState,
    Function(Map<String, dynamic>) onAdded,
    BuildContext context,
  ) {
    final actDescController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Détail de l'action"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: actDescController,
              decoration: const InputDecoration(
                labelText: "Description (ex: Coulage béton)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              onAdded({'description': actDescController.text, 'resources': []});
              setParentState(() {});
              Navigator.pop(context);
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  void _showAddResourceDialog(String projectId, BuildContext context) {
    String selectedType = 'matériel';
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Ajouter une Ressource"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                items: ['matériel', 'main d\'oeuvre', 'équipement']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedType = v!),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nom (ex: Ciment)",
                ),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: "Quantité allouée",
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [/* ... boutons ... */],
        ),
      ),
    );
  }

  void _showAddMemberDialog(String projectId, BuildContext context) {
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Invite collaborator"),
        content: TextField(
          controller: idController,
          decoration: const InputDecoration(labelText: "Full Name"),
        ),
        actions: [/* ... boutons ... */],
      ),
    );
  }

  Widget _buildFAB(int index, BuildContext context, WidgetRef ref) {
    switch (index) {
      case 0:
        return FloatingActionButton(
          key: const ValueKey('add_task'),
          onPressed: () => _showAddTaskDialog(project.id, context, ref),
          child: const Icon(Icons.add_task),
        );
      case 2:
        return FloatingActionButton(
          key: const ValueKey('add_member'),
          onPressed: () => _showAddMemberDialog(project.id, context),
          child: const Icon(Icons.person_add),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(currentTabProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _buildFAB(index, context, ref),
    );
  }
}
