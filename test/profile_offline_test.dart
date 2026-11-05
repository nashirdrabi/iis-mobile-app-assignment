import 'package:iis_mobile_application/features/auth/domain/user_profile_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iis_mobile_application/features/auth/data/firebase_auth_repository.dart';
import 'package:iis_mobile_application/features/auth/data/preferences_profile_cache.dart';
import 'package:iis_mobile_application/features/auth/domain/auth_failure.dart';
import 'package:iis_mobile_application/features/auth/domain/user_profile.dart';

class _UnavailableStore implements UserProfileStore {
  _UnavailableStore(this.code);
  final String code;
  @override
  Future<UserProfile?> read(String uid) async =>
      throw FirebaseException(plugin: 'cloud_firestore', code: code);
  @override
  Future<void> save(UserProfile profile, {bool created = false}) async =>
      throw FirebaseException(plugin: 'cloud_firestore', code: code);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final code in ['unavailable', 'permission-denied']) {
    test('offline fallback is limited to network failures: $code', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final cache = PreferencesProfileCache(preferences);
      await cache.write(
        const UserProfile(
          id: 'owner',
          email: 'e',
          name: 'Cached',
          onboardingComplete: true,
        ),
      );
      final repository = FirebaseAuthRepository(
        auth: MockFirebaseAuth(
          mockUser: MockUser(uid: 'owner'),
          signedIn: true,
        ),
        profileStore: _UnavailableStore(code),
        cache: cache,
      );
      if (code == 'unavailable') {
        expect((await repository.currentUser())!.name, 'Cached');
      } else {
        await expectLater(
          repository.currentUser(),
          throwsA(isA<AuthFailure>()),
        );
      }
    });
  }
  test(
    'first-time offline account receives a retryable connection error',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = FirebaseAuthRepository(
        auth: MockFirebaseAuth(
          mockUser: MockUser(uid: 'uncached'),
          signedIn: true,
        ),
        profileStore: _UnavailableStore('unavailable'),
        cache: PreferencesProfileCache(preferences),
      );
      await expectLater(
        repository.currentUser(),
        throwsA(
          isA<AuthFailure>().having(
            (e) => e.message,
            'message',
            contains('internet'),
          ),
        ),
      );
    },
  );
}
