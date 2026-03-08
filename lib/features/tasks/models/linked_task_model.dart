import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/projects/models/linked_project_model.dart';

part 'linked_task_model.freezed.dart';
part 'linked_task_model.g.dart';

@freezed
abstract class LinkedTaskData with _$LinkedTaskData {
  @JsonSerializable(explicitToJson: true)
  const factory LinkedTaskData({
    required String id,
    required String title,
    String? description,
    required LinkedProjectData project,
  }) = _LinkedTaskData;

  factory LinkedTaskData.fromJson(Map<String, dynamic> json) =>
      _$LinkedTaskDataFromJson(json);
}
