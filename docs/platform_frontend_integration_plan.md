# Platform Frontend Integration Plan

> 작성일: 2026-05-22  
> 대상: `synapse-frontend` platform 담당 작업  
> 기준 문서:
> - `docs/director_frontend.md`
> - `docs/worker_frontend_backend_summary.md`
> - `docs/project-management/prd/PRD_W1.md`
> - `docs/project-management/prd/PRD_W2.md`
> - `docs/project-management/prd/PRD_W3.md`
> - `docs/project-management/prd/PRD_W4.md`
> - `docs/project-management/task/TASK_frontend.md`
> - `docs/project-management/history/HISTORY_frontend.md`

## 1. 목적

이 문서는 현재 `synapse-platform-svc` 백엔드 구현 상태를 기준으로, `synapse-frontend`의 platform 담당자가 지금 진행해야 할 프론트 작업과 보류해야 할 작업을 정리한다.

현재 프론트는 platform 관련 화면 UI 뼈대가 대부분 존재하지만, 실제 OAuth, 토큰 저장, refresh, MFA, billing, FCM device 등록 연동은 아직 남아 있다.

## 1.1 선행 차단 이슈

platform 연동을 시작하기 전에 아래 항목을 먼저 맞춰야 한다. 이 항목이 해결되지 않으면 OAuth와 보호 API 연동이 동시에 실패한다.

| 심각도 | 이슈 | 현재 상태 | 필요한 결정/조치 |
|---|---|---|---|
| Critical | W1~W2 platform 단독 테스트 base URL 분리 필요 | 프론트 기본 `dev` base URL은 `http://localhost:8080`이지만, 현재 작업 범위는 gateway 없이 `synapse-platform-svc`만 로컬 단독 실행해 OAuth/MFA/Billing/FCM device를 테스트하는 것이다. | W1~W2 platform 단독 테스트에서는 platform direct URL `http://localhost:8081`을 사용할 수 있는 실행 모드를 둔다. W3 이후 통합 테스트에서 gateway `http://localhost:8080` 라우팅을 확인한다. |
| Done | OAuth callback URI 백엔드 설정 | platform-svc 담당자가 `app.oauth2.redirect-uri` 기본값을 `http://127.0.0.1:8088/auth/callback`로 변경 완료했다. | 프론트는 `/auth/callback` route guard 예외와 query token 처리를 구현한다. |
| Done | platform-svc CORS allowlist | platform-svc의 `application.yml`, `application-local.yml`, `application-dev.yml`에 `http://127.0.0.1:8088` 반영 완료했다. | W1~W2 platform direct 테스트는 platform-svc CORS 기준으로 진행한다. gateway CORS는 W3 이후 통합 단계에서 팀리드 확인 대상으로 둔다. |
| Critical | `/auth/callback` route guard 예외 필요 | platform OAuth callback은 `http://127.0.0.1:8088/auth/callback`로 받는 방향이다. | `/auth/callback` 라우트는 미인증 상태에서도 접근 가능해야 한다. 인증 가드 예외로 처리하지 않으면 OAuth 성공 후 토큰 처리 전에 `/login`으로 redirect된다. |
| Critical | `/auth/callback` redirect 예외 누락 위험 | 현재 `app_router.dart`의 auth route 목록에는 `/auth/callback`이 없다. | `/auth/callback`을 라우트에 추가할 때 `authRoutes`에도 반드시 포함한다. 포함하지 않으면 토큰 처리 전에 `/login`으로 redirect된다. |
| Medium | `PLAT-401` 코드 불일치 | notification 문서 일부는 `PLAT-401`을 쓰지만 공통 에러 표에는 정의되어 있지 않다. | 프론트 분기는 HTTP `401` 또는 공통 코드 `PLAT-002`를 기준으로 처리한다. `PLAT-401` 전용 분기를 만들지 않는다. |
| Medium | refresh token 저장 방식 문서 상충 | `worker_frontend_backend_summary.md`는 결정 필요로 표시하지만 현재 OAuth 성공 플로우는 query로 `refresh_token`을 전달한다. | 현재 구현 연동은 query 수신 후 저장으로 진행하되, HttpOnly Cookie 전환 시 `TokenStore`만 교체 가능하게 격리한다. |
| Low | PKCE 주석과 실제 흐름 불일치 | 코드/일부 문서에는 PKCE가 남아 있지만 현재 백엔드 요약은 서버 주도 OAuth redirect 방식이다. | 프론트는 직접 `code_verifier`/`code_challenge`를 생성하지 않는다. OAuth 시작 URL로 브라우저 이동한다. |
| Low | `GET /api/v1/auth/callback?userId=...` 설명 혼선 | worker 문서에 보조 엔드포인트로만 언급된다. | 프론트 주 로그인 플로우에서는 호출하지 않는다. `/auth/callback` 프론트 라우트의 query token 처리를 우선한다. |
| Medium | MFA 로그인 강제 여부 미결 | 백엔드 요약 문서에는 MFA를 로그인 과정에서 강제할지, 설정 화면에서만 제공할지 결정 필요로 남아 있다. | 1차 프론트 작업은 settings 보안 화면에서 setup/verify를 제공하는 것으로 제한한다. 로그인 중 MFA challenge가 필요한 정책으로 결정되면 Auth flow와 router guard 작업을 별도 태스크로 재계획한다. |

