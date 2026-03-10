import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:task_companion/features/projects/models/linked_project_model.dart';
import 'package:task_companion/features/projects/models/project_model.dart';
import 'package:task_companion/features/projects/services/project_services.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

final projectsListProvider =
    AsyncNotifierProvider<ProjectsListNotifier, List<LinkedProjectData>>(() {
      return ProjectsListNotifier();
    });

final projectDetailsProvider = FutureProvider.family<Project?, String>((
  ref,
  id,
) {
  return ref.read(projectServiceProvider).getFullProjectDetails(id);
});

class ProjectsListNotifier extends AsyncNotifier<List<LinkedProjectData>> {
  @override
  Future<List<LinkedProjectData>> build() async =>
      await ref.read(projectServiceProvider).getUserProjects();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => await ProjectServices().getUserProjects(),
    );
  }

  Future<void> addProject(LinkedProjectData newProject) async {
    state = AsyncValue.data([newProject, ...state.value ?? []]);
  }

  void removeProject(String id) {
    final previousState = state.value ?? [];
    state = AsyncValue.data(previousState.where((p) => p.id != id).toList());
  }
}
