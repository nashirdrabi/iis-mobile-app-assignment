import '../../../core/theme/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/state/selection_state.dart';
import '../../../core/widgets/sanctuary_brand.dart';
import '../../meditation/meditation_design_system.dart';
import 'auth_state.dart';
import 'auth_error_message.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = ref.watch(authActionProvider);
    return Scaffold(
      backgroundColor: MeditationPalette.canvas,
      body: SanctuaryBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.contentMaxWidth,
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: action.isLoading
                          ? null
                          : () => completeOnboarding(ref),
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Image.asset(
                      'assets/images/sanctuary_lotus.png',
                      width: 170,
                      height: 170,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mindful moments.\nMeaningful connections.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 29,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.8,
                      color: MeditationPalette.ink,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Create space for your daily practice and keep the stories of your family close.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: MeditationPalette.muted,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _IntroductionFeature(
                    Icons.spa_outlined,
                    'Meditation & Music',
                    'Sacred sounds, guided practice and your personal library.',
                  ),
                  const SizedBox(height: 12),
                  const _IntroductionFeature(
                    Icons.account_tree_outlined,
                    'KinTree',
                    'Family heritage, memories and conversations.',
                  ),
                  _AuthError(action),
                  const SizedBox(height: 24),
                  _SubmitButton(
                    label: 'Get started',
                    busy: action.isLoading,
                    onPressed: () => completeOnboarding(ref),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: action.isLoading
                        ? null
                        : () => completeOnboarding(ref),
                    child: const Text('I already have an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroductionFeature extends StatelessWidget {
  const _IntroductionFeature(this.icon, this.title, this.detail);
  final IconData icon;
  final String title, detail;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xCCFFFFFF),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF0E9FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 22, color: MeditationPalette.accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: MeditationPalette.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(), _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  static const _visibility = ('auth.password.hidden', 'true');
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(authActionProvider);
    final hidden = ref.watch(selectionProvider(_visibility)) == 'true';
    ref.listen(authProvider, (_, next) {
      if (next.hasValue && next.value != null && context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
    return _AuthLayout(
      title: 'Welcome back',
      subtitle:
          'Sign in to your sanctuary. Your daily practice and family stories are waiting.',
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              validator: _validateEmail,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: hidden,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter your password.' : null,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: hidden ? 'Show password' : 'Hide password',
                  onPressed: () => ref
                      .read(selectionProvider(_visibility).notifier)
                      .select((!hidden).toString()),
                  icon: Icon(
                    hidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            _AuthError(action),
            const SizedBox(height: 24),
            _SubmitButton(
              label: 'Sign in',
              busy: action.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: action.isLoading
                  ? null
                  : () {
                      ref.read(authActionProvider.notifier).clear();
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      ref.read(authProvider.notifier).signIn(_email.text, _password.text);
    }
  }
}

String? _validateEmail(String? value) {
  final text = value?.trim() ?? '';
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)
      ? null
      : 'Enter a valid email.';
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
    final action = ref.watch(authActionProvider);
    ref.listen(authProvider, (_, next) {
      if (next.hasValue && next.value != null && context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
    return _AuthLayout(
      title: 'Begin your journey',
      subtitle:
          'One account for mindful living and meaningful family connections.',
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your name.' : null,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: _validateEmail,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) => v == null || v.length < 6
                  ? 'Use at least six characters.'
                  : null,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Password',
                helperText: 'At least 6 characters',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            _AuthError(action),
            const SizedBox(height: 24),
            _SubmitButton(
              label: 'Create account',
              busy: action.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: action.isLoading
                  ? null
                  : () {
                      ref.read(authActionProvider.notifier).clear();
                      Navigator.pop(context);
                    },
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      ref
          .read(authProvider.notifier)
          .createAccount(_name.text, _email.text, _password.text);
    }
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
    backgroundColor: MeditationPalette.canvas,
    body: SanctuaryBackdrop(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.authMaxWidth,
              ),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SanctuaryBrand(),
                    const SizedBox(height: 36),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 27,
                        height: 1.25,
                        letterSpacing: -.7,
                        fontWeight: FontWeight.w600,
                        color: MeditationPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: MeditationPalette.muted,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xE6FFFFFF),
                        borderRadius: BorderRadius.circular(AppRadii.large),
                        border: Border.all(color: Colors.white),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x126C5CE7),
                            blurRadius: 32,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    const SizedBox(height: 24),
                    const Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 13,
                          color: MeditationPalette.muted,
                        ),
                        Text(
                          'Your space. Your stories. Your practice.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: MeditationPalette.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
      ? Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            authErrorMessage(value.error),
            style: const TextStyle(
              color: Color(0xFFB42345),
              fontSize: 12,
              height: 1.5,
            ),
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
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [MeditationPalette.primary, MeditationPalette.accent],
      ),
      borderRadius: BorderRadius.circular(AppRadii.card),
      boxShadow: const [
        BoxShadow(
          color: Color(0x284F46E5),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
    ),
  );
}

class AuthErrorPage extends ConsumerWidget {
  const AuthErrorPage({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context, WidgetRef ref) => _AuthLayout(
    title: 'Let’s reconnect',
    subtitle: 'We could not load your account.',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          size: 40,
          color: MeditationPalette.accent,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),
        _SubmitButton(
          label: 'Retry',
          busy: false,
          onPressed: () => ref.invalidate(authProvider),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => ref.read(authProvider.notifier).signOut(),
          child: const Text('Sign out'),
        ),
      ],
    ),
  );
}
