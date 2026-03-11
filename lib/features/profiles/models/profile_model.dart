import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
abstract class Profile with _$Profile {
  @JsonSerializable(explicitToJson: true)
  const factory Profile({
    required String id,
    required String email,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'display_name') required String displayName,
    String? biography,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'is_collaborator') required bool isCollaborator,
    @JsonKey(name: 'current_user_requested') required bool currentUserRequested,
    @JsonKey(name: 'other_user_requested') required bool otherUserRequested,
    @JsonKey(name: 'is_current_user') required bool isCurrentUser,
    @JsonKey(name: 'conversation_id') String? conversationId,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
