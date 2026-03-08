import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/home/models/enums.dart';
import 'package:task_companion/features/profiles/models/linked_profile_model.dart';

part 'project_member_model.freezed.dart';
part 'project_member_model.g.dart';

@freezed
abstract class ProjectMember with _$ProjectMember {
  @JsonSerializable(explicitToJson: true)
  const factory ProjectMember({
    required String id,
    @JsonKey(name: 'project_id') required String projectId,
    required LinkedProfileData user,
    @JsonKey(name: 'job_description') required String jobDescrpition,
    required ProjectRole role,
    required AssignmentStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ProjectMember;

  factory ProjectMember.fromJson(Map<String, dynamic> json) =>
      _$ProjectMemberFromJson(json);
}
