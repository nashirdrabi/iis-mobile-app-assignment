import 'user_profile.dart';

abstract interface class ProfileCache {
  UserProfile? read(String uid);
  Future<void> write(UserProfile profile);
  Future<void> clear(String uid);
  bool get introductionSeen;
  Future<void> markIntroductionSeen();
}
