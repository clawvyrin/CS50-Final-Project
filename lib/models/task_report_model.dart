import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_report_model.freezed.dart';
part 'task_report_model.g.dart';

@freezed
abstract class DailyTaskReport with _$DailyTaskReport {
  @JsonSerializable(explicitToJson: true)
  const factory DailyTaskReport({
    required String id,
    @JsonKey(name: 'task_id') required String taskId,
    @JsonKey(name: 'user_id') required String userId,
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
