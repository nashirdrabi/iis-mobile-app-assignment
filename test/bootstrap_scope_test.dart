import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iis_mobile_application/app.dart';
import 'package:iis_mobile_application/main.dart';
import 'package:iis_mobile_application/features/auth/presentation/auth_pages.dart';
import 'package:iis_mobile_application/features/auth/presentation/auth_state.dart';
import 'package:iis_mobile_application/features/meditation/presentation/meditation_state.dart';
import 'auth_and_cache_test.dart' show StubAuthRepository;
import 'support/load_design_fonts.dart';
import 'package:iis_mobile_application/features/auth/domain/user_profile.dart';

class StartupFailureRepository extends StubAuthRepository {
  @override
  Future<UserProfile?> currentUser() async =>
      throw StateError('internal startup diagnostic');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadDesignFonts);
  late SharedPreferences preferences;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  test('nested bootstrap scope supplies preferences to derived providers', () {
    final parent = ProviderContainer();
    final child = ProviderContainer(
      parent: parent,
      overrides: [preferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(() {
      child.dispose();
      parent.dispose();
    });
    expect(child.read(onboardingProvider), isFalse);
    expect(child.read(profileCacheProvider).introductionSeen, isFalse);
  });

  test('playlist providers use storage from the application scope', () async {
    await preferences.setStringList('assignment.music.guest.playlists', [
      'Saved practice',
    ]);
    final parent = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(StubAuthRepository()),
      ],
    );
    final child = ProviderContainer(
      parent: parent,
      overrides: [preferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(() {
      child.dispose();
      parent.dispose();
    });
    expect(child.read(playlistsProvider), ['Saved practice']);
  });

  testWidgets(
    'real bootstrap hierarchy reaches onboarding and login without a provider error',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bootstrapProvider.overrideWith((ref) async => preferences),
            authRepositoryProvider.overrideWithValue(StubAuthRepository()),
          ],
          child: const BootstrapApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(OnboardingPage), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Get started'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Get started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(EntryGate), findsOneWidget);
    },
  );
  testWidgets('unexpected startup errors show a safe retry message', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWithValue(preferences),
          authRepositoryProvider.overrideWithValue(StartupFailureRepository()),
        ],
        child: const MaterialApp(home: EntryGate()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AuthErrorPage), findsOneWidget);
    expect(
      find.text('We could not connect to your account. Please try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('internal startup diagnostic'), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
