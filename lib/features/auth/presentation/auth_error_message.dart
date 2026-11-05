import '../domain/auth_failure.dart';

/// Only intentional, user-facing failures belong in the account UI.
String authErrorMessage(Object? error) => error is AuthFailure
    ? error.message
    : 'We could not connect to your account. Please try again.';
