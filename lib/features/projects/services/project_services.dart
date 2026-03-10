import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/log/logger.dart';
import 'package:task_companion/features/projects/models/linked_project_model.dart';
import 'package:task_companion/features/projects/models/project_model.dart';

class ProjectServices {
  final supabase = Supabase.instance.client;

  Future<List<LinkedProjectData>> getUserProjects({
    DateTime? anchor,
    int limit = 10,
  }) async {
    try {
      appLogger.i("Attempt to fetch user projects");

      final timestamp =
          anchor?.toIso8601String() ?? DateTime.now().toIso8601String();

      final test = await supabase
          .from('projects')
          .select()
          .lt('created_at', timestamp)
          .order('created_at', ascending: false)
          .limit(limit);

      appLogger.i("Fetched ${test.length} projects");
      return test.map((json) => LinkedProjectData.fromJson(json)).toList();
    } catch (e, st) {
      appLogger.e(
        "Error getting user projects",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return [];
    }
  }

  Future<LinkedProjectData?> createProject({
    required String name,
    required String description,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      appLogger.i("Attempt to create project");

      final response = await supabase
          .from("projects")
          .insert({
            'name': name,
            'description': description,
            'start_date': start.toIso8601String(),
            'end_date': end.toIso8601String(),
          })
          .select()
          .single();
      return LinkedProjectData.fromJson(response);
    } catch (e, st) {
      appLogger.e(
        "Error creating project",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return null;
    }
  }

  Future<Project?> getFullProjectDetails(String id) async {
    try {
      appLogger.i("Attempt to get project details");

      final response = await supabase
          .from("project_view")
          .select()
          .eq('id', id)
          .limit(1)
          .maybeSingle();

      // final response = await supabase.rpc(
      //   'get_project_details',
      //   params: {'p_id': id},
      // );
      if (response == null) return null;

      return Project.fromJson(response);
    } catch (e, st) {
      appLogger.e(
        "Error getting project details",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return null;
    }
  }

  Future deleteProject(String id) async {
    try {
      appLogger.i("Attempt to delete project");

      await supabase.rpc('create_project', params: {'p_id': id});
    } catch (e, st) {
      appLogger.e(
        "Error deleting project",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
    }
  }

  Future editProject(Project updatedProject) async {
    try {
      appLogger.i("Attempt to edit project");

      await supabase.rpc(
        'create_project',
        params: {'updated_project': updatedProject},
      );
    } catch (e, st) {
      appLogger.e(
        "Error editing project",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
    }
  }
}

final projectServiceProvider = Provider<ProjectServices>((ref) {
  return ProjectServices();
});
