import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/features/projects/models/linked_project_model.dart';

part 'resource_model.freezed.dart';
part 'resource_model.g.dart';

@freezed
abstract class Resource with _$Resource {
  @JsonSerializable(explicitToJson: true)
  const factory Resource({
    required String id,
    required LinkedProjectData project,
    required String name,
    required String type,
    @JsonKey(name: 'allocated_amount') required double allocatedAmount,
    @JsonKey(name: 'consumed_amount') required double consumedAmount,
    String? unit,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Resource;

  factory Resource.fromJson(Map<String, dynamic> json) =>
      _$ResourceFromJson(json);
}
