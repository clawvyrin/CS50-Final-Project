import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/log/logger.dart';
import 'package:task_companion/features/tasks/models/linked_task_model.dart';
import '../models/task_model.dart';

class TaskService {
  final supabase = Supabase.instance.client;

  Future<LinkedTaskData?> createNewTask({
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

      final insertResponse = await supabase
          .from("tasks")
          .insert({
            'project_id': projectId,
            'title': title,
            'description': description,
            'due_date': dueDate.toIso8601String(),
            'assigned_to': ?assigneeId,
          })
          .select()
          .single();

      dependencies?.forEach((d) async {
        await supabase.from("task_dependencies").insert({
          'project_id': projectId,
          'task_id': insertResponse['id'],
          'depends_on_task_id': d,
        });
      });

      final response = await supabase
          .from("task_data_view")
          .select()
          .eq('id', insertResponse['id'])
          .single();

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
          .rpc(
            'get_task_details',
            params: {'p_task_id': taskId, 'p_id': projectId},
          )
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
}

final taskServiceProvider = Provider((ref) => TaskService());
