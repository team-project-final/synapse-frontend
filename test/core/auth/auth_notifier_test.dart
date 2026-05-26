import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/core/auth/auth_notifier.dart';
import 'package:synapse_frontend/core/auth/auth_repository_exception.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/core/auth/auth_state.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';

void main() {
  late ProviderContainer container;
  late _FakeAuthRepository repository;

  setUp(() {
    repository = _FakeAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryPortProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is initializing', () {
    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.initializing);
    expect(state.accessToken, isNull);
  });

  test('restoreSession without tokens resolves to unauthenticated', () async {
    await container.read(authNotifierProvider.notifier).restoreSession();

    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.unauthenticated);
    expect(state.accessToken, isNull);
  });

  test('completeOAuthLogin stores access token and authenticates', () async {
    await container
        .read(authNotifierProvider.notifier)
        .completeOAuthLogin(accessToken: 'access');

    final state = container.read(authNotifierProvider);

    expect(state.status, AuthStatus.authenticated);
    expect(state.accessToken, 'access');
    expect(repository.tokens?.accessToken, 'access');
  });

  test('restoreSession authenticates when stored tokens exist', () async {
    repository.tokens = const AuthTokens(accessToken: 'stored-access');

    await container.read(authNotifierProvider.notifier).restoreSession();

    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.accessToken, 'stored-access');
  });

  test('restoreSession reads tokens through repository port', () async {
    final recordingRepository = _FakeAuthRepository(
      tokens: const AuthTokens(accessToken: 'stored-access'),
    );
    final recordingContainer = ProviderContainer(
      overrides: [
        authRepositoryPortProvider.overrideWithValue(recordingRepository),
      ],
    );
    addTearDown(recordingContainer.dispose);

    await recordingContainer
        .read(authNotifierProvider.notifier)
        .restoreSession();

    expect(recordingRepository.calls, ['restore']);
    final state = recordingContainer.read(authNotifierProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.accessToken, 'stored-access');
  });

  test('logout clears tokens and resets state to unauthenticated', () async {
    await container
        .read(authNotifierProvider.notifier)
        .completeOAuthLogin(accessToken: 'access');

    await container.read(authNotifierProvider.notifier).logout();

    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.unauthenticated);
    expect(repository.tokens, isNull);
  });

  test('loginWithOAuth starts OAuth through repository port', () async {
    container.read(authNotifierProvider.notifier).loginWithOAuth('google');

    expect(repository.oauthProviders, ['google']);
  });

  test('login authenticates and stores access token in state', () async {
    repository.loginResult = const AuthTokens(accessToken: 'login-access');

    await container
        .read(authNotifierProvider.notifier)
        .login('user@example.com', 'P@ssw0rd!');

    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.accessToken, 'login-access');
    expect(state.errorMessage, isNull);
  });

  test('login failure exposes repository detail', () async {
    repository.loginError = const AuthRepositoryException(
      status: 401,
      code: 'PLAT-009-002',
      detail: 'Invalid credentials',
    );

    await container
        .read(authNotifierProvider.notifier)
        .login('user@example.com', 'bad-password');

    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.unauthenticated);
    expect(state.errorMessage, 'Invalid credentials');
  });

  test(
    'signup success keeps unauthenticated state and sets success message',
    () async {
      await container
          .read(authNotifierProvider.notifier)
          .signup('user@example.com', 'P@ssw0rd!');

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.successMessage, 'Signup completed. Please log in.');
      expect(repository.signupCallCount, 1);
    },
  );

  test('signup failure exposes repository detail', () async {
    repository.signupError = const AuthRepositoryException(
      status: 409,
      code: 'PLAT-009-001',
      detail: 'Email already registered',
    );

    await container
        .read(authNotifierProvider.notifier)
        .signup('user@example.com', 'P@ssw0rd!');

    final state = container.read(authNotifierProvider);
    expect(state.status, AuthStatus.unauthenticated);
    expect(state.errorMessage, 'Email already registered');
  });
}

class _FakeAuthRepository implements AuthRepositoryPort {
  _FakeAuthRepository({this.tokens});

  AuthTokens? tokens;
  AuthTokens? loginResult;
  Object? loginError;
  Object? signupError;
  int signupCallCount = 0;
  final calls = <String>[];
  final oauthProviders = <String>[];

  @override
  Future<AuthTokens?> restoreSession() async {
    calls.add('restore');
    return tokens;
  }

  @override
  Future<AuthTokens> completeOAuthLogin({required String accessToken}) async {
    calls.add('completeOAuthLogin');
    tokens = AuthTokens(accessToken: accessToken);
    return tokens!;
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    calls.add('login');
    final error = loginError;
    if (error != null) throw error;
    return loginResult ?? const AuthTokens(accessToken: 'login-access');
  }

  @override
  Future<void> signup({required String email, required String password}) async {
    calls.add('signup');
    signupCallCount += 1;
    final error = signupError;
    if (error != null) throw error;
  }

  @override
  void loginWithOAuth(String provider) {
    calls.add('loginWithOAuth');
    oauthProviders.add(provider);
  }

  @override
  Future<void> logout() async {
    calls.add('logout');
    tokens = null;
  }
}
