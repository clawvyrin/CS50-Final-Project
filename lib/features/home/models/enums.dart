import 'package:freezed_annotation/freezed_annotation.dart';

enum ProjectRole { admin, editor, viewer }

enum Weekday { mon, tue, wed, thu, fri, sat, sun }

enum ProjectStatus {
  @JsonValue('hiatus')
  hiatus,

  @JsonValue('on_going')
  onGoing,

  @JsonValue('done')
  done,
}

enum TaskStatus {
  @JsonValue('todo') // Optionnel si la DB utilise 'todo'
  todo,

  @JsonValue('in_progress')
  inProgress,

  @JsonValue('done')
  done,
}

enum MilestoneStatus {
  @JsonValue('on_track')
  onTrack,

  @JsonValue('achieved')
  achieved,

  @JsonValue('postponed')
  postponed,
}

enum RequestStatus { accepted, pending, denied }

enum AssignmentStatus { accepted, pending, denied, left, removed }

enum NotificationStatus {
  accepted,
  pending,
  denied,
  read,
  archived,
  clicked,
  dismissed,
}
