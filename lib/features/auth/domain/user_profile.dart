class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
  });

  final String id;
  final String email;
  final String name;

  UserProfile copyWith({String? name}) =>
      UserProfile(id: id, email: email, name: name ?? this.name);
}
