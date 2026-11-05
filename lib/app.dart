import 'features/auth/presentation/auth_theme.dart';
import 'core/widgets/sanctuary_brand.dart';
import 'features/meditation/meditation_design_system.dart';
import 'core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/presentation/auth_pages.dart';
import 'features/auth/presentation/auth_state.dart';
import 'features/auth/presentation/auth_error_message.dart';
import 'features/kintree/kintree_app.dart';
import 'features/meditation/meditation_app.dart';
import 'core/theme/palette.dart';

class AssignmentApp extends StatelessWidget {
  const AssignmentApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'IIS Mobile Application',
    debugShowCheckedModeBanner: false,
    theme: authTheme(),
    routes: {
      AppRoutes.register: (_) => const RegisterPage(),
      AppRoutes.kinTree: (_) => const KinTreeApp(),
      AppRoutes.meditation: (_) => const MeditationApp(),
      AppRoutes.settings: (_) => const MusicSettingsPage(),
    },
    home: const SplashScreen(),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, animation, _) => const EntryGate(),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 280),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const SanctuarySplash();
}

class EntryGate extends ConsumerWidget {
  const EntryGate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return auth.when(
      loading: () => const Scaffold(
        backgroundColor: MeditationPalette.canvas,
        body: Center(
          child: CircularProgressIndicator(
            color: MeditationPalette.primary,
            strokeWidth: 2.5,
          ),
        ),
      ),
      error: (error, _) => AuthErrorPage(message: authErrorMessage(error)),
      data: (user) {
        if (user != null) {
          return user.onboardingComplete
              ? const ExperienceChooser()
              : const OnboardingPage();
        }
        if (!ref.watch(onboardingProvider)) return const OnboardingPage();
        return const LoginPage();
      },
    );
  }
}

class ExperienceChooser extends ConsumerWidget {
  const ExperienceChooser({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              const SizedBox(height: 36),
              const Icon(Icons.auto_awesome_rounded, size: 40, color: forest),
              const SizedBox(height: 18),
              const Text(
                'Choose your experience',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'One sign-in for your family heritage and daily practice.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),
              _ExperienceCard(
                title: 'KinTree',
                detail: 'Family stories, heritage and conversations',
                icon: Icons.account_tree_rounded,
                color: const Color(0xFFE5EEE8),
                onTap: () => Navigator.pushNamed(context, AppRoutes.kinTree),
              ),
              const SizedBox(height: 14),
              _ExperienceCard(
                title: 'Meditation & Music',
                detail: 'Guided practice, albums and playlists',
                icon: Icons.spa_rounded,
                color: const Color(0xFFF0E9FF),
                onTap: () => Navigator.pushNamed(context, AppRoutes.meditation),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.title,
    required this.detail,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String title, detail;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    color: color,
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: Colors.white,
              child: Icon(icon, color: forest),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    ),
  );
}
