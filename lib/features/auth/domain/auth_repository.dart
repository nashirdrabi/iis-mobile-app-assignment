import 'user_profile.dart';

abstract interface class AuthRepository {
  Future<UserProfile?> currentUser();
  Future<UserProfile> signIn(String email, String password);
  Future<UserProfile> createAccount(String name, String email, String password);
  Future<UserProfile> updateName(String name);
  Future<void> completeOnboarding();
  Future<void> signOut();
}
