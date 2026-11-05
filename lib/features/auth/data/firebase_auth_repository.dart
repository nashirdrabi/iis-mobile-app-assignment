import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/auth_repository.dart';
import '../domain/user_profile.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : auth = auth ?? FirebaseAuth.instance,
      firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  @override
  Future<UserProfile?> currentUser() async {
    final user = auth.currentUser;
    if (user == null) return null;
    return _ensureProfile(user);
  }

  @override
  Future<UserProfile> signIn(String email, String password) async {
    final result = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = result.user!;
    return _ensureProfile(user);
  }

  @override
  Future<UserProfile> createAccount(
    String name,
    String email,
    String password,
  ) async {
    final result = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = result.user!;
    await user.updateDisplayName(name.trim());
    await firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'displayName': name.trim(),
      'email': email.trim(),
      'onboardingComplete': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return UserProfile(id: user.uid, email: email.trim(), name: name.trim());
  }

  @override
  Future<UserProfile> updateName(String name) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Sign in to edit your profile.');
    await user.updateDisplayName(name.trim());
    await firestore.collection('users').doc(user.uid).set({
      'displayName': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return UserProfile(
      id: user.uid,
      email: user.email ?? '',
      name: name.trim(),
    );
  }

  @override
  Future<void> completeOnboarding() async {
    final user = auth.currentUser;
    if (user == null) return;
    await firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName ?? 'Member',
      'onboardingComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> signOut() => auth.signOut();

  UserProfile _profile(User user, Map<String, dynamic>? data) => UserProfile(
    id: user.uid,
    email: user.email ?? '',
    name: data?['displayName'] as String? ?? user.displayName ?? 'Member',
  );

  Future<UserProfile> _ensureProfile(User user) async {
    final reference = firestore.collection('users').doc(user.uid);
    final snapshot = await reference.get();
    final data = snapshot.data();
    if (data == null) {
      final profile = _profile(user, null);
      await reference.set({
        'uid': user.uid,
        'displayName': profile.name,
        'email': profile.email,
        'onboardingComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return profile;
    }
    await reference.set({
      'uid': user.uid,
      'displayName': data['displayName'] ?? user.displayName ?? 'Member',
      'email': data['email'] ?? user.email ?? '',
      'onboardingComplete': data['onboardingComplete'] ?? false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return _profile(user, data);
  }
}
