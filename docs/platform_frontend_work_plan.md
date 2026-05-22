# Platform Frontend Work Plan

> 작성일: 2026-05-22  
> 브랜치: `feat/platform-integration`  
> 범위: W1~W2 platform 단독 연동  
> 기준 문서: `docs/platform_frontend_integration_plan.md`

## 1. 작업 범위

이번 작업은 gateway 없이 `synapse-platform-svc`만 로컬에서 단독 실행해 platform 프론트 연동을 검증하는 범위로 제한한다.

포함:

- OAuth callback 처리
- token 저장/복원
- platform direct base URL 실행 모드
- Dio 인증 헤더 및 refresh retry
- MFA setup/verify
- Billing subscription/checkout
- FCM device API client

제외:

- gateway routing 검증
- gateway CORS 검증
- notification 목록/읽음/preference 연동
- admin users/tenants/audit logs 연동
- 로그인 과정에서 MFA challenge 강제
- 실제 Firebase Web Push token 발급

## 2. 로컬 실행 기준

W1~W2 platform 단독 테스트는 다음 기준을 사용한다.

| 항목 | 값 |
|---|---|
| Flutter Web | `http://127.0.0.1:8088` |
| OAuth callback | `http://127.0.0.1:8088/auth/callback` |
| platform-svc direct | `http://localhost:8081` |
| gateway | `http://localhost:8080` |
| W1~W2 실행 env | `APP_ENV=platform-dev` |
| W3+ 통합 env | `APP_ENV=dev` |

실행 예시:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8088 --dart-define=APP_ENV=platform-dev
```

## 3. 작업 순서

### Task 1: platform-dev 환경 추가

목표:

- `APP_ENV=platform-dev`를 추가한다.
- `platform-dev`는 `http://localhost:8081`을 base URL로 사용한다.
- 기존 `dev`는 gateway `http://localhost:8080`으로 유지한다.

대상 파일:

- `lib/core/network/app_environment.dart`
- `lib/core/network/dio_client.dart`
- 테스트 파일 신규 또는 기존 network/auth 테스트 확장

검증:

- `APP_ENV=platform-dev`가 `AppEnvironment.platformDev` 또는 동등한 값으로 매핑된다.
- base URL이 `http://localhost:8081`인지 테스트한다.

### Task 2: token 저장소 추가

목표:

- access token, refresh token 저장/조회/삭제 경계를 만든다.
- AuthNotifier와 Dio interceptor가 저장 구현 세부사항에 직접 의존하지 않도록 한다.
- 향후 HttpOnly Cookie 전환 가능성을 고려해 저장소 경계를 분리한다.

대상 파일:

- 신규: `lib/core/auth/token_store.dart`
- `lib/core/auth/auth_notifier.dart`
- 테스트 파일 신규: `test/core/auth/token_store_test.dart`

검증:

- token 저장 후 조회 가능
- token 삭제 후 조회 결과 없음
- 저장 실패 시 인증 상태가 authenticated로 바뀌지 않음

주의:

- 현재 의존성에는 `hive_flutter`가 있다.
- 보안 기준상 `flutter_secure_storage` 사용이 더 적합하지만, 의존성 추가 여부는 구현 시 결정한다.

### Task 3: AuthState/AuthNotifier 확장

목표:

- OAuth callback에서 받은 token으로 인증 상태를 갱신한다.
- 앱 시작 시 저장된 token을 복원한다.
- logout은 백엔드 API 없이 로컬 token 삭제로 처리한다.

대상 파일:

- `lib/core/auth/auth_state.dart`
- `lib/core/auth/auth_notifier.dart`
- `test/core/auth/auth_notifier_test.dart`

검증:

- `completeOAuthLogin(accessToken, refreshToken)` 호출 시 authenticated 상태가 된다.
- 저장된 token이 있으면 앱 시작 시 authenticated 상태로 복원된다.
- token이 없으면 unauthenticated 상태로 유지된다.
- logout 시 token 삭제 후 unauthenticated 상태가 된다.

### Task 4: OAuth callback 라우트 추가

목표:

- `/auth/callback` 라우트를 추가한다.
- `/auth/callback`은 인증 가드 예외 목록에 포함한다.
- callback query parameter를 처리한다.

성공 흐름:

1. `access_token`, `refresh_token` query parameter를 읽는다.
2. token 저장 및 AuthState 갱신을 수행한다.
3. dashboard(`/`)로 이동한다.

실패 흐름:

1. `error` query parameter가 있으면 실패로 처리한다.
2. 필수 token이 없으면 실패로 처리한다.
3. token 저장 실패 시 실패로 처리한다.
4. 실패 시 `/login`으로 이동한다.

대상 파일:

- `lib/core/constants/app_routes.dart`
- `lib/core/router/app_router.dart`
- 신규 후보: `lib/services/platform/features/auth/presentation/screens/oauth_callback_screen.dart`
- `test/widget_test.dart` 또는 신규 route 테스트

검증:

- unauthenticated 상태에서도 `/auth/callback?access_token=a&refresh_token=r`가 `/login`으로 튕기지 않는다.
- token 처리 성공 후 dashboard로 이동한다.
- `error` 또는 token 누락 시 `/login`으로 이동한다.

### Task 5: OAuth provider redirect 연결

목표:

- LoginScreen의 OAuth 버튼을 platform-svc OAuth 시작 URL에 연결한다.
- platform direct 모드에서는 `http://localhost:8081/oauth2/authorization/{provider}`로 이동한다.

대상 provider:

