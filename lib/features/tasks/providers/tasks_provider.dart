import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/features/tasks/models/task_model.dart';
import 'package:task_companion/features/conversations/providers/chat_provider.dart';
import 'package:task_companion/features/projects/providers/project_providers.dart';
import 'package:task_companion/features/authentication/services/auth_services.dart';
import 'package:task_companion/features/tasks/services/task_services.dart';

final taskDetailsProvider = FutureProvider.family<Task?, Map<String, String>>((
  ref,
  data,
) async {
  if (!(data.containsKey("projectId") && data.containsKey("taskId"))) {
    return null;
  }

  final response = await ref
      .read(taskServiceProvider)
      .getTaskDetails(projectId: data["projectId"]!, taskId: data["taskId"]!);

  return response;
});

final taskActionsProvider = AsyncNotifierProvider<TaskActionsNotifier, void>(
  () {
    return TaskActionsNotifier();
  },
);

class TaskActionsNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> createTask({Map<String, dynamic>? taskData}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(taskServiceProvider).createNewTask(taskData: taskData);

      ref.invalidate(projectDetailsProvider(taskData!["projectId"]));
    });
  }

  Future<void> verifyReport({
    required String reportId,
    required String taskId,
  }) async {
    final supabase = ref.read(supabaseProvider);

    await supabase.rpc(
      'certify_daily_report',
      params: {'p_report_id': reportId},
    );

    ref.invalidate(taskDetailsProvider);
    ref.invalidate(messagesProvider);
  }

  Future<void> submitDailyReport({required Map<String, dynamic> report}) async {
    final supabase = ref.read(supabaseProvider);

    final response = await supabase
        .from("daily_tasks_reports")
        .insert(report)
        .select()
        .maybeSingle();

    if (response != null) ref.invalidate(taskDetailsProvider);
  }
}
