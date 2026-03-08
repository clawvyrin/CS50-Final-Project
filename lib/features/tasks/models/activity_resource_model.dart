import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_resource_model.freezed.dart';
part 'activity_resource_model.g.dart';

@freezed
abstract class ActivityResource with _$ActivityResource {
  @JsonSerializable(explicitToJson: true)
  const factory ActivityResource({
    @JsonKey(name: 'activity_id') required String activityId,
    @JsonKey(name: 'resource_id') required String resourceId,
    @JsonKey(name: 'amount_impacted') required int amountImpacted,
  }) = _ActivityResource;

  factory ActivityResource.fromJson(Map<String, dynamic> json) =>
      _$ActivityResourceFromJson(json);
}
