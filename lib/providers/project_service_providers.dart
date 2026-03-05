import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/models/project_model.dart';
import 'package:task_companion/services/project_services.dart';

final projectServiceProvider =
    AsyncNotifierProvider<ProjectServiceProviders, List<Project>>(
      ProjectServiceProviders.new,
    );

class ProjectServiceProviders extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async =>
      await ProjectServices().getUserProjects();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => await ProjectServices().getUserProjects(),
    );
  }

  Future<void> addProject(Project newProject) async {
    state = AsyncValue.data([newProject, ...state.value ?? []]);
  }
}
