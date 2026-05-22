# Platform Frontend Project Management Check

## 목적

오늘 진행한 platform frontend 작업을 `docs/project-management`의 PRD 및 Workflow 문서와 대조해 체크 가능한 항목과 아직 체크하지 않은 항목을 정리한다.

## 확인 기준

- 프론트 코드와 테스트로 확인된 항목만 체크했다.
- 백엔드 동작, webhook, gateway, 실제 OAuth provider 등록, 실제 FCM token 발급이 필요한 항목은 체크하지 않았다.
- 문서의 요구사항과 현재 백엔드 연동 방식이 충돌하는 항목은 체크하지 않고 별도 이슈로 남겼다.
- README는 수정하지 않았다.

## 오늘 반영한 project-management 체크

### `docs/project-management/workflow/WORKFLOW_frontend_W1.md`

#### Step 2: 로그인/회원가입 화면 및 OAuth 인증

체크한 항목:

- Step Goal / Done When / Scope / Input 확인
- PRD_W1 인증 화면 요구사항 확인
- 로그인 화면 UI 요소 정의
- 인증 화면 공개 여부 및 권한 검토
- 프론트엔드 ERD 해당 없음
- 인증 상태 모델 설계
- platform-svc base URL 환경 관리
- AuthState Provider 설계
- AuthNotifier 구현
- OAuth callback 처리 및 token 수신 로직
- GoRouter redirect guard 구현
- AuthNotifier 상태 전이 unit test
- 테스트 통과 확인
- 로그인 페이지 UI 구현
- 로그인 화면 렌더링 및 OAuth 버튼 동작 확인

Status 문구도 다음 방향으로 갱신했다.

```md
**Step 2 Status**: [x] In Progress (OAuth 프론트 연동 완료, 이메일/비밀번호 API 연동 및 토큰 저장 정책 정리 잔여)
```

#### Step 3: 대시보드 및 사이드바 네비게이션

체크한 항목:

- 인증 필요 여부
- 로그인 사용자 권한
- 공개 API 아님
- GoRouter guard로 미인증 redirect 확인

### `docs/project-management/prd/PRD_W1.md`

체크한 항목:

```md
- [x] Flutter: 로그인/대시보드 화면 렌더링
```

이 항목은 현재 `flutter test --no-pub`에서 로그인 화면, 저장 token 복원, dashboard 접근 흐름이 검증되므로 체크했다.

## PRD 기준 현재 구현 매핑

| 문서 | 항목 | 현재 상태 |
| --- | --- | --- |
| `PRD_W1.md` | `FR-PL-001` Google OAuth 회원가입 | 프론트 OAuth 시작 URL 연결 완료. 실제 회원 생성은 백엔드/E2E 확인 필요 |
| `PRD_W1.md` | `FR-PL-002` GitHub OAuth 로그인 | 프론트 OAuth 시작 URL 연결 완료 |
| `PRD_W1.md` | `FR-PL-002a` Apple OAuth 로그인/회원가입 | 프론트 버튼과 redirect 연결 완료. 백엔드 Apple provider 등록 확인 필요 |
| `PRD_W1.md` | `FR-PL-003` JWT Access/Refresh 발급 및 갱신 | callback token 저장, session restore, Dio refresh retry 구현 완료 |
| `PRD_W1.md` | `FR-PL-004` TOTP MFA 등록 | MFA setup/verify API client 및 설정 화면 연결 완료. 실제 QR 렌더링은 placeholder |
| `PRD_W1.md` | `FR-FE-002` OAuth 버튼 -> platform-svc -> token 저장 | 구현 및 테스트 완료 |
| `PRD_W1.md` | `FR-FE-003` 인증 사용자 dashboard/sidebar | 기존 shell 유지, auth restore 초기 redirect 문제 보강 |
| `PRD_W2.md` | `FR-PL-101` Stripe Checkout | checkout session 생성, success/cancel URL 전달, `checkoutUrl` 이동 구현 완료 |
| `PRD_W2.md` | `FR-PL-102` Stripe Webhook | 백엔드 담당. 프론트는 return route만 준비 |
| `PRD_W2.md` | `FR-PL-103` 플랜별 기능 제한 확인 | `GET /billing/plans` 미제공 상태라 로컬 플랜 + subscription 조회까지만 구현 |
| `PRD_W2.md` | `FR-PL-104` FCM device 등록 | device 등록/삭제 API client 구현 완료. 실제 FCM Web token 발급은 잔여 |
| `PRD_W3.md` | `FR-PL-201` W2 FCM device 등록/테스트 잔무 | API client 완료. token 갱신 안정화 및 E2E는 잔여 |

