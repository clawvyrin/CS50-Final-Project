import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/profiles/models/linked_profile_model.dart';
import 'package:task_companion/features/tasks/models/linked_task_model.dart';

part 'task_report_model.freezed.dart';
part 'task_report_model.g.dart';

@freezed
abstract class DailyTaskReport with _$DailyTaskReport {
  @JsonSerializable(explicitToJson: true)
  const factory DailyTaskReport({
    required String id,
    required LinkedTaskData task,
    @JsonKey(name: 'submitted_by') required LinkedProfileData submittedBy,
    @JsonKey(name: 'daily_summary') String? dailySummary,
    @JsonKey(name: 'daily_activities') required dynamic dailyActivities,
    @JsonKey(name: 'start_time') DateTime? startTime,
    @JsonKey(name: 'end_time') DateTime? endTime,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(name: 'is_signed') required bool isSigned,
    @JsonKey(name: 'reported_at') DateTime? reportedAt,
  }) = _DailyTaskReport;

  factory DailyTaskReport.fromJson(Map<String, dynamic> json) =>
      _$DailyTaskReportFromJson(json);
}
