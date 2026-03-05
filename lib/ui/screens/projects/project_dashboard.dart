import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/providers/project_providers.dart';
import 'package:task_companion/ui/widgets/projects/dynamic_floating_action_button.dart';
import 'package:task_companion/ui/widgets/projects/gantt/gantt_chart.dart';
import 'package:task_companion/ui/widgets/projects/milestone_row.dart';
import 'package:task_companion/ui/widgets/projects/tabs/activities_tab.dart';
import 'package:task_companion/ui/widgets/projects/tabs/members_tab.dart';
import 'package:task_companion/ui/widgets/projects/tabs/resources_tab.dart';
import 'package:task_companion/ui/widgets/projects/tabs/tasks_tabs.dart';
import 'package:task_companion/ui/widgets/projects/tabs/timeline_tab.dart';

class ProjectDashboard extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectDashboard({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDashboard> createState() => _ProjectDashboardState();
}

class _ProjectDashboardState extends ConsumerState<ProjectDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailsProvider(widget.projectId));

    return projectAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Erreur: $err'))),
      data: (project) => project == null
          ? Container()
          : DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  title: ListTile(
                    title: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: project.description != null
                        ? Text(
                            project.description!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Container(),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                  ],
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: 'Tasks', icon: Icon(Icons.list)),
                      Tab(text: 'Activities', icon: Icon(Icons.history)),
                      Tab(text: 'Resources', icon: Icon(Icons.inventory_2)),
                      Tab(text: 'Timeline', icon: Icon(Icons.timeline)),
                      Tab(text: 'Team', icon: Icon(Icons.group)),
                    ],
                  ),
                ),
                body: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: GanttChartWidget(tasks: project.tasks ?? []),
                    ),
                    MilestoneRow(milestones: project.milestones ?? []),
                    const Divider(height: 1),
                    Expanded(
                      child: TabBarView(
                        children: [
                          TasksTab(tasks: project.tasks ?? []),
                          ActivitiesTab(activities: project.activities ?? []),
                          ResourcesTab(resources: project.resources ?? []),
                          TimelineTab(events: project.timeline ?? []),
                          MembersTab(members: project.members ?? []),
                        ],
                      ),
                    ),
                  ],
                ),
                floatingActionButton: ProjectFloatingActionButton(
                  project: project,
                  tabController: _tabController,
                ),
              ),
            ),
    );
  }
}