## 체크하지 않은 항목과 이유

### Token 저장 정책

`WORKFLOW_frontend_W1.md`에는 다음 방향이 남아 있다.

- SecureStorage만 허용
- refreshToken은 httpOnly Cookie로 서버에서 관리
- 클라이언트가 refreshToken을 직접 저장하지 않음

현재 구현은 백엔드 연동 문서와 리뷰 결과에 맞춰 OAuth callback query parameter의 `access_token`, `refresh_token`을 받아 `TokenStore`에 저장한다.

따라서 workflow의 token 저장 정책 항목은 현재 구현과 충돌하므로 체크하지 않았다. 이 항목은 백엔드 최종 인증 정책에 맞춰 문서 또는 구현 중 하나를 정리해야 한다.

### 이메일/비밀번호 로그인 및 회원가입

다음 항목은 아직 구현하지 않았으므로 체크하지 않았다.

- `LoginRequest` 모델
- `SignupRequest` 모델
- 이메일/비밀번호 로그인 API 연동
- 회원가입 폼 유효성 검증
- 폼 제출 widget test
- `AuthRepository` 클래스

### Billing/FCM Workflow 공백

`PRD_W2.md`에는 platform-owner의 Billing + Notification 기초 요구사항이 있다.

- `FR-PL-101` Stripe Checkout
- `FR-PL-102` Stripe Webhook
- `FR-PL-103` 플랜별 기능 제한
- `FR-PL-104` FCM device 등록

하지만 `WORKFLOW_frontend_W2.md`에는 platform frontend의 Billing/FCM 세부 체크리스트가 없다. 따라서 오늘 구현한 Billing/FCM frontend 작업은 PRD에는 매핑되지만, workflow에서 체크할 항목이 없다.

필요하면 별도 workflow section을 추가하는 것이 맞다.

## 오늘 작업 완료로 볼 수 있는 범위

- W1 OAuth frontend 시작/callback/token 저장/guard 기반 작업
- W1 dashboard 접근 guard와 auth restore 안정화
- W2 Stripe Checkout frontend 연동 기반
- W2 FCM device 등록/삭제 API client
- W3 FCM 잔무 중 API client 기반

## 남은 확인 항목

- Apple OAuth provider가 platform-svc에 실제 등록되어 있는지 확인
- 실제 OAuth E2E: provider login -> callback -> token 저장 -> dashboard 이동
- refresh 실패 시 `AuthNotifier` 상태와 token store 동기화 보강
- 실제 Stripe Test Mode: checkout -> success/cancel -> webhook -> subscription 상태 갱신
- 실제 FCM Web token 발급 및 token 갱신 안정화
- `WORKFLOW_frontend_W2.md`에 Billing/FCM frontend section 추가 여부 결정
- token 저장 정책 문서 정리: query token 저장 방식 vs httpOnly Cookie 방식

## 검증 상태

오늘 구현 범위 기준:

```powershell
flutter test --no-pub
```

통과.

```powershell
flutter analyze --no-pub lib\core lib\services\platform test\core test\services test\widget_test.dart
```

통과.

전체 analyze:

```powershell
flutter analyze --no-pub
```

기존 `engagement` / `learning` 영역 info 50건으로 실패한다. 오늘 platform 작업 범위 신규 issue는 없다.
