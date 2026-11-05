import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/palette.dart';
import 'auth_state.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: paper,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final artHeight = (constraints.maxHeight * .30).clamp(170.0, 250.0);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _continue(context, ref),
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: artHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEE7),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          right: 18,
                          top: 18,
                          child: Icon(
                            Icons.auto_awesome,
                            color: forest.withValues(alpha: .55),
                          ),
                        ),
                        const CircleAvatar(
                          radius: 66,
                          backgroundImage: AssetImage(
                            'assets/images/murphy_profile.png',
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_tree_outlined,
                                  size: 17,
                                  color: forest,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'Sharma family · 4 generations',
                                  style: TextStyle(fontSize: 11, color: forest),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Keep what matters close',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 11),
                  const Text(
                    'Bring family stories, mindful moments and the people you love into one thoughtful mobile experience.',
                    style: TextStyle(
                      height: 1.5,
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _continue(context, ref),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text('Get started'),
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        await completeOnboarding(ref);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        }
                      },
                      child: const Text('I already have an account'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    await completeOnboarding(ref);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _obscure = true;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    ref.listen(authProvider, (_, next) {
      if (next.hasValue && next.value != null && context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
    return _AuthLayout(
      title: 'Welcome back',
      subtitle: 'Sign in to continue to your experiences.',
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Enter a valid email.' : null,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter your password.' : null,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            _AuthError(auth),
            const SizedBox(height: 18),
            _SubmitButton(
              label: 'Sign in',
              busy: auth.isLoading,
              onPressed: () {
                if (_form.currentState!.validate()) {
                  ref
                      .read(authProvider.notifier)
                      .signIn(_email.text, _password.text);
                }
              },
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              ),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    ref.listen(authProvider, (_, next) {
      if (next.hasValue && next.value != null && context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
    return _AuthLayout(
      title: 'Create your account',
      subtitle: 'Your profile will be shared across both experiences.',
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _name,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your name.' : null,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Enter a valid email.' : null,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              validator: (v) => v == null || v.length < 6
                  ? 'Use at least six characters.'
                  : null,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            _AuthError(auth),
            const SizedBox(height: 18),
            _SubmitButton(
              label: 'Create account',
              busy: auth.isLoading,
              onPressed: () {
                if (_form.currentState!.validate()) {
                  ref
                      .read(authProvider.notifier)
                      .createAccount(_name.text, _email.text, _password.text);
                }
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthLayout extends StatelessWidget {
  const _AuthLayout({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title, subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: paper,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: forest,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.account_tree_rounded,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 11),
                    const Text(
                      'KinTree',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        color: forest,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.lock_outline, size: 17, color: forest),
                    const SizedBox(width: 5),
                    const Text(
                      'Private by design',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6E746F),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFECE9E2)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C332B1F),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: child,
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'KinTree Heritage · Encrypted & Private',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Color(0xFF858A85)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _AuthError extends StatelessWidget {
  const _AuthError(this.value);
  final AsyncValue<dynamic> value;
  @override
  Widget build(BuildContext context) => value.hasError
      ? Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            value.error.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(color: Colors.red),
          ),
        )
      : const SizedBox.shrink();
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.busy,
    required this.onPressed,
  });
  final String label;
  final bool busy;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: busy ? null : onPressed,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    ),
  );
}

class AuthErrorPage extends StatelessWidget {
  const AuthErrorPage({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Could not load your account',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}
