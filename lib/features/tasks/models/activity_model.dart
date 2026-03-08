import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/profiles/models/linked_profile_model.dart';
import 'package:task_companion/features/projects/models/linked_project_model.dart';
import 'package:task_companion/features/tasks/models/linked_task_model.dart';
import 'package:task_companion/features/tasks/models/resource_model.dart';

part 'activity_model.freezed.dart';
part 'activity_model.g.dart';

@freezed
abstract class Activity with _$Activity {
  @JsonSerializable(explicitToJson: true)
  const factory Activity({
    required String id,
    required LinkedProjectData project,
    LinkedTaskData? task,
    required LinkedProfileData user,

    String? description,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'affected_resources')
    @Default([])
    List<Resource>? affectedResources,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
}
