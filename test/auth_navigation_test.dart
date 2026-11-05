import 'package:iis_mobile_application/features/auth/presentation/auth_theme.dart';
import 'support/load_design_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iis_mobile_application/app.dart';
import 'package:iis_mobile_application/core/widgets/design_icon.dart';
import 'package:iis_mobile_application/core/routing/app_routes.dart';
import 'package:iis_mobile_application/features/auth/presentation/auth_pages.dart';
import 'package:iis_mobile_application/features/auth/presentation/auth_state.dart';
import 'package:iis_mobile_application/features/auth/domain/auth_failure.dart';
import 'package:iis_mobile_application/features/auth/domain/user_profile.dart';
import 'auth_and_cache_test.dart' show StubAuthRepository;

void main() {
  setUpAll(loadDesignFonts);
  late SharedPreferences preferences;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });
  Future<void> mount(WidgetTester tester, StubAuthRepository repo) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWithValue(preferences),
          authRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: authTheme(),
          routes: {AppRoutes.register: (_) => const RegisterPage()},
          home: const EntryGate(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('first launch completes introduction then opens login', (
    tester,
  ) async {
    await mount(tester, StubAuthRepository());
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
    expect(find.byType(LoginPage), findsOneWidget);
    expect(preferences.getBool('assignment.onboarding.complete'), isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'signed-in incomplete onboarding overrides a completed device introduction',
    (tester) async {
      await preferences.setBool('assignment.onboarding.complete', true);
      await mount(
        tester,
        StubAuthRepository(
          user: const UserProfile(id: 'a', email: 'e', name: 'A'),
        ),
      );
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
      expect(find.byType(ExperienceChooser), findsOneWidget);
    },
  );
  testWidgets('invalid login stays on login and displays a readable error', (
    tester,
  ) async {
    await preferences.setBool('assignment.onboarding.complete', true);
    await mount(
      tester,
      StubAuthRepository()..failure = const AuthFailure('Incorrect password'),
    );
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@example.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect password'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(AuthErrorPage), findsNothing);
  });
  testWidgets('login validation prevents empty submissions', (tester) async {
    await preferences.setBool('assignment.onboarding.complete', true);
    await mount(tester, StubAuthRepository());
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });
  testWidgets(
    'registration routes back to the chooser after creating a profile',
    (tester) async {
      await preferences.setBool('assignment.onboarding.complete', true);
      await mount(tester, StubAuthRepository());
      await tester.ensureVisible(find.text('Create an account'));
      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterPage), findsOneWidget);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Member');
      await tester.enterText(fields.at(1), 'member@example.test');
      await tester.enterText(fields.at(2), 'password123');
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceChooser), findsOneWidget);
      expect(find.byType(RegisterPage), findsNothing);
    },
  );
  testWidgets('onboarding and authentication fit a 320px device', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 780);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester, StubAuthRepository());
    expect(tester.takeException(), isNull);
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
  });
  testWidgets(
    'both app experiences can return to the chooser without signing out',
    (tester) async {
      final repo = StubAuthRepository(
        user: const UserProfile(
          id: 'a',
          email: 'e',
          name: 'A',
          onboardingComplete: true,
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesProvider.overrideWithValue(preferences),
            authRepositoryProvider.overrideWithValue(repo),
          ],
          child: const AssignmentApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceChooser), findsOneWidget);
      await tester.tap(find.text('KinTree'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Profile and app options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Switch app'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceChooser), findsOneWidget);
      await tester.tap(find.text('Meditation & Music'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is DesignIcon && w.icon == Icons.menu_rounded,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Switch app'));
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceChooser), findsOneWidget);
      expect(repo.user, isNotNull);
    },
  );
}
