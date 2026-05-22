# Platform Frontend Review Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 코드 리뷰에서 확인된 Billing API 계약 불일치와 앱 시작 시 auth restore 라우팅 문제를 실제 platform-svc 연동 기준으로 수정한다.

**Architecture:** Billing 수정은 `BillingApi`의 request/response 계약을 백엔드 스펙에 맞추고, Stripe 복귀 URL은 프론트 실행 origin 기준으로 생성한다. Auth 수정은 앱 시작 상태를 별도 `initializing` 상태로 분리해 저장 토큰 복원 전 `/login` redirect와 보호 화면 노출을 모두 막는다.

**Tech Stack:** Flutter, Riverpod, GoRouter, Dio, Hive, flutter_test.

---

## Scope

이번 계획은 코드 리뷰에서 확인된 4개 항목만 다룬다.

| 항목 | 처리 |
| --- | --- |
| Billing checkout request `plan` 필드 오류 | `planCode`로 변경 |
| Billing subscription response `plan` 파싱 오류 | `planCode` 파싱 |
| Billing checkout `successUrl`, `cancelUrl` 누락 | payload에 포함 |
| 앱 시작 시 저장 토큰 복원 전 `/login` redirect | auth 초기화 상태 분리 |

README는 수정하지 않는다.

---

## File Map

| 파일 | 책임 |
| --- | --- |
| `lib/services/platform/features/billing/data/billing_api.dart` | Billing API request/response 계약 수정 |
| `lib/services/platform/features/billing/presentation/screens/billing_screens.dart` | checkout 호출부와 subscription 로딩 중 버튼 상태 수정 |
| `test/services/platform/billing/billing_api_test.dart` | `planCode`, `successUrl`, `cancelUrl`, subscription `planCode` 파싱 검증 |
| `test/services/platform/billing/billing_plans_screen_test.dart` | 화면에서 checkout 생성 시 올바른 plan code로 호출하는지 검증 |
| `lib/core/auth/auth_state.dart` | 앱 부팅 세션 복원용 auth status 추가 |
| `lib/core/auth/auth_notifier.dart` | 초기 상태와 restore 완료 상태 전환 수정 |
| `lib/app.dart` | auth initializing 상태에서 splash shell 표시 |
| `lib/core/router/app_router.dart` | initializing/loading 상태의 redirect 정책 정리 |
| `test/core/auth/auth_notifier_test.dart` | 초기화 상태와 restore 완료 상태 검증 |
| `test/widget_test.dart` | 저장 토큰 복원 전 로그인 화면 깜빡임 방지 검증 |

---

## Task 1: Billing API 계약 테스트 수정

**Files:**
- Modify: `test/services/platform/billing/billing_api_test.dart`

- [ ] **Step 1: subscription 응답 필드 테스트를 `planCode` 기준으로 바꾼다**

현재 테스트의 응답 JSON을 아래처럼 바꾼다.

```dart
return ResponseBody.fromString(
  jsonEncode({'planCode': 'pro', 'status': 'ACTIVE'}),
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);
```

검증은 대문자 정규화를 기대한다.

```dart
expect(subscription?.plan, 'PRO');
expect(subscription?.status, 'ACTIVE');
```

- [ ] **Step 2: checkout request payload 테스트를 `planCode`, `successUrl`, `cancelUrl` 기준으로 바꾼다**

`createCheckout` 호출은 복귀 URL을 명시하는 형태로 바꾼다.

```dart
final session = await api.createCheckout(
  planCode: 'PRO',
  successUrl: 'http://127.0.0.1:8088/billing/success',
  cancelUrl: 'http://127.0.0.1:8088/billing/cancel',
);
```

adapter expectation은 아래 payload를 기대한다.

```dart
expect(options.data, {
  'planCode': 'PRO',
  'successUrl': 'http://127.0.0.1:8088/billing/success',
  'cancelUrl': 'http://127.0.0.1:8088/billing/cancel',
});
```