## 2. 현재 백엔드 구현 상태 요약

`synapse-platform-svc`에서 현재 프론트가 연동 가능한 API 표면은 다음과 같다.

| 영역 | 현재 상태 | 프론트 연동 가능 여부 |
|---|---|---|
| OAuth | Google, GitHub, Apple OAuth 시작 URL 제공 | 가능 |
| JWT | access token, refresh token 발급 | 가능 |
| Token Refresh | `POST /api/v1/auth/refresh` 제공 | 가능 |
| MFA | TOTP setup, verify 제공 | 가능 |
| Billing | Stripe checkout, subscription 조회 제공 | 가능 |
| Notification Device | FCM device token 등록/삭제 제공 | 부분 가능 |
| User Profile | 일반 사용자 프로필 조회/수정 API 미구현 | 보류 |
| Logout API | 미구현 | 로컬 토큰 삭제로 처리 |
| Notification List | 알림 목록/읽음 처리/preference API 미구현 | 보류 |
| Admin | users, tenants, audit logs 등 미구현 | 보류 |

## 3. Project Management 문서와의 연결

### W1: Auth

관련 문서:

- `PRD_W1.md`
  - `FR-PL-001`: Google OAuth 회원가입
  - `FR-PL-002`: GitHub OAuth 로그인
  - `FR-PL-002a`: Apple OAuth 로그인/회원가입
  - `FR-PL-003`: JWT Access/Refresh Token 발급 및 갱신
  - `FR-PL-004`: TOTP MFA 등록
- `TASK_frontend.md`
  - Step 2: 로그인/회원가입 화면 및 OAuth 인증
- `HISTORY_frontend.md`
  - Step 2 상태: UI 뼈대 완료, OAuth 연동 잔여

현재 결론:

- W1 platform 백엔드는 OAuth/JWT/MFA가 준비된 상태다.
- 프론트는 Step 2의 비즈니스 로직을 마무리해야 한다.
- 가장 먼저 OAuth callback, token 저장/복원, refresh 흐름을 구현해야 한다.
- W1~W2 platform 단독 테스트는 gateway를 제외하고 `synapse-platform-svc` direct URL(`http://localhost:8081`)로 진행한다.
- W3 이후 다른 서비스와 통합 테스트를 시작할 때 gateway 포트(`http://localhost:8080`)와 platform 라우팅을 별도로 확인한다.

### W2: Billing + Notification 기초

관련 문서:

