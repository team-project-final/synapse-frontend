import 'package:synapse_frontend/core/auth/auth_repository_exception.dart';

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class SignupRequest {
  const SignupRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class SignupResult {
  const SignupResult({required this.userId});

  factory SignupResult.fromJson(Map<String, dynamic> json) {
    final userId = json['userId'];
    if (userId is! String || userId.isEmpty) {
      throw const AuthRepositoryException(
        status: 500,
        detail: 'Invalid signup response.',
      );
    }

    return SignupResult(userId: userId);
  }

  final String userId;
}
