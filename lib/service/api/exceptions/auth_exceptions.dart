class UnverifiedEmailException implements Exception {
  final String message;
  final String email;

  UnverifiedEmailException(this.message, this.email);

  @override
  String toString() => message;
}