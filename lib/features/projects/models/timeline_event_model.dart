import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/profiles/models/linked_profile_model.dart';
import 'package:task_companion/features/projects/models/linked_project_model.dart';

part 'timeline_event_model.freezed.dart';
part 'timeline_event_model.g.dart';

@freezed
abstract class TimelineEvent with _$TimelineEvent {
  @JsonSerializable(explicitToJson: true)
  const factory TimelineEvent({
    required String id,
    required LinkedProjectData project,
    required LinkedProfileData user,
    @JsonKey(name: 'action_type') required String actionType,
    required String content,
    @JsonKey(name: 'meta_data') Map<String, dynamic>? metaData,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TimelineEvent;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) =>
      _$TimelineEventFromJson(json);
}
