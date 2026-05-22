# worker_frontend_backend_summary

> 프론트엔드 작업자가 현재 `synapse-platform-svc` 백엔드 상태를 빠르게 확인하기 위한 문서입니다.
> 기준일: 2026-05-22

## 1. 현재 완료 범위

2주차까지 완료된 백엔드 범위는 다음과 같습니다.

| Step | 범위 | 상태 |
|---|---|---|
| Step 1 | Spring Boot 4 + Spring Modulith 기반 프로젝트 골격 | 완료 |
| Step 2 | Google / GitHub / Apple OAuth 로그인 및 자동 회원가입 | 완료 |
| Step 3 | JWT Access/Refresh Token, MFA TOTP 기반 | 완료 |
| Step 4 | Stripe Checkout, Subscription, Webhook, Payment History | 완료 |
| Step 5 | FCM 디바이스 토큰 등록/삭제 | 완료 |
| 추가 | Refresh Token 멀티 디바이스 세션 최대 5개 지원 | 완료 |

현재 백엔드는 인증, 결제, FCM 디바이스 등록까지 프론트엔드 연동 가능한 API 표면을 제공합니다.

## 2. 기본 실행 정보

| 항목 | 값 |
|---|---|
| 서비스명 | `synapse-platform-svc` |
| 기본 포트 | `8081` |
| API Prefix | `/api/v1` |
| 로컬 프론트 허용 Origin | `http://localhost:3000`, `http://localhost:5173` |
| 인증 방식 | `Authorization: Bearer {accessToken}` |

보호된 API는 Access Token을 Bearer 토큰으로 전달해야 합니다.

```http
Authorization: Bearer eyJ...
```

## 3. OAuth 로그인 플로우

프론트엔드는 백엔드의 OAuth 시작 URL로 브라우저를 이동시키면 됩니다.

| Provider | OAuth 시작 URL |
|---|---|
| Google | `GET /oauth2/authorization/google` |
| GitHub | `GET /oauth2/authorization/github` |
| Apple | `GET /oauth2/authorization/apple` |

OAuth 성공 시 백엔드는 `app.oauth2.redirect-uri`로 리다이렉트합니다.

로컬 기본값:

```text
http://localhost:3000/auth/callback
```

성공 시 쿼리 파라미터:

```text
?access_token={accessToken}&refresh_token={refreshToken}
```

프론트엔드는 `/auth/callback` 페이지에서 위 토큰을 읽고 저장한 뒤 앱 내부 인증 상태를 갱신해야 합니다.

OAuth 실패 시 현재 구현은 `/api/v1/auth/callback?error={message}` 형태로 리다이렉트합니다.

## 4. Token 정책

| 토큰 | TTL | 용도 |
|---|---:|---|
| Access Token | 15분 | API 인증 |
| Refresh Token | 7일 | Access Token 갱신 |

중요 정책:

- JWT 서명은 RS256입니다.
- Refresh Token 원문은 DB에 저장하지 않습니다.
- DB에는 Refresh Token의 SHA-256 hash만 저장됩니다.
- 사용자당 활성 Refresh Token 세션은 최대 5개입니다.
- 5개를 초과하면 가장 오래된 세션부터 만료됩니다.

## 5. Auth API

### 5.1 Refresh Token 갱신

```http
POST /api/v1/auth/refresh
Content-Type: application/json
```

Request:

```json
{
  "refreshToken": "refresh-token"
}
```

Response:

```json
{
  "accessToken": "new-access-token",
  "refreshToken": "new-refresh-token"
}
```

프론트엔드는 갱신 성공 시 기존 Access Token과 Refresh Token을 모두 새 값으로 교체해야 합니다.

### 5.2 OAuth Callback 보조 API

```http
GET /api/v1/auth/callback?userId={userId}
```

현재 OAuth 성공 핸들러는 토큰을 프론트 리다이렉트 URL 쿼리로 전달합니다. 이 API는 보조 엔드포인트에 가깝고, 프론트의 주 로그인 플로우에서는 `/auth/callback` 프론트 라우트에서 토큰 쿼리를 처리하는 방식이 우선입니다.

## 6. MFA API

MFA API는 인증이 필요합니다.

### 6.1 TOTP 설정