- [ ] **Step 3: RED 확인**

Run:

```powershell
flutter test --no-pub test\services\platform\billing\billing_api_test.dart
```

Expected: `BillingApi.createCheckout` signature 또는 `options.data` expectation mismatch로 FAIL.

---

## Task 2: Billing API 구현 수정

**Files:**
- Modify: `lib/services/platform/features/billing/data/billing_api.dart`
- Modify: `lib/services/platform/features/billing/presentation/screens/billing_screens.dart`
- Modify: `test/services/platform/billing/billing_plans_screen_test.dart`

- [ ] **Step 1: `BillingApi.getSubscription()`에서 `planCode`를 파싱한다**

`billing_api.dart`의 subscription mapping을 아래 형태로 바꾼다.

```dart
final planCode = data['planCode'];
return BillingSubscription(
  plan: planCode is String ? planCode.toUpperCase() : 'FREE',
  status: (data['status'] as String?) ?? 'UNKNOWN',
);
```

- [ ] **Step 2: `createCheckout` signature를 명시적 payload로 바꾼다**

`BillingApi.createCheckout`를 아래 형태로 바꾼다.

```dart
Future<CheckoutSession> createCheckout({
  required String planCode,
  required String successUrl,
  required String cancelUrl,
}) async {
  final response = await _dio.post<Map<String, dynamic>>(
    '/api/v1/billing/checkout',
    data: {
      'planCode': planCode,
      'successUrl': successUrl,
      'cancelUrl': cancelUrl,
    },
  );
  final data = response.data ?? const <String, dynamic>{};
  final checkoutUrl = data['checkoutUrl'];

  if (checkoutUrl is! String || checkoutUrl.isEmpty) {
    throw const FormatException('Invalid billing checkout response.');
  }

  return CheckoutSession(checkoutUrl);
}
```

- [ ] **Step 3: Stripe 복귀 URL 생성 책임을 화면 쪽에 둔다**

`BillingPlansScreen`의 state에 helper를 추가한다. W1~W2 로컬 실행은 `http://127.0.0.1:8088`이고, web 환경에서는 `Uri.base.origin`을 우선 사용한다.

```dart
String get _frontendOrigin {
  final base = Uri.base;
  if (base.hasScheme && (base.scheme == 'http' || base.scheme == 'https')) {
    return base.origin;
  }
  return 'http://127.0.0.1:8088';
}

String get _billingSuccessUrl => '$_frontendOrigin/billing/success';
String get _billingCancelUrl => '$_frontendOrigin/billing/cancel';
```

checkout 호출부는 아래처럼 바꾼다.

```dart
final session = await ref.read(billingApiProvider).createCheckout(
      planCode: plan.code,
      successUrl: _billingSuccessUrl,
      cancelUrl: _billingCancelUrl,
    );
```

- [ ] **Step 4: subscription 로딩 중 checkout 버튼을 비활성화한다**

`_PlanData`에 `isDisabled`를 추가한다.

```dart
final bool isDisabled;
```

`_plans()`에서 현재 플랜이 아닌 유료 플랜은 subscription 조회 중 비활성화한다.

```dart
isDisabled: _loadingSubscription,
```

버튼 `onPressed` 조건은 아래처럼 바꾼다.

```dart
onPressed: plan.isCheckoutLoading || plan.isDisabled
    ? null
    : () => onCheckout(plan),
```

- [ ] **Step 5: 화면 테스트 fake API signature를 맞춘다**

`billing_plans_screen_test.dart`의 fake API override를 아래 형태로 바꾼다.

```dart
@override
Future<CheckoutSession> createCheckout({
  required String planCode,
  required String successUrl,
  required String cancelUrl,
}) async {
  checkoutPlans.add(planCode);
  return CheckoutSession(
    'https://checkout.stripe.test/${planCode.toLowerCase()}',
  );
}
```

- [ ] **Step 6: GREEN 확인**

Run:

