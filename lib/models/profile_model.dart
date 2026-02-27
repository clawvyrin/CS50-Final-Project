class Profiles {
  final String id;
  final String email;
  final String displayName;
  final String avatarUrl;

  Profiles({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
  });

  factory Profiles.fromMap(Map<String, dynamic> map) {
    return Profiles(
      id: map['id'],
      email: map['email'],
      displayName: map['display_name'],
      avatarUrl: map['avatar_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {};
  }
}
