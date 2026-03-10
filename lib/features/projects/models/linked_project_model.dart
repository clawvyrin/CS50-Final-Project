import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/home/models/enums.dart';

part 'linked_project_model.freezed.dart';
part 'linked_project_model.g.dart';

@freezed
abstract class LinkedProjectData with _$LinkedProjectData {
  @JsonSerializable(explicitToJson: true)
  const factory LinkedProjectData({
    required String id,
    required String name,
    @JsonKey(name: "background_picture_url") String? backgroundPictureUrl,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(unknownEnumValue: ProjectStatus.onGoing)
    required ProjectStatus status,

    String? description,
  }) = _LinkedProjectData;

  factory LinkedProjectData.fromJson(Map<String, dynamic> json) =>
      _$LinkedProjectDataFromJson(json);
}
