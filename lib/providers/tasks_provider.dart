import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_companion/providers/project_providers.dart';
import 'package:task_companion/services/task_services.dart';

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
}
