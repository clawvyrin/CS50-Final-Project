import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/home/models/enums.dart';
import 'package:task_companion/features/profiles/models/linked_profile_model.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String type,
    required LinkedProfileData notifier,
    @JsonKey(name: 'notified_id') required String notifiedId,
    required NotificationStatus status,
    @JsonKey(name: 'meta_data') Map<String, dynamic>? metaData,
    @JsonKey(name: 'seen_at') DateTime? seenAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
