import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_dependency_model.freezed.dart';
part 'task_dependency_model.g.dart';

@freezed
abstract class TaskDependency with _$TaskDependency {
  @JsonSerializable(explicitToJson: true)
  const factory TaskDependency({
    required String id,
    @JsonKey(name: 'project_id') required String projectId,
    @JsonKey(name: 'task_id') required String taskId,
    @JsonKey(name: 'depends_on_task_id') required String dependsOnTaskId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _TaskDependency;

  factory TaskDependency.fromJson(Map<String, dynamic> json) =>
      _$TaskDependencyFromJson(json);
}
