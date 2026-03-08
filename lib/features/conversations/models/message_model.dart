import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/profiles/models/linked_profile_model.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    required LinkedProfileData sender,
    required String type,
    @JsonKey(name: 'is_me') required bool isMe,
    required String content,
    @JsonKey(name: 'meta_data') Map<String, dynamic>? metaData,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
