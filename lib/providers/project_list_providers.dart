import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/models/project_model.dart';
import 'package:task_companion/services/supabase_services.dart';

final projectListProvider =
    AsyncNotifierProvider<ProjectListProviders, List<Project>>(
      ProjectListProviders.new,
    );

class ProjectListProviders extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async =>
      await SupabaseServices().getUserProjects();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => await SupabaseServices().getUserProjects(),
    );
  }
}
