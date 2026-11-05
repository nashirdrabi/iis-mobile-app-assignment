/// User-facing failures cross the repository boundary without Firebase types.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}
