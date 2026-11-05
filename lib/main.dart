import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'features/meditation/meditation_design_system.dart';
import 'core/widgets/sanctuary_brand.dart';
import 'features/auth/presentation/auth_state.dart';

final bootstrapProvider = FutureProvider<SharedPreferences>((ref) async {
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  return SharedPreferences.getInstance();
});
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BootstrapApp()));
}

class BootstrapApp extends ConsumerWidget {
  const BootstrapApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(bootstrapProvider)
      .when(
        data: (preferences) => ProviderScope(
          overrides: [preferencesProvider.overrideWithValue(preferences)],
          child: const AssignmentApp(),
        ),
        loading: () => MaterialApp(
          theme: meditationTheme(),
          home: const SanctuarySplash(),
        ),
        error: (error, stack) => MaterialApp(
          home: Scaffold(
            backgroundColor: MeditationPalette.canvas,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 40,
                        color: MeditationPalette.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Could not start the application',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check the Firebase platform configuration and try again.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ref.invalidate(bootstrapProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
