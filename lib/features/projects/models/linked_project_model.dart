import 'package:freezed_annotation/freezed_annotation.dart';

part 'linked_project_model.freezed.dart';
part 'linked_project_model.g.dart';

@freezed
abstract class LinkedProjectData with _$LinkedProjectData {
  @JsonSerializable(explicitToJson: true)
  const factory LinkedProjectData({
    required String id,
    required String name,
    String? description,
  }) = _LinkedProjectData;

  factory LinkedProjectData.fromJson(Map<String, dynamic> json) =>
      _$LinkedProjectDataFromJson(json);
}
