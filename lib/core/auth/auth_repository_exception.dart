class AuthRepositoryException implements Exception {
  const AuthRepositoryException({
    required this.status,
    required this.detail,
    this.code,
  });

  final int status;
  final String? code;
  final String detail;

  @override
  String toString() {
    final codeText = code == null ? '' : ' $code';
    return 'AuthRepositoryException($status$codeText): $detail';
  }
}
