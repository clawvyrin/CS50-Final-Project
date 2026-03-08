import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/log/logger.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/projects/models/project_model.dart';

class ProjectServices {
  final supabase = Supabase.instance.client;

  Future<List<Project>> getUserProjects({
    DateTime? anchor,
    int limit = 10,
  }) async {
    try {
      appLogger.i("Attempt to fetch user projects");

      final timestamp =
          anchor?.toIso8601String() ?? DateTime.now().toIso8601String();

      final response = await supabase
          .from('project_view')
          .select()
          .eq('owner->>id', AuthServices.id!)
          .gt('created_at', timestamp)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((json) => Project.fromJson(json)).toList();
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

  Future<Project?> createProject({
    required String name,
    required String description,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      appLogger.i("Attempt to create project");

      final response = await supabase.rpc(
        'create_project',
        params: {
          'p_name': name,
          'p_desc': description,
          'p_start': start.toIso8601String(),
          'p_end': end.toIso8601String(),
        },
      );
      return Project.fromJson(response);
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

      final response = await supabase.rpc(
        'get_project_details',
        params: {'p_id': id},
      );

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
