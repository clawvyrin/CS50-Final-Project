import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/models/enums.dart';

part 'project_member_model.freezed.dart';
part 'project_member_model.g.dart';

@freezed
abstract class ProjectMember with _$ProjectMember {
  @JsonSerializable(explicitToJson: true)
  const factory ProjectMember({
    required String id,
    @JsonKey(name: 'project_id') required String projectId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
    required ProjectRole role,
    required AssignmentStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ProjectMember;

  factory ProjectMember.fromJson(Map<String, dynamic> json) =>
      _$ProjectMemberFromJson(json);
}