- `PRD_W2.md`
  - `FR-PL-101`: Stripe Checkout 결제
  - `FR-PL-102`: Stripe Webhook 결제 이벤트 처리
  - `FR-PL-103`: 플랜별 기능 제한 확인
  - `FR-PL-104`: FCM device token 등록

현재 결론:

- Checkout session 생성과 subscription 조회는 프론트에서 바로 연동 가능하다.
- Webhook은 백엔드/Stripe 서버 간 흐름이므로 프론트에서 직접 호출하지 않는다.
- `GET /billing/plans`는 현재 백엔드 요약 문서에 없다. 프론트는 당분간 로컬 플랜 정의 + `GET /api/v1/billing/subscription` 조합으로 처리한다.
- FCM device 등록/삭제 API는 가능하지만, 실제 Web FCM token 발급은 Firebase 설정 확인 후 진행해야 한다.

### W3: FCM 잔무

관련 문서:

- `PRD_W3.md`
  - `FR-PL-201`: W2 FCM device 등록 및 토큰 갱신 안정화

현재 결론:

- 프론트에서 할 수 있는 최소 작업은 device token 등록 API client를 준비하는 것이다.
- device list API가 없으므로 등록된 기기 목록 UI나 안정적인 삭제 UI는 아직 완전 구현하기 어렵다.

### W4: Notification, Audit, Admin

관련 문서:

- `PRD_W4.md`
  - `FR-PL-401`: FCM 푸시 발송
  - `FR-PL-402`: SES 이메일 알림
  - `FR-PL-403`: notification preference quiet hours
  - `FR-PL-404`: audit logs 적재
  - `FR-PL-405`: tenant/user 관리
- `TASK_frontend.md`
  - Step 8: 알림 센터
  - Step 9: 관리자 신고 처리 화면

현재 결론:

- 현재 백엔드 요약 기준으로 W4 영역은 대부분 아직 프론트 실연동 대상이 아니다.
- 알림 센터의 목록 조회, 읽음 처리, preference 저장 API가 아직 없다.
- admin users, tenants, audit logs API도 아직 없다.
- 따라서 W4 관련 프론트 화면은 mock 유지 또는 API 준비 전 상태로 두는 것이 맞다.

## 4. 지금 진행해야 할 작업 순서

### 1순위: Auth callback + token state

해야 할 일:

- `/auth/callback` 라우트 추가
- `/auth/callback`을 `app_router.dart`의 인증 예외 목록인 `authRoutes`에 추가
- OAuth callback은 `http://127.0.0.1:8088/auth/callback` 기준으로 수신
- OAuth callback query 처리
  - `access_token`
  - `refresh_token`
  - `error`
- token 저장소 구현
- 앱 시작 시 저장된 token으로 인증 상태 복원
- token 저장 완료 후 dashboard(`/`)로 이동
- callback에 `error`가 있거나 필수 token이 없거나 token 저장에 실패하면 `/login`으로 이동
- logout은 백엔드 API가 없으므로 로컬 token 삭제로 처리

관련 파일:

- `lib/core/constants/app_routes.dart`
- `lib/core/router/app_router.dart`
- `lib/core/auth/auth_state.dart`
- `lib/core/auth/auth_notifier.dart`
- `lib/services/platform/features/auth/presentation/screens/auth_screens.dart`

### 2순위: Dio 인증 헤더 + refresh retry

해야 할 일:

- W1~W2 platform 단독 테스트에서는 platform direct base URL `http://localhost:8081`을 사용
- 기존 `dev` gateway base URL(`http://localhost:8080`)은 W3 이후 통합 테스트용으로 유지
- Dart define으로 gateway/direct base URL을 명확히 분리
  - `APP_ENV=dev`: gateway 기준 `http://localhost:8080`
  - `APP_ENV=platform-dev`: platform-svc direct 기준 `http://localhost:8081`
