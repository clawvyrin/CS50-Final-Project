import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/models/project_model.dart';
import 'package:task_companion/models/task_model.dart';
import 'package:task_companion/providers/tasks_provider.dart';

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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("New Task"),
          content: Column(
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
                        value: m.userId,
                        child: ListTile(
                          leading: FastCachedImage(url: m.avatarUrl),
                          title: Text(m.displayName),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) =>
                    setDialogState(() => selectedAssigneeId = val),
              ),

              const SizedBox(height: 10),
              const Text(
                "Depends on :",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Wrap(
                spacing: 8,
                children: (project.tasks ?? []).map((t) {
                  final isSelected = selectedDependencies.contains(t.id);
                  return FilterChip(
                    label: Text(t.title, style: const TextStyle(fontSize: 10)),
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
                title: const Text("Deadline"),
                subtitle: Text(selectedDate.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setDialogState(() => selectedDate = date);
                },
              ),
            ],
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
                            assignedTo: selectedAssigneeId, // <-- Nouveau
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

                  // Liste des activités ajoutées
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
                  ? null // On n'envoie pas un rapport vide
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
            // Ici tu pourrais ajouter un sélecteur de ressources
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              onAdded({
                'description': actDescController.text,
                'resources': [], // À remplir selon ton sélecteur
              });
              setParentState(
                () {},
              ); // Force le rafraîchissement du dialogue parent
              Navigator.pop(context);
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

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
        title: const Text("Inviter un membre"),
        content: TextField(
          controller: idController,
          decoration: const InputDecoration(
            labelText: "ID Utilisateur ou Email",
          ),
        ),
        actions: [/* ... boutons ... */],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (tabController.index) {
      case 0: // Tasks
        return FloatingActionButton(
          onPressed: () => _showAddTaskDialog(project.id, context, ref),
          child: const Icon(Icons.add_task),
        );
      case 2: // Resources
        return FloatingActionButton(
          onPressed: () => _showAddResourceDialog(project.id, context),
          child: const Icon(Icons.inventory_2),
        );
      case 4: // Members
        return FloatingActionButton(
          onPressed: () => _showAddMemberDialog(project.id, context),
          child: const Icon(Icons.person_add),
        );
      default:
        return Container();
    }
  }
}
