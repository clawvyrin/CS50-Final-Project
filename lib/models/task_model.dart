enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final TaskStatus status;
  final String? assignedTo;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.status,
    this.assignedTo,
    this.dueDate,
  });

  Task copyWith(
    String? id,
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    String? assignedTo,
    DateTime? dueDate,
  ) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      projectId: map['project_id'],
      title: map['title'] ?? '',
      description: map['description'],
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      assignedTo: map['assigned_to'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': status.name, // Très important : envoyer le String
      'assigned_to': assignedTo,
      'due_date': dueDate?.toIso8601String(),
    };
  }
}