- 보호 API 요청에 `Authorization: Bearer {accessToken}` 자동 주입
- 401 응답 시 `POST /api/v1/auth/refresh` 1회 호출
- refresh 성공 시 access token, refresh token 교체
- 원 요청 재시도
- refresh 실패 시 token 삭제 후 `/login` 이동
- 공통 에러 응답의 `code`, `detail`, `traceId` 파싱
- 인증 실패 처리는 HTTP `401`과 `PLAT-002`를 기준으로 한다. notification 문서에 등장하는 `PLAT-401`은 공통 코드 표에 없으므로 별도 기준으로 삼지 않는다.

관련 파일:

- `lib/core/network/dio_client.dart`
- 신규 후보: `lib/core/network/api_error.dart`
- 신규 후보: `lib/core/auth/token_store.dart`

### 3순위: MFA setup/verify

해야 할 일:

- `POST /api/v1/auth/mfa/setup`
- `POST /api/v1/auth/mfa/verify`
- `otpAuthUri`, `secret` 표시
- `PLAT-003`을 MFA 코드 불일치 메시지로 매핑
- 1차 범위는 설정 화면에서 사용자가 MFA를 등록/검증하는 흐름이다.
- 로그인 과정에서 MFA challenge를 강제할지는 아직 미결이다. 강제 정책이 확정되면 `/login -> /mfa -> dashboard` 인증 흐름을 별도 작업으로 분리한다.

관련 파일:

- `lib/services/platform/features/settings/presentation/screens/settings_screens.dart`
- 신규 후보: `lib/services/platform/features/auth/data/platform_auth_api.dart`

### 4순위: Billing subscription/checkout

해야 할 일:

- `GET /api/v1/billing/subscription`
- `POST /api/v1/billing/checkout`
- 응답의 `checkoutUrl`로 브라우저 이동
- `/billing/success`, `/billing/cancel` 라우트 추가
- Stripe 외부 페이지에서 `/billing/success` 또는 `/billing/cancel`로 돌아올 때 auth state 복원이 먼저 되어야 한다. token 저장/복원 작업이 완료되지 않으면 router guard가 결제 복귀 라우트를 `/login`으로 보낼 수 있다.
- `FREE` 플랜은 checkout 생성 호출 대상에서 제외

관련 파일:

- `lib/services/platform/features/billing/presentation/screens/billing_screens.dart`
- `lib/core/constants/app_routes.dart`
- `lib/core/router/app_router.dart`
- 신규 후보: `lib/services/platform/features/billing/data/billing_api.dart`

### 5순위: FCM device API client

해야 할 일:

- `POST /api/v1/notifications/devices`
- `DELETE /api/v1/notifications/devices/{id}`
- platform 값은 반드시 소문자 `ios`, `android`, `web` 사용
- 실제 FCM Web token 발급은 Firebase 설정 확인 이후 진행

관련 파일:

- `lib/services/platform/features/notifications/presentation/screens/notification_screens.dart`
- 신규 후보: `lib/services/platform/features/notifications/data/notification_device_api.dart`

## 5. 지금 보류해야 할 작업

다음 작업은 project-management 문서에는 존재하지만, 현재 백엔드 요약 기준으로는 아직 프론트 실연동을 진행하지 않는 것이 맞다.

| 작업 | 보류 사유 |
|---|---|
| 일반 사용자 프로필 조회/수정 | `GET /api/v1/users/me` 등 API 미구현 |
| 서버 logout API 호출 | logout API 미구현 |
| 알림 목록 조회 | `GET /notifications` API 미구현 |
| 알림 읽음 처리 | `PATCH /notifications/{id}/read` API 미구현 |
| 알림 preference 저장 | `GET/PUT /notifications/preferences` API 미구현 |
| 등록된 device 목록 UI | device list API 미구현 |
| admin users/tenants 관리 | API 미구현 |
| audit logs 조회 | API 미구현 |
| 실제 FCM push 수신 E2E | Firebase 설정 및 notification 발송 백엔드 흐름 필요 |

## 6. 구현 시 주의 사항