```powershell
flutter test --no-pub test\services\platform\billing\billing_api_test.dart test\services\platform\billing\billing_plans_screen_test.dart
```

Expected: All tests passed.

- [ ] **Step 7: Review checkpoint**

확인할 내용:
- `POST /api/v1/billing/checkout` payload가 `planCode`, `successUrl`, `cancelUrl`를 포함한다.
- `GET /api/v1/billing/subscription` 응답의 `planCode: "pro"`가 UI 내부에서 `PRO`로 정규화된다.
- subscription 로딩 중 유료 checkout 버튼이 비활성화된다.

---

## Task 3: Auth 초기화 상태 테스트 추가

**Files:**
- Modify: `test/core/auth/auth_notifier_test.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: AuthNotifier 초기 상태 테스트를 `initializing` 기준으로 바꾼다**

`auth_notifier_test.dart`의 초기 상태 검증을 아래처럼 바꾼다.

```dart
test('initial state is initializing', () {
  final state = container.read(authNotifierProvider);
  expect(state.status, AuthStatus.initializing);
  expect(state.accessToken, isNull);
});
```

- [ ] **Step 2: 저장 토큰이 없을 때 restore 후 unauthenticated가 되는 테스트를 추가한다**

```dart
test('restoreSession without tokens resolves to unauthenticated', () async {
  await container.read(authNotifierProvider.notifier).restoreSession();

  final state = container.read(authNotifierProvider);
  expect(state.status, AuthStatus.unauthenticated);
  expect(state.accessToken, isNull);
  expect(state.refreshToken, isNull);
});
```

- [ ] **Step 3: 앱 시작 중 login screen이 보이지 않는 widget test를 추가한다**

`test/widget_test.dart`에 지연 token store를 추가한다.

```dart
class _DelayedTokenStore implements TokenStore {
  final completer = Completer<AuthTokens?>();

  @override
  Future<AuthTokens?> read() => completer.future;

  @override
  Future<void> save(AuthTokens tokens) async {}

  @override
  Future<void> clear() async {}
}
```

테스트를 추가한다.

```dart
testWidgets('startup restore shows bootstrap state instead of login', (
  tester,
) async {
  final tokenStore = _DelayedTokenStore();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [tokenStoreProvider.overrideWithValue(tokenStore)],
      child: const SynapseApp(),
    ),
  );
  await tester.pump();

  expect(find.byType(LoginScreen), findsNothing);
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  tokenStore.completer.complete(null);
  await tester.pumpAndSettle();

  expect(find.byType(LoginScreen), findsOneWidget);
});
```

- [ ] **Step 4: RED 확인**

Run:

```powershell
flutter test --no-pub test\core\auth\auth_notifier_test.dart test\widget_test.dart
```

Expected: `AuthStatus.initializing`이 없어 FAIL.

---

## Task 4: Auth 초기화 흐름 구현

**Files:**
- Modify: `lib/core/auth/auth_state.dart`
- Modify: `lib/core/auth/auth_notifier.dart`
- Modify: `lib/app.dart`
- Modify: `lib/core/router/app_router.dart`

- [ ] **Step 1: AuthStatus에 `initializing`을 추가한다**

`auth_state.dart`를 아래처럼 바꾼다.

```dart
enum AuthStatus { initializing, unauthenticated, loading, authenticated }
```

`AuthState` 기본값은 `initializing`으로 둔다.

```dart
const AuthState({
  this.status = AuthStatus.initializing,
  this.accessToken,
  this.refreshToken,
});
```

- [ ] **Step 2: restoreSession 완료 상태를 명확히 한다**

`auth_notifier.dart`의 `restoreSession()`을 아래 형태로 바꾼다.

```dart
Future<void> restoreSession() async {
  state = const AuthState(status: AuthStatus.initializing);
  final tokens = await ref.read(tokenStoreProvider).read();
  if (tokens == null) {
    state = const AuthState(status: AuthStatus.unauthenticated);
    return;
  }

  state = AuthState(
    status: AuthStatus.authenticated,
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
  );
}
```

`logout()`은 명시적으로 unauthenticated를 설정한다.

```dart
state = const AuthState(status: AuthStatus.unauthenticated);
```

- [ ] **Step 3: 앱 초기화 중 bootstrap 화면을 표시한다**

`app.dart`에서 auth state를 watch하고, `initializing`일 때 router 대신 최소 shell을 표시한다.

```dart
final authState = ref.watch(authNotifierProvider);

