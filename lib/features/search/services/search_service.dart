import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/log/logger.dart';
import 'package:task_companion/features/profiles/models/profile_model.dart';
import 'package:task_companion/features/projects/models/linked_project_model.dart';
import 'package:task_companion/features/tasks/models/linked_task_model.dart';

class SearchService {
  Future<List<Profile>> searchUsers(
    String query,
    SupabaseClient supabaseClient,
  ) async {
    try {
      appLogger.i("Looking for users");

      final response = await supabaseClient
          .from("profiles_with_relation")
          .select()
          .like("display_name", '%$query%');

      return (response as List)
          .map((json) => Profile.fromJson(json))
          .toList();
    } catch (e, st) {
      appLogger.e(
        "Error looking for users",
        error: e,
        stackTrace: st,
        time: DateTime.now(),
      );
      return [];
    }
  }

  Future<List<LinkedProjectData>> searchProjects(
    String query,
    SupabaseClient supabaseClient,
  ) async {
    try {
      appLogger.i("Looking for projects");

      final response = await supabaseClient
          .from("projects")
          .select()
          .like("name", '%$query%');

      return (response as List)
          .map((json) => LinkedProjectData.fromJson(json))
          .toList();
    } catch (e, st) {
      appLogger.e(
        "Error looking for projects",
        error: e,
        stackTrace: st,
        time: DateTime.now(),
      );
      return [];
    }
  }

  Future<List<LinkedTaskData>> searchTask(
    String query,
    SupabaseClient supabaseClient,
  ) async {
    try {
      appLogger.i("Looking for task");

      final response = await supabaseClient
          .from("task_data_view")
          .select()
          .like("title", '%$query%');

      return (response as List)
          .map((json) => LinkedTaskData.fromJson(json))
          .toList();
    } catch (e, st) {
      appLogger.e(
        "Error looking for tasks",
        error: e,
        stackTrace: st,
        time: DateTime.now(),
      );
      return [];
    }
  }
}

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});
