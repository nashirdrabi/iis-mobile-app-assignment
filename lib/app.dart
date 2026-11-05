import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/presentation/auth_pages.dart';
import 'features/auth/presentation/auth_state.dart';
import 'features/kintree/kintree_app.dart';
import 'features/meditation/meditation_app.dart';
import 'core/theme/palette.dart';

class AssignmentApp extends StatelessWidget {
  const AssignmentApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'IIS Mobile Application',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: false,
      fontFamily: 'Georgia',
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(seedColor: forest),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE9E6DF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE9E6DF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: forest, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: paper,
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: forest,
                borderRadius: BorderRadius.circular(34),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x25214D3F),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_tree_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'KinTree',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: forest,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Every branch holds a story',
              style: TextStyle(fontSize: 14, color: Color(0xFF6E746F)),
            ),
            const SizedBox(height: 36),
            const SizedBox(
              width: 38,
              child: LinearProgressIndicator(
                minHeight: 3,
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: forest,
                backgroundColor: Color(0xFFDDE5DE),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class EntryGate extends ConsumerWidget {
  const EntryGate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return auth.when(
      loading: () => const Scaffold(
        backgroundColor: paper,
        body: Center(
          child: CircularProgressIndicator(color: forest, strokeWidth: 2.5),
        ),
      ),
      error: (error, _) => AuthErrorPage(message: error.toString()),
      data: (user) {
        if (user != null) return const ExperienceChooser();
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
                'One sign-in, two experiences from your assignment.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),
              _ExperienceCard(
                title: 'KinTree',
                detail: 'Family stories, heritage and conversations',
                icon: Icons.account_tree_rounded,
                color: const Color(0xFFE5EEE8),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KinTreeApp()),
                ),
              ),
              const SizedBox(height: 14),
              _ExperienceCard(
                title: 'Meditation & Music',
                detail: 'Guided practice, albums and playlists',
                icon: Icons.spa_rounded,
                color: const Color(0xFFF0E9FF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MeditationApp()),
                ),
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
