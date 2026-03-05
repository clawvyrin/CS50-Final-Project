import 'package:task_companion/models/activity_model.dart';
import 'package:task_companion/models/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/models/milestone_model.dart';
import 'package:task_companion/models/project_member_model.dart';
import 'package:task_companion/models/resource_model.dart';
import 'package:task_companion/models/task_model.dart';
import 'package:task_companion/models/timeline_event_model.dart';

part 'project_model.freezed.dart';
part 'project_model.g.dart';

@freezed
abstract class Project with _$Project {
  @JsonSerializable(explicitToJson: true)
  const factory Project({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'owner_id') required String ownerId,
    required ProjectStatus status,
    @JsonKey(name: 'background_picture_url') String? backgroundPictureUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @Default([]) List<Task>? tasks,
    @Default([]) List<Milestone>? milestones,
    @Default([]) List<TimelineEvent>? timeline,
    @Default([]) List<ProjectMember>? members,
    @Default([]) List<Resource>? resources,
    @Default([]) List<Activity>? activities,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
