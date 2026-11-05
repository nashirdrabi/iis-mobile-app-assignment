import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/firebase_auth_repository.dart';
import '../data/preferences_profile_cache.dart';
import '../domain/auth_repository.dart';
import '../domain/profile_cache.dart';
import '../domain/user_profile.dart';

final preferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Bootstrap must supply SharedPreferences.'),
);
final profileCacheProvider = Provider<ProfileCache>(
  (ref) => PreferencesProfileCache(ref.watch(preferencesProvider)),
);
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(cache: ref.watch(profileCacheProvider)),
);
final authProvider = AsyncNotifierProvider<AuthController, UserProfile?>(
  AuthController.new,
);
final authActionProvider =
    NotifierProvider<AuthActionController, AsyncValue<void>>(
      AuthActionController.new,
    );

class AuthActionController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);
  void loading() => state = const AsyncLoading();
  void success() => state = const AsyncData(null);
  void fail(Object error, StackTrace stack) => state = AsyncError(error, stack);
  void clear() => state = const AsyncData(null);
}

class AuthController extends AsyncNotifier<UserProfile?> {
  AuthRepository get repository => ref.read(authRepositoryProvider);
  @override
  Future<UserProfile?> build() =>
      ref.watch(authRepositoryProvider).currentUser();
  Future<bool> _perform(Future<UserProfile?> Function() action) async {
    final status = ref.read(authActionProvider.notifier);
    if (ref.read(authActionProvider).isLoading) return false;
    status.loading();
    try {
      final result = await action();
      state = AsyncData(result);
      status.success();
      return true;
    } catch (error, stack) {
      status.fail(error, stack);
      return false;
    }
  }

  Future<bool> signIn(String email, String password) =>
      _perform(() => repository.signIn(email, password));
  Future<bool> createAccount(String name, String email, String password) =>
      _perform(() => repository.createAccount(name, email, password));
  Future<bool> updateName(String name) =>
      _perform(() => repository.updateName(name));
  Future<bool> signOut() => _perform(() async {
    await repository.signOut();
    return null;
  });
  Future<bool> completeIntroduction() => _perform(() async {
    await repository.completeOnboarding();
    await ref.read(profileCacheProvider).markIntroductionSeen();
    ref.invalidate(onboardingProvider);
    return state.value?.copyWith(onboardingComplete: true);
  });
}

final onboardingProvider = Provider<bool>(
  (ref) => ref.watch(profileCacheProvider).introductionSeen,
);
Future<bool> completeOnboarding(WidgetRef ref) =>
    ref.read(authProvider.notifier).completeIntroduction();
