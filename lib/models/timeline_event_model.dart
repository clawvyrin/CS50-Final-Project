class TimelineEvent {
  final String id;
  final String projectId;
  final String userId;
  final String actionType;
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  TimelineEvent({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.actionType,
    required this.content,
    required this.createdAt,
    this.metadata,
  });

  factory TimelineEvent.fromMap(Map<String, dynamic> map) {
    return TimelineEvent(
      id: map['id'],
      projectId: map['project_id'],
      userId: map['user_id'],
      actionType: map['action_type'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      metadata: map['metadata'],
    );
  }
}
