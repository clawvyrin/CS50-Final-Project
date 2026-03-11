import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/tasks/models/task_model.dart';
import 'package:task_companion/features/tasks/providers/tasks_provider.dart';

class AddDailyTaskReportDialog extends ConsumerStatefulWidget {
  final Task task;
  const AddDailyTaskReportDialog({super.key, required this.task});

  @override
  ConsumerState<AddDailyTaskReportDialog> createState() =>
      _AddDailyTaskReportDialogState();
}

class _AddDailyTaskReportDialogState
    extends ConsumerState<AddDailyTaskReportDialog> {
  final summaryController = TextEditingController();

  List<Map<String, dynamic>> tempActivities = [];

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text.rich(
          TextSpan(
            text: "Report for : ",
            style: const TextStyle(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: widget.task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: summaryController,
                  decoration: const InputDecoration(
                    labelText: "Global summary of the day",
                    hintText: "i.e: Following along planning...",
                  ),
                  minLines: 1,
                  maxLines: 2,
                ),
                const SizedBox(height: 30),
                const Text(
                  "Performed activities: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                ...tempActivities.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var act = entry.value;
                  return Card(
                    color: Colors.blue.shade50,
                    child: ListTile(
                      title: Text(act['description']),
                      subtitle: Text("Resources: ${act['resources'].length}"),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            setDialogState(() => tempActivities.removeAt(idx)),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: tempActivities.isEmpty
                ? null
                : () async {
                    final Map<String, dynamic> report = {
                      "daily_summary": summaryController.text.trim(),
                      "daily_activities": tempActivities,
                      "start_time": widget.task.shiftStartTime,
                      "end_time": widget.task.shiftEndTime,
                    };
                    await ref
                        .read(taskActionsProvider.notifier)
                        .submitDailyReport(report: report);
                    if (context.mounted) context.pop();
                  },
            child: const Text("Send report"),
          ),
        ],
      ),
    );
  }
}
