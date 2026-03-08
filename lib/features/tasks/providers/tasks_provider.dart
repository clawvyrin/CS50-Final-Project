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
  return await TaskService().getTaskDetails(
    projectId: data["projectId"]!,
    taskId: data["taskId"]!,
  );
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

  Future<void> createTask({
    required String projectId,
    required String title,
    String? description,
    required DateTime dueDate,
    required String? assignedTo,
    List<String>? dependencies,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(taskServiceProvider)
          .createNewTask(
            projectId: projectId,
            title: title,
            description: description,
            dueDate: dueDate,
            assigneeId: assignedTo,
            dependencies: dependencies,
          );

      ref.invalidate(projectDetailsProvider(projectId));
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
}
