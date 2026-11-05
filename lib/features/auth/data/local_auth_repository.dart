import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_repository.dart';
import '../domain/user_profile.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this.preferences);
  final SharedPreferences preferences;
  static const _id = 'assignment.user.id';
  static const _email = 'assignment.user.email';
  static const _name = 'assignment.user.name';

  @override
  Future<UserProfile?> currentUser() async {
    final id = preferences.getString(_id);
    if (id == null) return null;
    return UserProfile(
      id: id,
      email: preferences.getString(_email) ?? '',
      name: preferences.getString(_name) ?? 'Member',
    );
  }

  @override
  Future<UserProfile> signIn(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw Exception('Enter your email and password.');
    }
    final profile = UserProfile(
      id: email.trim().toLowerCase(),
      email: email.trim(),
      name: preferences.getString(_name) ?? email.split('@').first,
    );
    await _save(profile);
    return profile;
  }

  @override
  Future<UserProfile> createAccount(
    String name,
    String email,
    String password,
  ) async {
    if (name.trim().isEmpty || !email.contains('@') || password.length < 6) {
      throw Exception(
        'Enter a name, valid email, and password with 6+ characters.',
      );
    }
    final profile = UserProfile(
      id: email.trim().toLowerCase(),
      email: email.trim(),
      name: name.trim(),
    );
    await _save(profile);
    return profile;
  }

  @override
  Future<UserProfile> updateName(String name) async {
    final profile = await currentUser();
    if (profile == null) throw Exception('Sign in to edit your profile.');
    final updated = profile.copyWith(name: name.trim());
    await _save(updated);
    return updated;
  }

  @override
  Future<void> completeOnboarding() async {
    final profile = await currentUser();
    if (profile == null) return;
    await preferences.setBool('assignment.user.${profile.id}.onboarding', true);
  }

  @override
  Future<void> signOut() async {
    await preferences.remove(_id);
    await preferences.remove(_email);
    await preferences.remove(_name);
  }

  Future<void> _save(UserProfile profile) async {
    await preferences.setString(_id, profile.id);
    await preferences.setString(_email, profile.email);
    await preferences.setString(_name, profile.name);
  }
}
