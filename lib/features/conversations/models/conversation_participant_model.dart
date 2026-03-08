import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/profiles/models/linked_profile_model.dart';

part 'conversation_participant_model.freezed.dart';
part 'conversation_participant_model.g.dart';

@freezed
abstract class ConversationParticipant with _$ConversationParticipant {
  @JsonSerializable(explicitToJson: true)
  const factory ConversationParticipant({
    @JsonKey(name: 'conversation_id') required String conversationId,
    required LinkedProfileData participant,
  }) = _ConversationParticipant;

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) =>
      _$ConversationParticipantFromJson(json);
}
