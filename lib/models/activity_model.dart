import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/models/resource_model.dart';

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
    @JsonKey(name: 'user_avatar_url') String? userAvatarUrl,
    @JsonKey(name: 'user_display_nale') String? userDisplayName,

    String? description,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'affected_resources')
    @Default([])
    List<Resource>? affectedResources,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
}