```http
POST /api/v1/auth/mfa/setup
Authorization: Bearer {accessToken}
```

Response:

```json
{
  "otpAuthUri": "otpauth://totp/...",
  "secret": "BASE32SECRET"
}
```

프론트엔드는 `otpAuthUri`로 QR 코드를 렌더링할 수 있습니다. `secret`은 수동 입력용으로 표시할 수 있습니다.

### 6.2 TOTP 검증

```http
POST /api/v1/auth/mfa/verify
Authorization: Bearer {accessToken}
Content-Type: application/json
```

Request:

```json
{
  "code": "123456"
}
```

Response:

```json
{
  "verified": true
}
```

검증 실패 시 에러 응답이 반환됩니다.

## 7. Billing API

Billing API는 Stripe Checkout 기반입니다.

### 7.1 Checkout Session 생성

```http
POST /api/v1/billing/checkout
Authorization: Bearer {accessToken}
Content-Type: application/json
```

Request:

```json
{
  "planCode": "PRO",
  "successUrl": "http://localhost:3000/billing/success",
  "cancelUrl": "http://localhost:3000/billing/cancel"
}
```

Response:

```json
{
  "checkoutUrl": "https://checkout.stripe.com/..."
}
```

프론트엔드는 응답의 `checkoutUrl`로 브라우저를 이동시키면 됩니다.

지원 Plan Code:

| 값 | 설명 |
|---|---|
| `FREE` | 무료 플랜. Checkout 생성 대상 아님 |
| `PRO` | 유료 플랜 |
| `TEAM` | 유료 플랜 |
| `ENTERPRISE` | 유료 플랜 |

현재 Checkout 생성은 `PRO`, `TEAM`, `ENTERPRISE`에 대해서만 유효합니다.

### 7.2 현재 구독 조회

```http
GET /api/v1/billing/subscription
Authorization: Bearer {accessToken}
```

Response:

```json
{
  "id": "subscription-uuid",
  "planCode": "PRO",
  "status": "ACTIVE",
  "currentPeriodEnd": "2026-06-22T00:00:00Z",
  "stripeSubscriptionId": "sub_..."
}
```

가능한 `status` 값:

| 값 |
|---|
| `ACTIVE` |
| `CANCELED` |
| `PAST_DUE` |
| `TRIALING` |

활성 구독이 없으면 404 에러가 반환됩니다.

### 7.3 Stripe Webhook

```http
POST /api/v1/billing/webhooks
```

이 엔드포인트는 Stripe 서버가 호출하는 용도입니다. 프론트엔드에서 직접 호출하지 않습니다.

처리 중인 Stripe 이벤트:

- `checkout.session.completed`
- `invoice.paid`
- `customer.subscription.deleted`

## 8. Notification API

현재 Notification 모듈은 실제 푸시 발송이 아니라 FCM 디바이스 토큰 등록/삭제까지만 제공합니다.

### 8.1 FCM 디바이스 토큰 등록

```http
POST /api/v1/notifications/devices
Authorization: Bearer {accessToken}
Content-Type: application/json
```

Request:

```json
{
  "token": "fcm-device-token",
  "platform": "web"
}
```

Response:

```http
201 Created
```

지원 platform:

| 값 |
|---|
| `ios` |
| `android` |
| `web` |

정책:

- 사용자당 최대 5개 디바이스 토큰 등록 가능
- 동일 토큰은 중복 생성하지 않고 기존 row를 갱신하는 방식

### 8.2 FCM 디바이스 토큰 삭제

```http
DELETE /api/v1/notifications/devices/{id}
Authorization: Bearer {accessToken}
```

Response:

```http
204 No Content
```

주의: 현재 등록 API는 생성된 디바이스 ID를 응답하지 않습니다. 따라서 프론트엔드에서 삭제 기능을 완전하게 제공하려면 디바이스 목록 조회 API 또는 등록 응답에 ID 포함이 추가로 필요합니다.

## 9. 공통 에러 응답

대부분의 API 에러는 다음 형태로 반환됩니다.

```json
{
  "type": "https://api.synapse.app/errors/PLAT-002",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Invalid or expired token",
  "code": "PLAT-002",
  "traceId": "trace-id"
}
```

프론트엔드는 `status` 또는 `code`를 기준으로 분기할 수 있습니다.

