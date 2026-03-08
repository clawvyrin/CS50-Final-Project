import 'package:freezed_annotation/freezed_annotation.dart';

part 'linked_profile_model.freezed.dart';
part 'linked_profile_model.g.dart';

@freezed
abstract class LinkedProfileData with _$LinkedProfileData {
  @JsonSerializable(explicitToJson: true)
  const factory LinkedProfileData({
    required String id,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _LinkedProfileData;

  factory LinkedProfileData.fromJson(Map<String, dynamic> json) =>
      _$LinkedProfileDataFromJson(json);
}
