import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/logger.dart';
import '../models/task_model.dart';

class TaskService {
  final supabase = Supabase.instance.client;

  Future<Task?> createNewTask({
    required String projectId,
    required String title,
    String? description,
    required DateTime dueDate,
    List<String>? workDays,
    String? assigneeId,
    List<String>? dependencies,
  }) async {
    try {
      appLogger.i("Attempt to create task for project");

      final response = await supabase.rpc(
        'create_task',
        params: {
          'p_project_id': projectId,
          'p_title': title,
          'p_description': description,
          'p_due_date': dueDate.toIso8601String(),
          'p_work_days': ?workDays,
          'p_dependencies': dependencies,
          'p_assigned_to': ?assigneeId,
        },
      );

      return Task.fromJson(response);
    } catch (e, st) {
      appLogger.e(
        "Error creating task",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return null;
    }
  }
}

final taskServiceProvider = Provider((ref) => TaskService());
