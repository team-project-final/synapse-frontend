import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';

final authRepositoryPortProvider = Provider<AuthRepositoryPort>((ref) {
  throw UnimplementedError('AuthRepositoryPort provider must be overridden.');
});

abstract interface class AuthRepositoryPort {
  Future<AuthTokens?> restoreSession();

  Future<AuthTokens> completeOAuthLogin({required String accessToken});

  Future<AuthTokens> login({required String email, required String password});

  Future<void> signup({required String email, required String password});

  void loginWithOAuth(String provider);

  Future<void> logout();
}
