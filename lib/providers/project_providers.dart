import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/models/project_model.dart';
import 'package:task_companion/services/project_services.dart';

final projectServiceProvider = Provider<ProjectServices>((ref) {
  return ProjectServices();
});

final projectsListProvider =
    AsyncNotifierProvider<ProjectsListNotifier, List<Project>>(() {
      return ProjectsListNotifier();
    });

final projectDetailsProvider = FutureProvider.family<Project?, String>((
  ref,
  id,
) {
  return ref.read(projectServiceProvider).getFullProjectDetails(id);
});

class ProjectsListNotifier extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async =>
      ref.read(projectServiceProvider).getUserProjects();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => await ProjectServices().getUserProjects(),
    );
  }

  Future<void> addProject(Project newProject) async {
    state = AsyncValue.data([newProject, ...state.value ?? []]);
  }

  void removeProject(String id) {
    final previousState = state.value ?? [];
    state = AsyncValue.data(previousState.where((p) => p.id != id).toList());
  }
}