- Google: `/oauth2/authorization/google`
- GitHub: `/oauth2/authorization/github`
- Apple: `/oauth2/authorization/apple`

대상 파일:

- `lib/services/platform/features/auth/presentation/screens/auth_screens.dart`
- 필요 시 신규 helper: `lib/services/platform/features/auth/data/oauth_redirect.dart`

검증:

- 각 provider 버튼이 올바른 URL을 생성한다.
- 프론트가 직접 PKCE `code_verifier`/`code_challenge`를 만들지 않는다.

### Task 6: Dio 인증 헤더 및 refresh retry

목표:

- 보호 API 요청에 `Authorization: Bearer {accessToken}`을 자동 주입한다.
- 401 응답 시 `/api/v1/auth/refresh`를 1회 호출한다.
- refresh 성공 시 새 access/refresh token을 저장하고 원 요청을 재시도한다.
- refresh 실패 시 token 삭제 후 로그인 상태로 되돌린다.

대상 파일:

- `lib/core/network/dio_client.dart`
- 신규 후보: `lib/core/network/api_error.dart`
- `lib/core/auth/token_store.dart`

검증:

- token이 있으면 Authorization header가 붙는다.
- 401 발생 시 refresh를 1회만 시도한다.
- refresh 성공 시 원 요청이 재시도된다.
- refresh 실패 시 token이 삭제된다.
- `PLAT-401` 전용 분기는 만들지 않고 HTTP `401` 또는 `PLAT-002` 기준으로 처리한다.

### Task 7: MFA settings 연동

목표:

- 1차 범위는 설정 화면에서 MFA를 등록/검증하는 흐름이다.
- 로그인 과정에서 MFA challenge를 강제하지 않는다.

API:

- `POST /api/v1/auth/mfa/setup`
- `POST /api/v1/auth/mfa/verify`

대상 파일:

- `lib/services/platform/features/settings/presentation/screens/settings_screens.dart`
- 신규 후보: `lib/services/platform/features/auth/data/platform_auth_api.dart`

검증:

- setup 응답의 `otpAuthUri`, `secret`을 표시한다.
- verify 요청에 6자리 code를 보낸다.
- `PLAT-003`은 MFA 코드 불일치 메시지로 매핑한다.

### Task 8: Billing subscription/checkout 연동

목표:

- 현재 구독 상태를 조회한다.
- 유료 플랜 선택 시 Stripe checkout session을 생성한다.
- 응답의 `checkoutUrl`로 이동한다.
- Stripe 복귀 라우트를 추가한다.

API:

- `GET /api/v1/billing/subscription`
- `POST /api/v1/billing/checkout`

라우트:

- `/billing/success`
- `/billing/cancel`

주의:

- `FREE` 플랜은 checkout 생성 대상이 아니다.
- Stripe 외부 페이지에서 복귀할 때 auth state 복원이 먼저 되어야 한다.
- token 저장/복원 작업이 불완전하면 복귀 라우트가 `/login`으로 튕길 수 있다.

대상 파일:

- `lib/services/platform/features/billing/presentation/screens/billing_screens.dart`
- `lib/core/constants/app_routes.dart`
- `lib/core/router/app_router.dart`
- 신규 후보: `lib/services/platform/features/billing/data/billing_api.dart`

검증:

- subscription 조회 성공/404 상태를 구분한다.
- PRO/TEAM/ENTERPRISE는 checkout 요청을 보낸다.
- FREE는 checkout 요청을 보내지 않는다.
- success/cancel 라우트가 등록되어 있다.

### Task 9: FCM device API client 준비

목표:

- 실제 Firebase Web Push token 발급은 제외한다.
- platform-svc device token 등록/삭제 API client만 준비한다.

API:

- `POST /api/v1/notifications/devices`
- `DELETE /api/v1/notifications/devices/{id}`

대상 파일:

- 신규 후보: `lib/services/platform/features/notifications/data/notification_device_api.dart`

검증:

- 등록 요청 body는 `token`, `platform`을 포함한다.
- Web platform 값은 소문자 `web`을 사용한다.
- 삭제 요청은 device id path parameter를 사용한다.

### Task 10: 검증 및 정리

목표:

- platform 연동 변경 후 테스트와 정적 분석을 통과시킨다.
- `CLAUDE.md` 기준으로 analyze 경고 0개를 목표로 한다.

명령:

```bash
flutter test --no-pub
flutter analyze --no-pub
```

수동 smoke test:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8088 --dart-define=APP_ENV=platform-dev
```

확인:

- OAuth provider 버튼 클릭 시 platform-svc OAuth 시작 URL로 이동
- OAuth 성공 callback에서 token 저장
- 성공 후 dashboard 이동
- 실패 callback은 login 이동
- refresh token rotation 후 새 token 저장
- Billing checkout URL 이동

## 4. 권장 커밋 단위

1. `feat(platform): add platform-dev environment`
2. `feat(auth): add token store and auth restoration`
3. `feat(auth): handle oauth callback route`
4. `feat(auth): add oauth provider redirects`
5. `feat(network): add auth interceptor and refresh retry`
6. `feat(platform): integrate mfa settings`
7. `feat(platform): integrate billing checkout`
8. `feat(platform): add notification device api client`

## 5. 구현 우선순위 요약

1. `APP_ENV=platform-dev`
2. token store
3. AuthNotifier token 복원
4. `/auth/callback` route guard 예외
5. OAuth provider redirect
6. Dio refresh retry
7. MFA settings
8. Billing checkout
9. FCM device API client
10. test/analyze 정리

