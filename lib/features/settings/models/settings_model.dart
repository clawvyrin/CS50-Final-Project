class Settings {
  final String theme;
  final String language;
  final MutedNotifications mutedNotifications;

  Settings({
    required this.theme,
    required this.language,
    required this.mutedNotifications,
  });

  Settings copyWith({
    String? theme,
    String? language,
    MutedNotifications? mutedNotifications,
  }) {
    return Settings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      mutedNotifications: mutedNotifications ?? this.mutedNotifications,
    );
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      theme: json["theme"] ?? "system",
      language: json["language"] ?? "en",
      mutedNotifications: MutedNotifications.fromJson(
        json["mute_notifications_from"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "theme": theme,
      "language": language,
      "muted_notifications": mutedNotifications.toJson(),
    };
  }
}

class MutedNotifications {
  final List<String> users;
  final List<String> tasks;
  final List<String> projects;

  MutedNotifications({
    required this.users,
    required this.tasks,
    required this.projects,
  });

  MutedNotifications copyWith({
    List<String>? users,
    List<String>? tasks,
    List<String>? projects,
  }) {
    return MutedNotifications(
      users: users ?? this.users,
      tasks: tasks ?? this.tasks,
      projects: projects ?? this.projects,
    );
  }

  factory MutedNotifications.fromJson(Map<String, dynamic> json) {
    return MutedNotifications(
      users: List<String>.from(json["users"] ?? []),
      tasks: List<String>.from(json["tasks"] ?? []),
      projects: List<String>.from(json["projects"] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {"users": users, "tasks": tasks, "projects": projects};
  }
}
