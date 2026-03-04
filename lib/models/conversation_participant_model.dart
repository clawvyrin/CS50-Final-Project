import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_participant_model.freezed.dart';
part 'conversation_participant_model.g.dart';

@freezed
abstract class ConversationParticipant with _$ConversationParticipant {
  @JsonSerializable(explicitToJson: true)
  const factory ConversationParticipant({
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
    @JsonKey(name: 'display_name') required String displayName,
  }) = _ConversationParticipant;

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) =>
      _$ConversationParticipantFromJson(json);
}
