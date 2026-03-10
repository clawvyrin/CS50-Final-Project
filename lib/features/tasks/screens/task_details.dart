import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/core/utils/string_extensions.dart';
import 'package:task_companion/features/projects/providers/project_providers.dart';
import 'package:task_companion/features/tasks/models/task_model.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';

class TaskDetails extends ConsumerStatefulWidget {
  final String taskId;
  final String projectId;

  const TaskDetails({super.key, required this.taskId, required this.projectId});

  @override
  ConsumerState<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends ConsumerState<TaskDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailsProvider(widget.projectId));

    return projectAsync.when(
      error: (e, _) => OnError(e: e),
      loading: () => const OnLoading(),
      data: (project) {
        final task = project?.tasks?.firstWhere((t) => t.id == widget.taskId);
        if (task == null) {
          return const Scaffold(body: Center(child: Text("Task not found")));
        }

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  title: Text(
                    task.title.capitalize(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.only(top: 80.0),
                      child: _buildTaskMetadataHeader(task),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: "Activities"),
                      Tab(text: "Resources"),
                      Tab(text: "Reports"),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildActivitiesList(task),
                _buildResourcesGrid(task),
                _buildReportsTimeline(task),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskMetadataHeader(Task task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(task.assignee.displayName),
                avatar: const Icon(Icons.person, size: 16),
              ),
              Text(
                "Shift: ${task.shiftStartTime} - ${task.shiftEndTime}",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Progression",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const LinearProgressIndicator(value: 0.4, minHeight: 8),
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
        title: Text("Report from ${task.reports![index].reportedAt}"),
        subtitle: Text(task.reports![index].dailySummary ?? ""),
      ),
    );
  }
}
