import 'user_profile.dart';

abstract interface class UserProfileStore {
  Future<UserProfile?> read(String uid);
  Future<void> save(UserProfile profile, {bool created = false});
}
