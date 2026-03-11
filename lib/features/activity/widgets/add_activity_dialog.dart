import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/activity/widgets/pick_resource_quantity.dart';

class AddActivityDialog extends StatefulWidget {
  final List<Map<String, dynamic>> availableResources;
  const AddActivityDialog({super.key, required this.availableResources});

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  final _actDescController = TextEditingController();
  final List<Map<String, dynamic>> _selectedForActivity = [];

  @override
  void dispose() {
    _actDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Action details"),
      content: SizedBox(
        // Utilise un SizedBox pour donner une contrainte à la ListView
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _actDescController,
              decoration: const InputDecoration(
                labelText: "Description (ex: laying bricks)",
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Link to resources :",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Flexible(
              // Permet à la liste de scroller si elle est longue
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.availableResources.length,
                itemBuilder: (context, index) {
                  final resource = widget.availableResources[index];

                  // On cherche si la ressource est déjà allouée
                  final allocated = _selectedForActivity
                      .where((r) => r["id"] == resource["id"])
                      .firstOrNull;

                  return ListTile(
                    title: Text(resource['name']),
                    subtitle: Text(
                      allocated != null
                          ? "Allocated: ${allocated["amount"]} ${resource["unit"]}"
                          : "Available: ${resource['amount']} ${resource['unit']}",
                    ),
                    trailing: allocated != null
                        ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() {
                              _selectedForActivity.removeWhere(
                                (r) => r["id"] == resource["id"],
                              );
                            }),
                          )
                        : const Icon(Icons.add_circle_outline),
                    onTap: () async {
                      final double? amount = await showDialog<double>(
                        context: context,
                        builder: (context) =>
                            PickResourceQuantity(resource: resource),
                      );

                      if (amount != null && amount > 0) {
                        setState(() {
                          // On retire l'ancienne valeur si elle existe avant d'ajouter la nouvelle
                          _selectedForActivity.removeWhere(
                            (r) => r["id"] == resource["id"],
                          );
                          _selectedForActivity.add({
                            ...resource, // Copie les infos de base
                            "amount": amount,
                          });
                        });
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () => context.pop({
            'description': _actDescController.text.trim(),
            'resources': _selectedForActivity,
          }),
          child: const Text("Add"),
        ),
      ],
    );
  }
}
