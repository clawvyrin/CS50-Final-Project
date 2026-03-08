import 'package:freezed_annotation/freezed_annotation.dart';

part 'linked_message_model.freezed.dart';
part 'linked_message_model.g.dart';

@freezed
abstract class LinkedMessageData with _$LinkedMessageData {
  @JsonSerializable(explicitToJson: true)
  const factory LinkedMessageData({
    required String content,
    required String? type,
    @JsonKey(name: 'seen_at') DateTime? seenAt,
    @JsonKey(name: 'sent_at') required DateTime sentAt,
  }) = _LinkedMessageData;

  factory LinkedMessageData.fromJson(Map<String, dynamic> json) =>
      _$LinkedMessageDataFromJson(json);
}