대표 케이스:

| HTTP Status | 의미 |
|---:|---|
| 400 | 요청 본문 또는 검증 오류 |
| 401 | 인증 필요, 토큰 없음, 토큰 만료 또는 잘못된 토큰 |
| 403 | 권한 없음 |
| 404 | 리소스 없음 |
| 500 | 서버 내부 오류 |

## 10. 현재 미구현 또는 프론트 연동 주의 사항

프론트엔드에서 아직 기대하면 안 되는 기능은 다음과 같습니다.

| 기능 | 현재 상태 |
|---|---|
| 일반 사용자 프로필 조회/수정 API | 미구현 |
| 로그아웃 API | 미구현 |
| 디바이스 토큰 목록 조회 API | 미구현 |
| FCM 실제 푸시 발송 | 미구현 |
| SES 이메일 발송 | 미구현 |
| Admin 사용자 관리 API | 미구현 |
| Admin 테넌트 관리 API | 미구현 |
| Audit Log 조회 API | 미구현 |

## 11. 프론트엔드 작업 전 결정 필요 사항

다음 항목은 프론트엔드 구현 전에 팀 차원의 결정이 필요합니다.

1. OAuth 콜백에서 받은 Access Token / Refresh Token 저장 위치
2. Refresh Token을 브라우저 저장소에 둘지, HttpOnly Cookie 방식으로 전환할지
3. Access Token 만료 시 자동 refresh 처리 방식
4. Refresh 실패 시 로그아웃 처리 및 로그인 페이지 이동 정책
5. MFA를 로그인 과정에서 강제할지, 설정 화면에서만 제공할지
6. Stripe 결제 성공/취소 페이지 라우트
7. FCM Web Push 토큰 발급 시점
8. 디바이스 토큰 삭제 UI를 제공할지 여부
9. 공통 에러 메시지 매핑 규칙

## 12. 프론트엔드 권장 라우트 초안

현재 백엔드 상태 기준으로 최소 필요 라우트는 다음과 같습니다.

| Route | 목적 |
|---|---|
| `/login` | OAuth Provider 선택 |
| `/auth/callback` | OAuth 성공 후 토큰 수신 및 저장 |
| `/settings/security` | MFA 설정 및 검증 |
| `/billing` | 현재 구독 조회, 플랜 선택 |
| `/billing/success` | Stripe Checkout 성공 후 복귀 |
| `/billing/cancel` | Stripe Checkout 취소 후 복귀 |

## 13. 프론트엔드 API 클라이언트 권장 동작

1. 모든 보호 API 요청에 `Authorization: Bearer {accessToken}` 헤더를 붙입니다.
2. API 응답이 401이면 `/api/v1/auth/refresh`를 한 번 호출합니다.
3. Refresh 성공 시 새 토큰으로 원래 요청을 재시도합니다.
4. Refresh 실패 시 저장된 토큰을 제거하고 로그인 화면으로 이동합니다.
5. Billing Checkout 생성 성공 시 `checkoutUrl`로 브라우저를 이동합니다.
6. FCM 토큰은 로그인 완료 후 사용자 권한 동의가 끝난 시점에 등록합니다.

## 14. 참고 소스 위치

| 범위 | 파일 |
|---|---|
| Security 설정 | `src/main/java/com/synapse/platform/auth/config/SecurityConfig.java` |
| CORS 설정 | `src/main/java/com/synapse/platform/auth/config/CorsConfig.java` |
| OAuth 성공 처리 | `src/main/java/com/synapse/platform/auth/service/OAuth2SuccessHandler.java` |
| JWT 처리 | `src/main/java/com/synapse/platform/auth/service/JwtTokenProvider.java` |
| Refresh Token 처리 | `src/main/java/com/synapse/platform/auth/service/RefreshTokenService.java` |
| MFA API | `src/main/java/com/synapse/platform/auth/controller/MfaController.java` |
| Billing API | `src/main/java/com/synapse/platform/billing/controller/BillingController.java` |
| Notification API | `src/main/java/com/synapse/platform/notification/controller/DeviceTokenController.java` |
| 공통 에러 응답 | `src/main/java/com/synapse/platform/global/exception/GlobalExceptionHandler.java` |

