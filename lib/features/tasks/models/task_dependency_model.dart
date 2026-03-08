import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/tasks/models/linked_task_model.dart';

part 'task_dependency_model.freezed.dart';
part 'task_dependency_model.g.dart';

@freezed
abstract class TaskDependency with _$TaskDependency {
  @JsonSerializable(explicitToJson: true)
  const factory TaskDependency({
    required String id,
    @JsonKey(name: 'project_id') required String projectId,
    required LinkedTaskData task,
    required LinkedTaskData dependency,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _TaskDependency;

  factory TaskDependency.fromJson(Map<String, dynamic> json) =>
      _$TaskDependencyFromJson(json);
}
