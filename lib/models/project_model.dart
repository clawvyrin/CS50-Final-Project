import 'package:task_companion/models/milestone_model.dart';
import 'package:task_companion/models/task_model.dart';
import 'package:task_companion/models/timeline_event_model.dart';

enum ProjectStatus { hiatus, onGoing, done }

class Project {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final DateTime createdAt;
  final List<Task> tasks;
  final List<Milestone> milestones;
  final List<TimelineEvent> timeline;
  final ProjectStatus status;
  final String? backgroundAvatarUrl;

  Project({
    required this.id,
    required this.name,
    this.description,
    this.backgroundAvatarUrl,
    required this.ownerId,
    required this.createdAt,
    this.tasks = const [],
    this.milestones = const [],
    this.timeline = const [],
    required this.status,
  });

  Project copyWith(
    String? id,
    String? name,
    String? description,
    String? ownerId,
    DateTime? createdAt,
    List<Task>? tasks,
    List<Milestone>? milestones,
    ProjectStatus? status,
    String? backgroundAvatarUrl,
  ) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      milestones: milestones ?? this.milestones,
      description: description ?? this.backgroundAvatarUrl,
      backgroundAvatarUrl: backgroundAvatarUrl ?? this.backgroundAvatarUrl,
    );
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Sans nom',
      description: map['description'],
      backgroundAvatarUrl: map['background_avatar_url'],
      ownerId: map['owner_id'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProjectStatus.onGoing,
      ),
      tasks:
          (map['tasks'] as List?)?.map((x) => Task.fromMap(x)).toList() ?? [],
      milestones:
          (map['milestones'] as List?)
              ?.map((x) => Milestone.fromMap(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'status': status.name, // .name convertit l'enum en String pour la DB
      'background_avatar_url': backgroundAvatarUrl,
    };
  }
}
