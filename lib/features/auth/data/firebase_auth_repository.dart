import 'firestore_profile_store.dart';
import '../domain/user_profile_store.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/profile_cache.dart';
import '../domain/user_profile.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    UserProfileStore? profileStore,
    required this.cache,
  }) : auth = auth ?? FirebaseAuth.instance,
       store =
           profileStore ??
           FirestoreProfileStore(firestore ?? FirebaseFirestore.instance);
  final FirebaseAuth auth;
  final UserProfileStore store;
  final ProfileCache cache;
  static const networkTimeout = Duration(seconds: 12);

  @override
  Future<UserProfile?> currentUser() async {
    final user = auth.currentUser;
    if (user == null) return null;
    try {
      final stored = await store.read(user.uid);
      if (stored != null) {
        final profile = stored;
        await _cacheBestEffort(profile);
        return profile;
      }
      final profile = _profile(user, null);
      await _save(profile, created: true);
      return profile;
    } on TimeoutException {
      return _cachedOrThrow(user.uid);
    } on FirebaseException catch (error) {
      if (error.code == 'unavailable' || error.code == 'deadline-exceeded') {
        return _cachedOrThrow(user.uid);
      }
      throw _failure(error.code);
    }
  }

  // A cache never creates a session: a Firebase-authenticated UID is mandatory.
  UserProfile _cachedOrThrow(String uid) {
    final profile = cache.read(uid);
    if (profile != null) return profile;
    throw const AuthFailure(
      'Connect to the internet to load this account for the first time, then tap Retry.',
    );
  }

  @override
  Future<UserProfile> signIn(String email, String password) async {
    try {
      await auth
          .signInWithEmailAndPassword(email: email.trim(), password: password)
          .timeout(networkTimeout);
      return (await currentUser())!;
    } on FirebaseAuthException catch (error) {
      throw _failure(error.code);
    } on TimeoutException {
      throw const AuthFailure(
        'The connection timed out. Check your internet and try again.',
      );
    }
  }

  @override
  Future<UserProfile> createAccount(
    String name,
    String email,
    String password,
  ) async {
    try {
      final result = await auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(networkTimeout);
      final user = result.user!;
      await user.updateDisplayName(name.trim());
      final profile = UserProfile(
        id: user.uid,
        email: user.email ?? email.trim(),
        name: name.trim(),
        onboardingComplete: cache.introductionSeen,
      );
      await _save(profile, created: true);
      return profile;
    } on FirebaseAuthException catch (error) {
      throw _failure(error.code);
    } on FirebaseException catch (error) {
      throw _failure(error.code);
    } on TimeoutException {
      throw const AuthFailure(
        'Account setup timed out. If the account was created, sign in again to finish setup.',
      );
    }
  }

  @override
  Future<UserProfile> updateName(String name) async {
    final user = auth.currentUser;
    if (user == null) throw const AuthFailure('Sign in to edit your profile.');
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const AuthFailure('Enter your display name.');
    try {
      final current = await currentUser();
      final updated = current!.copyWith(name: trimmed);
      await _save(updated);
      await user.updateDisplayName(trimmed);
      return updated;
    } on FirebaseException catch (error) {
      throw _failure(error.code);
    } on TimeoutException {
      throw const AuthFailure(
        'Could not save your profile. Check your connection and try again.',
      );
    }
  }

  @override
  Future<void> completeOnboarding() async {
    final user = auth.currentUser;
    if (user == null) return;
    try {
      final current = await currentUser();
      await _save(current!.copyWith(onboardingComplete: true));
    } on FirebaseException catch (error) {
      throw _failure(error.code);
    } on TimeoutException {
      throw const AuthFailure(
        'Onboarding could not sync. Reconnect and try again.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    final uid = auth.currentUser?.uid;
    await auth.signOut();
    if (uid != null) {
      try {
        await cache.clear(uid);
      } catch (_) {
        /* A failed cache cleanup cannot restore a Firebase session. */
      }
    }
  }

  UserProfile _profile(User user, Map<String, dynamic>? data) => UserProfile(
    id: user.uid,
    email: user.email ?? '',
    name: data?['displayName'] as String? ?? user.displayName ?? 'Member',
    onboardingComplete: data?['onboardingComplete'] == true,
  );

  Future<void> _save(UserProfile profile, {bool created = false}) async {
    await store.save(profile, created: created);
    await _cacheBestEffort(profile);
  }

  Future<void> _cacheBestEffort(UserProfile profile) async {
    try {
      await cache.write(profile);
    } catch (_) {
      /* Firestore remains the profile source of truth. */
    }
  }

  AuthFailure _failure(String code) => AuthFailure(switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'The email or password is incorrect.',
    'invalid-email' => 'Enter a valid email address.',
    'email-already-in-use' =>
      'This email already has an account. Please sign in.',
    'weak-password' => 'Use a stronger password with at least six characters.',
    'network-request-failed' ||
    'unavailable' => 'Check your internet connection and try again.',
    'too-many-requests' =>
      'Too many attempts. Please wait a moment before trying again.',
    'user-disabled' => 'This account has been disabled. Contact support.',
    'operation-not-allowed' =>
      'Email/password sign-in must be enabled in Firebase Authentication.',
    'permission-denied' =>
      'Your profile could not be accessed. Check the Firestore users collection rules.',
    _ => 'The account request could not be completed. Please try again.',
  });
}
