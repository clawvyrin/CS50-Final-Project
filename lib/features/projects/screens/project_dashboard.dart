import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/projects/providers/project_providers.dart';
import 'package:task_companion/features/home/widgets/helpers/on_error.dart';
import 'package:task_companion/features/home/widgets/helpers/on_loading.dart';
import 'package:task_companion/features/projects/widgets/dynamic_floating_action_button.dart';
import 'package:task_companion/features/projects/widgets/gantt/gantt_chart.dart';
import 'package:task_companion/features/projects/widgets/milestone_row.dart';
import 'package:task_companion/features/projects/widgets/tabs/members_tab.dart';
import 'package:task_companion/features/projects/widgets/tabs/tasks_tabs.dart';
import 'package:task_companion/features/projects/widgets/tabs/timeline_tab.dart';

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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(currentTabProvider.notifier).state = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectDetailsAsync = ref.watch(
      projectDetailsProvider(widget.projectId),
    );

    return projectDetailsAsync.when(
      error: (e, _) => OnError(e: e),
      loading: () => const OnLoading(),
      data: (project) => project == null
          ? const SizedBox()
          : Scaffold(
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 380,
                      pinned: true,
                      floating: false,
                      title: Text(project.name),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 80),
                            SizedBox(
                              height: 200,
                              child: GanttChartWidget(
                                tasks: project.tasks ?? [],
                                projectStart: project.startDate!,
                              ),
                            ),
                            MilestoneRow(milestones: project.milestones ?? []),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                      bottom: TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(text: 'Tasks', icon: Icon(Icons.list)),
                          Tab(text: 'Timeline', icon: Icon(Icons.timeline)),
                          Tab(text: 'Team', icon: Icon(Icons.group)),
                        ],
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    TasksTab(tasks: project.tasks ?? []),
                    TimelineTab(events: project.timeline ?? []),
                    MembersTab(
                      projectId: project.id,
                      isOwner: AuthServices.id == project.owner.id,
                    ),
                  ],
                ),
              ),
              floatingActionButton: ProjectFloatingActionButton(
                project: project,
                tabController: _tabController,
              ),
            ),
    );
  }
}
