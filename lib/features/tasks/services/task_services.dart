import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/log/logger.dart';
import 'package:task_companion/features/tasks/models/linked_task_model.dart';
import '../models/task_model.dart';

class TaskService {
  final supabase = Supabase.instance.client;

  Future<LinkedTaskData?> createNewTask({
    Map<String, dynamic>? taskData,
  }) async {
    try {
      if (taskData == null) return null;

      final response = await supabase.rpc(
        "create_task_with_details",
        params: taskData,
      );

      return LinkedTaskData.fromJson(response);
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

  Future<Task?> getTaskDetails({
    required String projectId,
    required String taskId,
  }) async {
    try {
      appLogger.i("Attempt to get task details");

      final response = await supabase
          .from("task_view")
          .select()
          .eq('id', taskId)
          .eq('project_id', projectId)
          .maybeSingle();

      return Task.fromJson(response!);
    } catch (e, st) {
      appLogger.e(
        "Error getting task details",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
      return null;
    }
  }

  Future verifyTaskReport({required String reportId}) async {
    try {
      appLogger.i("Attempt to get task details");

      await supabase.rpc(
        'certify_daily_report',
        params: {'p_report_id': reportId},
      );
    } catch (e, st) {
      appLogger.e(
        "Error verifying task report",
        error: e,
        stackTrace: st,
        time: DateTime.now().toUtc(),
      );
    }
  }

  Future<void> updateProgress(String taskId, double progress) async {
    try {
      await supabase
          .from('tasks')
          .update({'progression': progress})
          .eq('id', taskId);

      appLogger.i("Task progression updated : $progress%");
    } catch (e) {
      appLogger.e("Erro updating progression", error: e);
    }
  }
}

final taskServiceProvider = Provider((ref) => TaskService());
