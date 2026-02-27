enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final TaskStatus status; // 'todo', 'in_progress', 'done'
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

  factory Task.fromMap(Map<String, dynamic> map) {
    TaskStatus status = TaskStatus.done;

    switch (map['status']) {
      case 'todo':
        status = TaskStatus.todo;
      case 'in_progress':
        status = TaskStatus.inProgress;
      case 'done':
        status = TaskStatus.done;
      default:
        status = TaskStatus.todo;
    }

    return Task(
      id: map['id'],
      projectId: map['project_id'],
      title: map['title'],
      description: map['description'],
      status: status,
      assignedTo: map['assigned_to'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': status,
      'assigned_to': assignedTo,
      'due_date': dueDate?.toIso8601String(),
    };
  }
}
