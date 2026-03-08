import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/tasks/models/activity_model.dart';
import 'package:task_companion/features/home/models/enums.dart';
import 'package:task_companion/features/profiles/models/linked_profile_model.dart';
import 'package:task_companion/features/projects/models/linked_project_model.dart';
import 'package:task_companion/features/tasks/models/resource_model.dart';
import 'package:task_companion/features/tasks/models/task_dependency_model.dart';
import 'package:task_companion/features/tasks/models/task_report_model.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
abstract class Task with _$Task {
  @JsonSerializable(explicitToJson: true)
  const factory Task({
    required String id,
    required LinkedProjectData project,
    @JsonKey(name: 'conversation_id') required String conversationId,
    required String title,
    String? description,
    required TaskStatus status,
    required LinkedProfileData assignee,
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
    @JsonKey(name: 'pending_reports_count') required int pendingReportsCount,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
