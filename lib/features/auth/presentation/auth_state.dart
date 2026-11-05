import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/firebase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/user_profile.dart';

final preferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(),
);
final authProvider = AsyncNotifierProvider<AuthController, UserProfile?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<UserProfile?> {
  late AuthRepository repository;

  @override
  Future<UserProfile?> build() {
    repository = ref.watch(authRepositoryProvider);
    return repository.currentUser();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.signIn(email, password));
  }

  Future<void> createAccount(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repository.createAccount(name, email, password),
    );
  }

  Future<void> updateName(String name) async {
    state = await AsyncValue.guard(() => repository.updateName(name));
  }

  Future<void> signOut() async {
    await repository.signOut();
    state = const AsyncData(null);
  }
}

final onboardingProvider = Provider<bool>(
  (ref) =>
      ref
          .watch(preferencesProvider)
          .getBool('assignment.onboarding.complete') ??
      false,
);

Future<void> completeOnboarding(WidgetRef ref) async {
  await ref
      .read(preferencesProvider)
      .setBool('assignment.onboarding.complete', true);
  ref.invalidate(onboardingProvider);
  await ref.read(authRepositoryProvider).completeOnboarding();
}

final playlistsProvider = NotifierProvider<PlaylistsController, List<String>>(
  PlaylistsController.new,
);

class PlaylistsController extends Notifier<List<String>> {
  static const _key = 'assignment.music.playlists';
  @override
  List<String> build() =>
      ref.watch(preferencesProvider).getStringList(_key) ??
      [
        'Daily Twin Hearts Routine',
        'Evening Aura Cleansing & Chakra Healing',
        'Arhatic Dhyan & Kundalini',
      ];
  Future<void> add(String value) async {
    final next = [value, ...state];
    state = next;
    await ref.read(preferencesProvider).setStringList(_key, next);
  }
}

final playingTrackProvider = NotifierProvider<PlayingTrackController, String?>(
  PlayingTrackController.new,
);

class PlayingTrackController extends Notifier<String?> {
  @override
  String? build() => null;
  void play(String track) => state = track;
  void stop() => state = null;
}
