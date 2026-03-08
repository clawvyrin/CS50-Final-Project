import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/tasks/models/task_model.dart';
import 'package:task_companion/features/tasks/providers/tasks_provider.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';

class TaskDetails extends ConsumerWidget {
  final String taskId;
  final String projectId;

  const TaskDetails({super.key, required this.taskId, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .read(taskDetailsProvider({"projectId": projectId, "taskId": taskId}))
      .when(
        error: (e, _) => OnError(e: e),
        loading: () => const OnLoading(),
        data: (task) {
          return task == null
              ? Container()
              : DefaultTabController(
                  length: 3,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text("Task Details"),
                      bottom: const TabBar(
                        tabs: [
                          Tab(text: "Activities"),
                          Tab(text: "Resources"),
                          Tab(text: "Reports"),
                        ],
                      ),
                    ),
                    body: Column(
                      children: [
                        _buildTaskMetadataHeader(task),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildActivitiesList(task),
                              _buildResourcesGrid(task),
                              _buildReportsTimeline(task),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      );

  Widget _buildTaskMetadataHeader(Task task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.shade50),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Assigné: ${task.assignee.displayName}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Shift: ${task.shiftStartTime} - ${task.shiftEndTime}"),
            ],
          ),
          const SizedBox(height: 10),
          const LinearProgressIndicator(value: 0.4),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(Task task) {
    return ListView.builder(
      itemCount: task.activities?.length ?? 0,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: Text(task.activities![index].description ?? ""),
      ),
    );
  }

  Widget _buildResourcesGrid(Task task) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
      ),
      itemCount: task.affectedResources?.length ?? 0,
      itemBuilder: (context, index) {
        final res = task.affectedResources![index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  res.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${res.consumedAmount}/${res.allocatedAmount} ${res.unit}",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportsTimeline(Task task) {
    return ListView.builder(
      itemCount: task.reports?.length ?? 0,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.history),
        title: Text("Rapport du ${task.reports![index].reportedAt}"),
        subtitle: Text(task.reports![index].dailySummary ?? ""),
      ),
    );
  }
}
