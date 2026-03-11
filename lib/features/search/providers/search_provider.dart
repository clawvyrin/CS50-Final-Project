import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/profiles/models/profile_model.dart';
import 'package:task_companion/features/projects/models/linked_project_model.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/search/services/search_service.dart';
import 'package:task_companion/features/tasks/models/linked_task_model.dart';

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => "";

  void update(String value) => state = value;
}

final userSearchProvider = FutureProvider<List<Profile>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 2) return [];

  final supabaseClient = ref.read(supabaseProvider);

  return await ref
      .read(searchServiceProvider)
      .searchUsers(query, supabaseClient);
});

final projectSearchProvider = FutureProvider<List<LinkedProjectData>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 2) return [];

  final supabaseClient = ref.read(supabaseProvider);

  return await ref
      .read(searchServiceProvider)
      .searchProjects(query, supabaseClient);
});

final taskSearchProvider = FutureProvider<List<LinkedTaskData>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 2) return [];

  final supabaseClient = ref.read(supabaseProvider);

  return await ref
      .read(searchServiceProvider)
      .searchTask(query, supabaseClient);
});
