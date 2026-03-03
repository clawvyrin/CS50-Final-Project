enum MilestoneStatus { onTrack, achieved, postponed }

class Milestone {
  final String id;
  final String title;
  final DateTime originalDueDate;
  final DateTime? updatedDueDate;
  final MilestoneStatus status;

  Milestone({
    required this.id,
    required this.title,
    required this.originalDueDate,
    required this.updatedDueDate,
    required this.status,
  });

  Milestone copyWith(
    String? id,
    String? title,
    DateTime? originalDueDate,
    DateTime? updatedDueDate,
    MilestoneStatus? status,
  ) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      originalDueDate: originalDueDate ?? this.originalDueDate,
      updatedDueDate: updatedDueDate ?? this.updatedDueDate,
      status: status ?? this.status,
    );
  }

  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      id: map["id"],
      title: map["title"] ?? '',
      originalDueDate: DateTime.parse(map["original_due_date"]),
      updatedDueDate: map["updated_due_date"] != null
          ? DateTime.parse(map["updated_due_date"])
          : null,
      status: MilestoneStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MilestoneStatus.onTrack,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'original_due_date': originalDueDate.toIso8601String(),
      'updated_due_date': updatedDueDate?.toIso8601String(),
      'status': status.name,
    };
  }
}
