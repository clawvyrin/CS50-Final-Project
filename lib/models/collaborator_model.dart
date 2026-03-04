import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_companion/models/enums.dart';

part 'collaborator_model.freezed.dart';
part 'collaborator_model.g.dart';

@freezed
abstract class Collaborator with _$Collaborator {
  const factory Collaborator({
    @JsonKey(name: 'requested_by') required String requestedBy,
    @JsonKey(name: 'requested_to') required String requestedTo,
    required RequestStatus status,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Collaborator;

  factory Collaborator.fromJson(Map<String, dynamic> json) =>
      _$CollaboratorFromJson(json);
}
