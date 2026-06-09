import 'package:dio/dio.dart';
import 'package:synapse_frontend/core/auth/auth_repository_port.dart';
import 'package:synapse_frontend/core/auth/token_store.dart';
import 'package:synapse_frontend/services/platform/features/settings/data/account_api.dart';

/// settings 화면 테스트용 공용 AccountApi Fake.
/// SecuritySettingsScreen이 init 시 getProfile/listOAuthConnections를 호출하므로
/// 이 화면을 빌드하는 모든 테스트가 안전한 스텁을 제공해야 한다.
class FakeAccountApi extends AccountApi {
  FakeAccountApi({
    this.profile = const UserProfile(id: 'u', hasPassword: true),
    this.connections = const [],
    this.changePasswordError,
    this.deleteAccountError,
    this.unlinkError,
    this.updateProfileError,
  }) : super(Dio());

  final UserProfile profile;
  final List<OAuthConnection> connections;
  final AccountApiException? changePasswordError;
  final AccountApiException? deleteAccountError;
  final AccountApiException? unlinkError;
  final AccountApiException? updateProfileError;

  int changePasswordCount = 0;
  int deleteAccountCount = 0;
  final List<String> unlinkedProviders = [];
  String? updatedDisplayName;
  String? updatedLanguage;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    changePasswordCount++;
    final error = changePasswordError;
    if (error != null) throw error;
  }

  @override
  Future<void> deleteAccount() async {
    deleteAccountCount++;
    final error = deleteAccountError;
    if (error != null) throw error;
  }

  @override
  Future<UserProfile> getProfile() async => profile;

  @override
  Future<UserProfile> updateProfile({
    required String displayName,
    required String language,
  }) async {
    final error = updateProfileError;
    if (error != null) throw error;
    updatedDisplayName = displayName;
    updatedLanguage = language;
    return UserProfile(
      id: profile.id,
      hasPassword: profile.hasPassword,
      email: profile.email,
      displayName: displayName,
      avatarUrl: profile.avatarUrl,
      language: language,
    );
  }

  @override
  Future<List<OAuthConnection>> listOAuthConnections() async => connections;

  @override
  Future<void> unlinkOAuth(String provider) async {
    final error = unlinkError;
    if (error != null) throw error;
    unlinkedProviders.add(provider);
  }
}

class FakeAuthPort implements AuthRepositoryPort {
  bool logoutCalled = false;

  @override
  Future<AuthTokens?> restoreSession() async => null;

  @override
  Future<AuthTokens> completeOAuthLogin({required String accessToken}) async =>
      AuthTokens(accessToken: accessToken);

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async => const AuthTokens(accessToken: 'token');

  @override
  Future<void> signup({
    required String email,
    required String password,
  }) async {}

  @override
  void loginWithOAuth(String provider) {}

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}
