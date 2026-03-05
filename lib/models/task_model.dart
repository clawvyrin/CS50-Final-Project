import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/models/activity_model.dart';
import 'package:task_companion/models/enums.dart';
import 'package:task_companion/models/resource_model.dart';
import 'package:task_companion/models/task_dependency_model.dart';
import 'package:task_companion/models/task_report_model.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
abstract class Task with _$Task {
  @JsonSerializable(explicitToJson: true)
  const factory Task({
    required String id,
    @JsonKey(name: 'project_id') required String projectId,
    @JsonKey(name: 'project_name') required String projectName,
    @JsonKey(name: 'conversation_id') required String conversationId,
    required String title,
    String? description,
    required TaskStatus status,
    @JsonKey(name: 'assigned_to') required String? assigneeId,
    @JsonKey(name: 'assignee_display_name')
    required String? assigneeDisplayName,
    @JsonKey(name: 'assignee_avatar_url') required String? assigneeAvatarUrl,
    @JsonKey(name: 'work_days') @Default([]) List<Weekday>? workDays,
    @JsonKey(name: 'shift_start_time')
    @Default("08:00:00")
    String? shiftStartTime,
    @JsonKey(name: 'shift_end_time') @Default("18:00:00") String? shiftEndTime,
    @JsonKey(name: 'affected_resources')
    @Default([])
    List<Resource>? affectedResources,
    @Default([]) List<Activity>? activities,
    @Default([]) List<DailyTaskReport>? reports,
    @Default([]) List<TaskDependency>? dependencies,
    @JsonKey(name: 'due_date') required DateTime dueDate,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
