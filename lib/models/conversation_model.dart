import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/models/conversation_participant_model.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

@freezed
abstract class Conversation with _$Conversation {
  @JsonSerializable(explicitToJson: true)
  const factory Conversation({
    required String id,
    @JsonKey(name: 'project_id') String? projectId,
    @JsonKey(name: 'task_id') String? taskId,
    required String title,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @Default([]) List<ConversationParticipant>? participants,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
