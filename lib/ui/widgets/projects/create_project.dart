import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/providers/project_service_providers.dart';
import 'package:task_companion/services/project_services.dart';

class CreateProject extends ConsumerStatefulWidget {
  const CreateProject({super.key});

  @override
  ConsumerState<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends ConsumerState<CreateProject> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text("New Project"),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Nom"),
          ),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: "Description"),
          ),
          ListTile(
            title: const Text('Start date'),
            subtitle: Text(_startDate.toString().split(' ')[0]),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) setState(() => _startDate = date);
            },
          ),
          ListTile(
            title: const Text('Estimated end date'),
            subtitle: Text(_endDate.toString().split(' ')[0]),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _endDate,
                firstDate: _startDate,
                lastDate: DateTime(2030),
              );
              if (date != null) setState(() => _endDate = date);
            },
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => context.pop(), child: const Text("Cancel")),
      ElevatedButton(
        onPressed: () async {
          await ProjectServices().createProject(
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7)),
          );
          if (context.mounted) {
            context.pop(context);
            ref.invalidate(projectServiceProvider);
          }
        },
        child: const Text("Créer"),
      ),
    ],
  );
}
