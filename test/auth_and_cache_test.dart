import 'package:mock_exceptions/mock_exceptions.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:iis_mobile_application/features/auth/data/firebase_auth_repository.dart';
import 'package:iis_mobile_application/features/auth/data/preferences_profile_cache.dart';
import 'package:iis_mobile_application/features/auth/domain/auth_failure.dart';
import 'package:iis_mobile_application/features/auth/domain/auth_repository.dart';
import 'package:iis_mobile_application/features/auth/domain/user_profile.dart';
import 'package:iis_mobile_application/features/auth/presentation/auth_state.dart';
import 'package:iis_mobile_application/features/meditation/data/preferences_playlist_repository.dart';

class StubAuthRepository implements AuthRepository {
  UserProfile? user;
  Object? failure;
  Completer<UserProfile>? pending;
  StubAuthRepository({this.user});
  @override
  Future<UserProfile?> currentUser() async => user;
  @override
  Future<UserProfile> signIn(String email, String password) async {
    if (failure != null) throw failure!;
    return pending != null
        ? pending!.future
        : user = const UserProfile(
            id: 'account',
            email: 'test@example.test',
            name: 'Test Member',
            onboardingComplete: true,
          );
  }

  @override
  Future<UserProfile> createAccount(
    String name,
    String email,
    String password,
  ) async => user = UserProfile(
    id: 'account',
    email: email,
    name: name,
    onboardingComplete: true,
  );
  @override
  Future<UserProfile> updateName(String name) async {
    if (failure != null) throw failure!;
    return user = user!.copyWith(name: name);
  }

  @override
  Future<void> completeOnboarding() async {
    if (failure != null) throw failure!;
    user = user?.copyWith(onboardingComplete: true);
  }

