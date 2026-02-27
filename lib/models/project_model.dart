class Project {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.createdAt,
  });

  // Pour transformer la réponse de Supabase (Map) en objet Projet
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      ownerId: map['owner_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Pour envoyer des données vers Supabase
  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'owner_id': ownerId};
  }
}
