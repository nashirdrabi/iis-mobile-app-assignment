import 'support/load_design_fonts.dart';
import 'package:iis_mobile_application/core/widgets/sanctuary_brand.dart';
import 'package:iis_mobile_application/features/auth/presentation/auth_pages.dart';
import 'package:iis_mobile_application/features/auth/presentation/auth_theme.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iis_mobile_application/features/auth/domain/auth_repository.dart';
import 'package:iis_mobile_application/features/auth/domain/user_profile.dart';
import 'package:iis_mobile_application/features/auth/presentation/auth_state.dart';
import 'package:iis_mobile_application/features/kintree/kintree_app.dart';
import 'package:iis_mobile_application/features/meditation/meditation_app.dart';

class _VisualRepository implements AuthRepository {
  const _VisualRepository();
  static const profile = UserProfile(
    id: 'visual-review',
    email: 'murphy@example.com',
    name: 'Murphy Sharma',
  );
  @override
  Future<UserProfile?> currentUser() async => profile;
  @override
  Future<UserProfile> signIn(String email, String password) async => profile;
  @override
  Future<UserProfile> createAccount(
    String name,
    String email,
    String password,
  ) async => profile;
  @override
  Future<UserProfile> updateName(String name) async =>
      profile.copyWith(name: name);
  @override
  Future<void> completeOnboarding() async {}
  @override
  Future<void> signOut() async {}
}

class _VisualBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}

void main() {
  _VisualBinding();
  setUpAll(loadDesignFonts);

  testWidgets(
    'Render nine Figma screens and shared auth/splash without layout errors',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final capture = GlobalKey();
      final frames = <(String, double, Widget)>[
        ('meditation_home', 1115, const MeditationApp(initialTab: 0)),
        ('meditation_albums', 864, const MeditationApp(initialTab: 1)),
        ('meditation_playlists', 862, const MeditationApp(initialTab: 2)),
        ('meditation_profile', 844, const MeditationApp(initialTab: 3)),
        ('meditation_settings', 1142, const MusicSettingsPage()),
        ('kintree_home', 2125, const KinTreeApp(initialTab: 0)),
        ('kintree_tree', 1272, const KinTreeApp(initialTab: 1)),
        ('kintree_chat', 3030, const KinTreeApp(initialTab: 2)),
        ('kintree_profile', 1684, const KinTreeApp(initialTab: 3)),
        ('auth_splash', 844, const SanctuarySplash()),
        ('auth_onboarding', 844, const OnboardingPage()),
        ('auth_login', 844, const LoginPage()),
        ('auth_register', 844, const RegisterPage()),
      ];
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final frame in frames) {
        tester.view.physicalSize = Size(390, frame.$2);
        await tester.pumpWidget(
          ProviderScope(
            key: ValueKey(frame.$1),
            overrides: [
              preferencesProvider.overrideWithValue(preferences),
              authRepositoryProvider.overrideWithValue(
                const _VisualRepository(),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: authTheme(),
              home: RepaintBoundary(key: capture, child: frame.$3),
            ),
          ),
        );
        if (frame.$1 == 'auth_splash') {
          await tester.pump(const Duration(milliseconds: 500));
        } else {
          await tester.pumpAndSettle();
        }
        await tester.runAsync(() async {
          for (final file
              in Directory('assets/images').listSync().whereType<File>().where(
                (f) => f.path.endsWith('.png') || f.path.endsWith('.jpg'),
              )) {
            await precacheImage(AssetImage(file.path), capture.currentContext!);
          }
        });
        if (frame.$1 == 'auth_splash') {
          await tester.pump(const Duration(milliseconds: 500));
        } else {
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull, reason: frame.$1);
        await tester.runAsync(() async {
          final boundary =
              capture.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('design_review/current/${frame.$1}.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets('Every tab lays out at 320 logical pixels', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 780);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final page in <Widget>[
      for (var i = 0; i < 4; i++) KinTreeApp(initialTab: i),
      for (var i = 0; i < 4; i++) MeditationApp(initialTab: i),
      const MusicSettingsPage(),
    ]) {
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            preferencesProvider.overrideWithValue(preferences),
            authRepositoryProvider.overrideWithValue(const _VisualRepository()),
          ],
          child: MaterialApp(home: page),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: page.runtimeType.toString(),
      );
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
