import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/profile_cache.dart';
import '../domain/user_profile.dart';

class PreferencesProfileCache implements ProfileCache {
  PreferencesProfileCache(this.preferences);
  final SharedPreferences preferences;
  static const introductionKey = 'assignment.onboarding.complete';
  String _key(String uid) => 'assignment.profile.$uid';
  @override
  UserProfile? read(String uid) {
    final raw = preferences.getString(_key(uid));
    if (raw == null) return null;
    try {
      final profile = UserProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return profile.id == uid ? profile : null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<void> write(UserProfile profile) async {
    if (!await preferences.setString(
      _key(profile.id),
      jsonEncode(profile.toJson()),
    )) {
      throw const FormatException('Could not save the local profile cache.');
    }
  }

  @override
  Future<void> clear(String uid) async {
    await preferences.remove(_key(uid));
  }

  @override
  bool get introductionSeen => preferences.getBool(introductionKey) ?? false;
  @override
  Future<void> markIntroductionSeen() async {
    if (!await preferences.setBool(introductionKey, true)) {
      throw const FormatException('Could not save onboarding progress.');
    }
  }
}
