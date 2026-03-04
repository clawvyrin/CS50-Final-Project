import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/models/activity_resource_model.dart';

part 'activity_model.freezed.dart';
part 'activity_model.g.dart';

@freezed
abstract class Activity with _$Activity {
  @JsonSerializable(explicitToJson: true)
  const factory Activity({
    required String id,
    @JsonKey(name: 'project_id') required String projectId,
    @JsonKey(name: 'task_id') String? taskId,
    @JsonKey(name: 'user_id') String? userId,
    String? description,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'resources') @Default([]) List<ActivityResource>? resources,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
}
