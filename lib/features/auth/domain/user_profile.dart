class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.onboardingComplete = false,
  });
  final String id;
  final String email;
  final String name;
  final bool onboardingComplete;
  UserProfile copyWith({String? name, bool? onboardingComplete}) => UserProfile(
    id: id,
    email: email,
    name: name ?? this.name,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
  );
  Map<String, Object> toJson() => {
    'uid': id,
    'email': email,
    'displayName': name,
    'onboardingComplete': onboardingComplete,
  };
  factory UserProfile.fromJson(Map<String, dynamic> data) => UserProfile(
    id: data['uid'] as String,
    email: data['email'] as String? ?? '',
    name: data['displayName'] as String? ?? 'Member',
    onboardingComplete: data['onboardingComplete'] == true,
  );
}