- OAuth 로그인은 REST 호출이 아니라 브라우저 redirect 방식이다.
- 현재 백엔드 요약 기준으로 프론트가 직접 PKCE `code_verifier`/`code_challenge`를 만들지 않는다.
- OAuth 성공 후 프론트 callback URL에서 token query를 읽어야 한다.
- `/auth/callback`은 미인증 상태에서도 접근 가능해야 한다. GoRouter redirect guard의 auth route 예외에 포함하지 않으면 token query를 처리하기 전에 `/login`으로 튕긴다.
- 현재 백엔드 문서상 refresh token도 query로 내려온다. 기존 `TASK_frontend.md`의 “refresh token은 httpOnly Cookie” 전제와 다르므로, 현재 백엔드 구현 문서를 우선 기준으로 삼는다.
- refresh token 저장 방식은 장기적으로 HttpOnly Cookie 전환 가능성이 있으므로, 화면/Notifier가 저장소 구현 세부사항에 직접 의존하지 않도록 `TokenStore` 같은 경계로 격리한다.
- refresh token rotation 때문에 refresh 성공 시 기존 refresh token도 반드시 새 값으로 교체해야 한다.
- 401 retry는 무한 루프를 막기 위해 원 요청당 1회만 수행한다.
- Billing checkout의 `checkoutUrl`은 프론트가 직접 이동시키고, webhook은 프론트에서 호출하지 않는다.
- Notification device 등록의 `platform`은 대문자가 아니라 소문자여야 한다.
- 프론트 주 로그인 플로우에서는 `GET /api/v1/auth/callback?userId=...`를 호출하지 않는다. OAuth 성공 후 이동한 `/auth/callback` 프론트 라우트에서 token query를 처리한다.
- OAuth 302 redirect 자체는 CORS 대상이 아니다. CORS는 redirect 이후 프론트 JavaScript가 API를 fetch/XHR로 호출할 때 적용된다.
- platform OAuth callback은 `http://127.0.0.1:8088/auth/callback`로 받는다. README의 기본 Flutter 실행 포트는 변경하지 않는다.
- `http://127.0.0.1:8088`은 `http://localhost:8088`과도 다른 origin이다. CORS allowlist와 OAuth redirect URI에는 실제 Flutter 실행 origin을 정확히 등록해야 한다.
- platform-svc에는 `http://127.0.0.1:8088/auth/callback` redirect와 `http://127.0.0.1:8088` CORS 허용이 반영 완료됐다.
- 프론트팀 전달 사항: `/auth/callback` 라우트를 인증 가드 예외로 처리하고, 이 라우트에서 `access_token`, `refresh_token` query parameter를 추출해 저장한 뒤 dashboard로 이동한다. callback에 `error`가 있거나 필수 token이 없거나 token 저장에 실패하면 `/login`으로 이동한다.
- W1~W2 platform 작업은 gateway 없이 `synapse-platform-svc:8081` direct 호출로 테스트한다. gateway CORS와 gateway 라우팅(`/oauth2/**`, `/api/v1/auth/**`, `/api/v1/billing/**`, `/api/v1/notifications/**`)은 W3 이후 통합 테스트에서 팀리드 확인 대상으로 둔다.
- W1~W2 platform direct 테스트 실행 예시는 `flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8088 --dart-define=APP_ENV=platform-dev`이다.
- 현재 프론트의 `flutter analyze --no-pub`는 lint/info 71건으로 실패 상태다. `CLAUDE.md` 기준으로 analyze 경고 0개를 유지해야 하므로, platform 연동 작업은 관련 lint를 함께 정리해 `flutter analyze --no-pub` 통과를 목표로 한다.

## 7. 최종 우선순위 요약

1. W1 Step 2 인증 연동 완료
2. token 저장/복원 및 refresh interceptor 구현
3. MFA setup/verify 연동
4. Billing subscription/checkout 연동
5. FCM device 등록/삭제 API client 준비
6. 알림 센터와 admin 화면은 백엔드 API가 준비될 때까지 mock 유지
