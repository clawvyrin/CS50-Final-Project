import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/conversations/models/conversation_participant_model.dart';
import 'package:task_companion/features/tasks/models/linked_task_model.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

@freezed
abstract class Conversation with _$Conversation {
  @JsonSerializable(explicitToJson: true)
  const factory Conversation({
    required String id,
    required LinkedTaskData? task,
    required String title,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @Default([]) List<ConversationParticipant>? participants,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