  @override
  Future<void> signOut() async {
    user = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences preferences;
  late PreferencesProfileCache cache;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    cache = PreferencesProfileCache(preferences);
  });
  test(
    'profile cache round-trip includes onboarding and is UID scoped',
    () async {
      const profile = UserProfile(
        id: 'a',
        email: 'a@example.test',
        name: 'A',
        onboardingComplete: true,
      );
      await cache.write(profile);
      expect(cache.read('a')!.onboardingComplete, isTrue);
      expect(cache.read('a')!.name, 'A');
      expect(cache.read('b'), isNull);
      await cache.clear('a');
      expect(cache.read('a'), isNull);
    },
  );
  test('corrupted cache never creates a profile', () async {
    await preferences.setString('assignment.profile.a', '{broken');
    expect(cache.read('a'), isNull);
  });
  test('introduction flag persists across cache instances', () async {
    expect(cache.introductionSeen, isFalse);
    await cache.markIntroductionSeen();
    expect(PreferencesProfileCache(preferences).introductionSeen, isTrue);
  });
  test(
    'playlists persist per user without leaking to another account',
    () async {
      final first = PreferencesPlaylistRepository(preferences, owner: 'a');
      await first.save(['My practice']);
      expect(PreferencesPlaylistRepository(preferences, owner: 'a').read(), [
        'My practice',
      ]);
      expect(
        PreferencesPlaylistRepository(preferences, owner: 'b').read(),
        PreferencesPlaylistRepository.defaults,
      );
    },
  );
  test('Firebase signed-out session ignores any cached user', () async {
    await cache.write(
      const UserProfile(
        id: 'uid',
        email: 'e',
        name: 'N',
        onboardingComplete: true,
      ),
    );
    final repository = FirebaseAuthRepository(
      auth: MockFirebaseAuth(),
      firestore: FakeFirebaseFirestore(),
      cache: cache,
    );
    expect(await repository.currentUser(), isNull);
  });
  test(
    'Firebase registration stores basic profile and completed introduction',
    () async {
      await cache.markIntroductionSeen();
      final firestore = FakeFirebaseFirestore();
      final repository = FirebaseAuthRepository(
        auth: MockFirebaseAuth(),
        firestore: firestore,
        cache: cache,
      );
      final profile = await repository.createAccount(
        '  Member  ',
        'member@example.test',
        'password123',
      );
      final data = (await firestore.collection('users').doc(profile.id).get())
          .data()!;
      expect(data['displayName'], 'Member');
      expect(data['onboardingComplete'], isTrue);
      expect(data['email'], 'member@example.test');
      expect(data['createdAt'], isNotNull);
      expect(cache.read(profile.id)!.name, 'Member');
    },
  );
  test(
    'existing Firebase account with missing profile resumes onboarding',
    () async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'uid',
          email: 'test@example.test',
          displayName: 'Member',
        ),
        signedIn: true,
      );
      final repository = FirebaseAuthRepository(
        auth: auth,
        firestore: firestore,
        cache: cache,
      );
      final profile = await repository.currentUser();
      expect(profile!.onboardingComplete, isFalse);
      await repository.completeOnboarding();
      expect((await repository.currentUser())!.onboardingComplete, isTrue);
      expect(
        (await firestore.collection('users').doc('uid').get())
            .data()!['onboardingComplete'],
        isTrue,
      );
    },
  );
  test(
    'profile update retains onboarding and signout removes the local profile',
    () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'uid', email: 'test@example.test'),
        signedIn: true,
      );
      final repository = FirebaseAuthRepository(
        auth: auth,
        firestore: FakeFirebaseFirestore(),
        cache: cache,
      );
      await repository.currentUser();
      await repository.completeOnboarding();
      final updated = await repository.updateName('Updated');
      expect(updated.name, 'Updated');
      expect(updated.onboardingComplete, isTrue);
      await repository.signOut();
      expect(auth.currentUser, isNull);
      expect(cache.read('uid'), isNull);
    },
  );
  test('invalid Firebase credentials become a readable domain error', () async {
    final auth = MockFirebaseAuth();
    whenCalling(
      Invocation.method(#signInWithEmailAndPassword, null),
    ).on(auth).thenThrow(FirebaseAuthException(code: 'invalid-credential'));
    final repository = FirebaseAuthRepository(
      auth: auth,
      firestore: FakeFirebaseFirestore(),
      cache: cache,
    );
    await expectLater(
      repository.signIn('test@example.test', 'bad'),
      throwsA(
        isA<AuthFailure>().having(
          (e) => e.message,
          'message',
          contains('incorrect'),
        ),
      ),
    );
  });
  test(
    'failed sign-in does not replace the signed-out session with an error',
    () async {
      final repo = StubAuthRepository()
        ..failure = const AuthFailure('Invalid login');
      final container = ProviderContainer(
        overrides: [
          preferencesProvider.overrideWithValue(preferences),
          authRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);
      expect(
        await container.read(authProvider.notifier).signIn('e', 'p'),
        isFalse,
      );
      expect(container.read(authProvider).value, isNull);
      expect(container.read(authProvider).hasError, isFalse);
      expect(container.read(authActionProvider).hasError, isTrue);
    },
  );
  test('failed profile save keeps the signed-in user', () async {
    final repo = StubAuthRepository(
      user: const UserProfile(
        id: 'a',
        email: 'e',
        name: 'Original',
        onboardingComplete: true,
      ),
    )..failure = const AuthFailure('Offline');
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(preferences),
        authRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authProvider.future);
    expect(
      await container.read(authProvider.notifier).updateName('New'),
      isFalse,
    );
    expect(container.read(authProvider).value!.name, 'Original');
  });
  test('onboarding failure does not mark local completion', () async {
    final repo = StubAuthRepository(
      user: const UserProfile(id: 'a', email: 'e', name: 'A'),
    )..failure = const AuthFailure('Offline');
    final container = ProviderContainer(
      overrides: [
        preferencesProvider.overrideWithValue(preferences),
        authRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authProvider.future);
    expect(
      await container.read(authProvider.notifier).completeIntroduction(),
      isFalse,
    );
    expect(cache.introductionSeen, isFalse);
    expect(container.read(authProvider).value!.onboardingComplete, isFalse);
  });
  test(
    'successful onboarding updates account state and persistent local flag',
    () async {
      final repo = StubAuthRepository(
        user: const UserProfile(id: 'a', email: 'e', name: 'A'),
      );
      final container = ProviderContainer(
        overrides: [
          preferencesProvider.overrideWithValue(preferences),
          authRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);
      expect(
        await container.read(authProvider.notifier).completeIntroduction(),
        isTrue,
      );
      expect(cache.introductionSeen, isTrue);
      expect(container.read(authProvider).value!.onboardingComplete, isTrue);
    },
  );
}