if (authState.status == AuthStatus.initializing) {
  return MaterialApp(
    title: 'Synapse',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    home: const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ),
  );
}
```

`AuthStatus` import가 이미 `auth_notifier.dart` 경유로 충분하지 않으면 `auth_state.dart`를 직접 import한다.

- [ ] **Step 4: router redirect에서 initializing/loading을 보류한다**

`app_router.dart` redirect 상단에 아래 조건을 둔다.

```dart
if (authState.status == AuthStatus.initializing ||
    authState.status == AuthStatus.loading) {
  return null;
}
```

이 조건은 기존 public route 검사보다 먼저 실행한다.

- [ ] **Step 5: GREEN 확인**

Run:

```powershell
flutter test --no-pub test\core\auth\auth_notifier_test.dart test\widget_test.dart
```

Expected: All tests passed.

- [ ] **Step 6: Review checkpoint**

확인할 내용:
- 저장 토큰 복원 전에는 login screen이 렌더링되지 않는다.
- 저장 토큰이 있으면 authenticated로 복원된다.
- 저장 토큰이 없으면 unauthenticated가 되고 login route로 이동한다.
- `/auth/callback`은 public route로 남아 OAuth token 처리 흐름을 유지한다.

---

## Task 5: 전체 회귀 검증

**Files:**
- No code changes.

- [ ] **Step 1: 관련 테스트 전체 실행**

Run:

```powershell
flutter test --no-pub test\core\auth\auth_notifier_test.dart test\widget_test.dart test\services\platform\billing\billing_api_test.dart test\services\platform\billing\billing_plans_screen_test.dart
```

Expected: All tests passed.

- [ ] **Step 2: 전체 테스트 실행**

Run:

```powershell
flutter test --no-pub
```

Expected: All tests passed.

- [ ] **Step 3: platform/core analyze 실행**

Run:

```powershell
flutter analyze --no-pub lib\core lib\services\platform test\core test\services test\widget_test.dart
```

Expected: No issues found.

- [ ] **Step 4: 전체 analyze 상태 기록**

Run:

```powershell
flutter analyze --no-pub
```

Expected: 기존 `engagement`/`learning` 영역 info가 남아 실패할 수 있다. 이번 수정 범위에서 새 issue가 생기면 해당 파일을 수정한다.

- [ ] **Step 5: 작업 리뷰**

리뷰 체크리스트:
- Billing payload가 director 스펙과 맞는가.
- Billing response parser가 `planCode`를 사용하고 대소문자를 정규화하는가.
- Stripe 복귀 URL이 `/billing/success`, `/billing/cancel`로 생성되는가.
- 앱 시작 중 login flicker가 사라졌는가.
- 기존 OAuth callback route guard 예외가 유지되는가.
- README가 변경되지 않았는가.

---

## Commit Plan

작업 단위별 commit message 후보:

1. `fix(platform): align billing api contract`
2. `fix(auth): gate routing during session restore`
3. `test(platform): cover billing contract and auth restore startup`

---

## Self-Review

- Spec coverage: Billing 필드명 2건, success/cancel URL 누락, auth restore flicker를 각각 Task 1~4에서 다룬다.
- Placeholder scan: 구현 단계에 필요한 파일, 코드 형태, 명령, expected result를 명시했다.
- Type consistency: Billing checkout은 `planCode`, `successUrl`, `cancelUrl` named parameter로 통일했다. Auth 초기화 상태는 `AuthStatus.initializing`으로 통일했다.
