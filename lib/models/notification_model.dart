import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/models/enums.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String type,
    @JsonKey(name: 'notifier_id') required String notifierId,
    @JsonKey(name: 'notified_id') required String notifiedId,
    required NotificationStatus status,
    @JsonKey(name: 'meta_data') Map<String, dynamic>? metaData,
    @JsonKey(name: 'seen_at') DateTime? seenAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
