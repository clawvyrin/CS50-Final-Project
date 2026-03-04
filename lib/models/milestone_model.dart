import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/models/enums.dart';

part 'milestone_model.freezed.dart';
part 'milestone_model.g.dart';

@freezed
abstract class Milestone with _$Milestone {
  @JsonSerializable(explicitToJson: true)
  const factory Milestone({
    required String id,
    @JsonKey(name: 'project_id') required String projectId,
    required String title,
    @JsonKey(name: 'original_due_date') required DateTime originalDueDate,
    @JsonKey(name: 'updated_due_date') DateTime? updatedDueDate,
    required MilestoneStatus status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Milestone;

  factory Milestone.fromJson(Map<String, dynamic> json) =>
      _$MilestoneFromJson(json);
}
