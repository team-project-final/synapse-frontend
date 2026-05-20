# W1+W2 프론트엔드 뼈대 설계서

> **작성일**: 2026-05-20  
> **브랜치**: `refactor/manual-riverpod-providers`  
> **범위**: W1 Step 1~3 + W2 Step 4~6 — 뼈대(scaffold) 전용  
> **원칙**: 비즈니스 로직은 각 팀원 담당. 여기서는 구조/레이아웃/네비게이션만 구현.

---

## 1. 현재 상태

### 이미 있는 것
- `ProviderScope` + `GoRouter` 40+ 플랫 라우트
- `AppTheme.light()` + `AppColors` (Warm Intellectual) + `AppSpacing` 토큰
- 서비스 도메인별 폴더 구조 (`lib/services/{platform,knowledge,learning,engagement}`)
- `DomainPlaceholderScaffold` 기반 모든 화면 placeholder
- `DioClient`, `AppEnvironment` HTTP 인프라

### 없는 것 (이번에 구현)
- ShellRoute 기반 사이드바 + 콘텐츠 레이아웃
- 로그인/회원가입 폼 UI 껍데기
- AuthState/AuthNotifier Provider 뼈대 + GoRouter redirect guard
- 노트 에디터 분할 뷰 레이아웃
- SRS 복습 카드 플립 위젯
- 커뮤니티 그룹 목록/상세 레이아웃

---

## 2. 라우터 구조 전환

### 2.1 Before → After

**Before**: 40+ 플랫 GoRoute (모두 최상위)

**After**: 3-tier 구조

```
GoRouter (redirect: authGuard)
│
├── 비인증 라우트 (Shell 밖)
│   ├── /login
│   ├── /signup
│   ├── /mfa
│   ├── /password-reset
│   └── /oauth-consent
│
└── ShellRoute → AppShell (사이드바 + AppBar + 콘텐츠)
    ├── / (Dashboard)
    ├── /notes
    ├── /notes/:noteId
    ├── /notes/:noteId/edit
    ├── /notes/:noteId/versions
    ├── /tags
    ├── /decks
    ├── /decks/:deckId/cards
    ├── /cards/new
    ├── /ai/cards
    ├── /review
    ├── /review/result
    ├── /graph
    ├── /graph/notes/:noteId
    ├── /graph/clusters
    ├── /search
    ├── /qa
    ├── /billing/plans
    ├── /billing/usage
    ├── /billing/history
    ├── /settings/profile
    ├── /settings/security
    ├── /settings/notifications
    ├── /settings/data
    ├── /settings/tenant
    ├── /admin
    ├── /community/groups
    ├── /community/groups/new
    ├── /community/groups/:groupId
    ├── /community/shared-decks
    ├── /community/shared-decks/:deckId
    ├── /community/shared-notes
    ├── /gamification/profile
    ├── /gamification/badges
    ├── /gamification/leaderboard
    ├── /notifications
    └── /notifications/settings
```

### 2.2 AppShell 레이아웃

```
Desktop (>1024px):
┌─────────────────────────────────────────────────┐
│  AppBar: 로고 · (검색placeholder) · 알림 · 프로필 │
├──────────┬──────────────────────────────────────┤
│ SideNav  │                                      │
│ 240px    │         child (from router)           │
│          │                                      │
│ 대시보드  │                                      │
│ 노트     │                                      │
│ 덱/복습  │                                      │
│ 그래프   │                                      │
│ 검색     │                                      │
│ 커뮤니티  │                                      │
│ ──────  │                                      │
│ 알림     │                                      │
│ 설정     │                                      │
├──────────┴──────────────────────────────────────┤

Tablet (600-1024px):
│ SideNav 56px (아이콘만) │  child                 │

Mobile (<600px):
│ SideNav 숨김. BottomNavigationBar 4탭:           │
│ 홈 / 노트 / 복습 / 더보기                         │
```

### 2.3 SideNav 항목

| 순서 | 아이콘 | 라벨 | 라우트 | 구분 |
|------|--------|------|--------|------|
| 1 | dashboard | 대시보드 | `/` | 상단 그룹 |
| 2 | description | 노트 | `/notes` | |
| 3 | style | 덱/복습 | `/decks` | |
| 4 | hub | 그래프 | `/graph` | |
| 5 | search | 검색 | `/search` | |
| 6 | groups | 커뮤니티 | `/community/groups` | |
| — | — | — | — | 구분선 |
| 7 | notifications | 알림 | `/notifications` | 하단 그룹 |
| 8 | settings | 설정 | `/settings/profile` | |

### 2.4 BottomNav 항목 (Mobile)

| 탭 | 아이콘 | 라우트 |
|----|--------|--------|
| 홈 | home | `/` |
| 노트 | description | `/notes` |
| 복습 | style | `/decks` |
| 더보기 | menu | Drawer 열기 |

---

## 3. 인증 가드 뼈대

### 3.1 AuthState

```dart
enum AuthStatus { unauthenticated, loading, authenticated }

class AuthState {
  final AuthStatus status;
  final String? accessToken;   // 팀원이 채움
  final String? refreshToken;  // 팀원이 채움
}
```

### 3.2 AuthNotifier

```dart
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);

  Future<void> login(String email, String password) async {
    // TODO: 팀원 구현 — platform-svc 연동
  }

  Future<void> loginWithOAuth(String provider) async {
    // TODO: 팀원 구현 — OAuth PKCE 플로우
  }

  Future<void> signup(String email, String password) async {
    // TODO: 팀원 구현
  }

  void logout() {
    // TODO: 팀원 구현 — 토큰 삭제
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
```

### 3.3 GoRouter Redirect Guard

```dart
redirect: (context, state) {
  final auth = ref.read(authNotifierProvider);
  final isAuthRoute = ['/login', '/signup', '/mfa', '/password-reset', '/oauth-consent']
      .contains(state.matchedLocation);

  if (auth.status == AuthStatus.unauthenticated && !isAuthRoute) {
    return '/login';
  }
  if (auth.status == AuthStatus.authenticated && isAuthRoute) {
    return '/';
  }
  return null;
}
```

---

## 4. 화면 뼈대 설계

### 4.1 로그인 화면 (SCR-W-AUTH-001)

**파일**: `lib/services/platform/features/auth/presentation/screens/auth_screens.dart`

```
┌──────────────────────────────────┐
│     [Synapse 로고 + 타이틀]       │
│                                  │
│  ┌────────────────────────────┐  │
│  │  이메일 (TextFormField)     │  │
│  ├────────────────────────────┤  │
│  │  비밀번호 (obscured)        │  │
│  ├────────────────────────────┤  │
│  │  [ 로그인 ] FilledButton    │  │
│  └────────────────────────────┘  │
│                                  │
│  ───────── 또는 ─────────       │
│                                  │
│  [ Google로 로그인 ] OutlinedBtn │
│  [ GitHub로 로그인 ] OutlinedBtn │
│                                  │
│  회원가입 / 비밀번호 찾기 링크    │
└──────────────────────────────────┘
```

- 최대 너비 400px, 세로 중앙 정렬
- 폼 유효성 검증 UI만 (이메일 형식, 비밀번호 8자+)
- `onSubmit` → `authNotifier.login()` 호출 (빈 메서드)
- OAuth 버튼 → `authNotifier.loginWithOAuth('google')` (빈 메서드)

### 4.2 회원가입 화면 (SCR-W-AUTH-002)

- 로그인과 동일 레이아웃, 필드 추가: 비밀번호 확인
- `onSubmit` → `authNotifier.signup()` (빈 메서드)

### 4.3 대시보드 (SCR-W-DASH-001)

**파일**: `lib/shared/features/dashboard/presentation/screens/dashboard_screen.dart`

```
┌─────────────────────────────────┐
│  오늘의 복습 카드                 │
│  ┌───────────────────────────┐  │
│  │  0장 대기중                │  │
│  │  [ 복습 시작 ] → /review  │  │
│  └───────────────────────────┘  │
├─────────────────────────────────┤
│  최근 노트                      │
│  (빈 상태 placeholder)          │
├─────────────────────────────────┤
│  학습 통계                      │
│  (빈 상태 placeholder)          │
└─────────────────────────────────┘
```

- 카드 위젯으로 섹션 분리
- 각 섹션은 `// TODO: 팀원 API 연동` 상태
- 복습 시작 버튼 → `/review`로 이동

### 4.4 노트 에디터 (SCR-W-NOTE-002) — W2

**파일**: `lib/services/knowledge/features/notes/presentation/screens/note_screens.dart`

```
┌────────────────────────────────────────┐
│ 툴바: [B] [I] [H1] [H2] [Link] [Code] │
├───────────────────┬────────────────────┤
│                   │                    │
│  편집 영역          │  미리보기 영역      │
│  (TextField       │  (MarkdownBody     │
│   multiline)      │   렌더링)          │
│                   │                    │
│                   │                    │
├───────────────────┴────────────────────┤
│  저장 상태: ● 저장됨                     │
└────────────────────────────────────────┘
```

- `flutter_markdown` 패키지 추가 (pubspec.yaml)
- 좌우 분할 뷰 (Row + Expanded 50:50)
- 모바일에서는 탭 전환 (편집 / 미리보기)
- 툴바 버튼은 TextField에 마크다운 문법 삽입만
- API 연동, 자동저장, 위키링크 파싱은 팀원

### 4.5 SRS 복습 화면 (SCR-W-CARD-005) — W2

**파일**: `lib/services/learning/features/cards/presentation/screens/card_screens.dart`

```
┌──────────────────────────────────┐
│  진행: 1 / 20        [X 종료]    │
├──────────────────────────────────┤
│                                  │
│        ┌──────────────┐          │
│        │              │          │
│        │  카드 앞면     │          │
│        │  (질문)       │          │
│        │              │          │
│        └──────────────┘          │
│                                  │
│        [ 답 보기 ]               │
│                                  │
├──────────────────────────────────┤
│  (답 보기 후 표시)                │
│  [Again] [Hard] [Good] [Easy]    │
└──────────────────────────────────┘
```

**FlipCard 위젯**:
- `AnimatedBuilder` + `Matrix4.rotationY` (Y축 3D 회전)
- 300ms ease-in-out
- 탭하면 앞→뒤 전환
- 뼈대: 앞면/뒷면에 `Text` placeholder

**난이도 버튼**:
- 4개 `FilledButton` 가로 배치
- 색상: Again=error, Hard=warning, Good=success, Easy=info (AppColors)
- `onPressed` → `// TODO: 팀원 SM-2 API 호출`

### 4.6 커뮤니티 그룹 목록 (SCR-W-COMM-001) — W2

**파일**: `lib/services/engagement/features/community/presentation/screens/community_screens.dart`

```
┌────────────────────────────┐
│  [내 그룹] [탐색]  탭바     │
├────────────────────────────┤
│  ┌──────────────────────┐  │
│  │ 그룹명               │  │
│  │ 멤버 3명 · 공유 덱 5  │  │
│  │ 그룹 설명 1줄         │  │
│  └──────────────────────┘  │
│  ┌──────────────────────┐  │
│  │ 그룹 카드 2           │  │
│  └──────────────────────┘  │
│                            │
│  (빈 상태: 그룹이 없습니다) │
└────────────────────────────┘
```

### 4.7 커뮤니티 그룹 상세 (SCR-W-COMM-002) — W2

```
┌────────────────────────────┐
│  ← 뒤로   그룹명           │
│  멤버 N명 · 공유 덱 N개     │
├────────────────────────────┤
│  [멤버] [공유 콘텐츠] 탭바   │
├────────────────────────────┤
│  멤버 리스트                │
│  ┌────────────────────┐    │
│  │ 아바타 · 이름 · 역할 │    │
│  └────────────────────┘    │
│  (빈 상태: 멤버가 없습니다)  │
└────────────────────────────┘
```

---

## 5. 파일 변경 목록

### 신규 파일

| 파일 | 용도 |
|------|------|
| `lib/core/auth/auth_state.dart` | AuthState, AuthStatus enum |
| `lib/core/auth/auth_notifier.dart` | AuthNotifier Provider 뼈대 |
| `lib/shared/widgets/app_shell.dart` | ShellRoute 레이아웃 (AppBar + SideNav + 콘텐츠) |
| `lib/shared/widgets/side_nav.dart` | 사이드바 위젯 (240px/56px 토글) |
| `lib/shared/widgets/bottom_nav.dart` | Mobile 하단 네비게이션 |
| `lib/shared/widgets/flip_card.dart` | 3D 플립 카드 위젯 |

### 수정 파일

| 파일 | 변경 내용 |
|------|-----------|
| `lib/core/router/app_router.dart` | 플랫 라우트 → ShellRoute 구조 + redirect guard |
| `lib/services/platform/features/auth/presentation/screens/auth_screens.dart` | placeholder → 실제 폼 UI |
| `lib/shared/features/dashboard/presentation/screens/dashboard_screen.dart` | 그리드 → 대시보드 카드 레이아웃 |
| `lib/services/knowledge/features/notes/presentation/screens/note_screens.dart` | placeholder → 에디터 분할 뷰 |
| `lib/services/learning/features/cards/presentation/screens/card_screens.dart` | placeholder → 복습 카드 플립 UI |
| `lib/services/engagement/features/community/presentation/screens/community_screens.dart` | placeholder → 그룹 목록/상세 레이아웃 |
| `pubspec.yaml` | `flutter_markdown` 의존성 추가 |

### 문서 업데이트

| 파일 | 변경 내용 |
|------|-----------|
| `docs/project-management/workflow/WORKFLOW_frontend_W1.md` | 체크박스 갱신 |
| `docs/project-management/history/HISTORY_frontend.md` | 작업 로그 기록 |

---

## 6. 설계 제약 및 규칙

| 항목 | 규칙 |
|------|------|
| 비즈니스 로직 | `// TODO: 팀원 구현` 주석으로 자리만 잡기 |
| API 호출 | 실제 HTTP 요청 없음. Provider 뼈대만. |
| 테마 토큰 | `AppColors`, `AppSpacing`, `Theme.of(context)` 사용. 하드코딩 금지. |
| 반응형 | Desktop >1024px, Tablet 600-1024px, Mobile <600px |
| 사이드바 | 확장 240px, 축소 56px, 전환 200ms ease-in-out |
| 카드 플립 | 300ms ease-in-out, Y축 3D 회전 |
| 폰트 | GoogleFonts (Noto Sans — 현재 설정 유지) |
| 상태관리 | Riverpod 3.x (Notifier 패턴) |
| 라우팅 | GoRouter ShellRoute + redirect guard |

---

## 7. TASK-WORKFLOW 매핑

| TASK Step | 이번 구현 범위 | 팀원 잔여 |
|-----------|--------------|----------|
| Step 1 (프로젝트 구조) | 이미 완료 (main 코드) | 없음 |
| Step 2 (로그인/인증) | 폼 UI + AuthState/AuthNotifier 뼈대 + redirect guard | OAuth PKCE, SecureStorage, 토큰 갱신, platform-svc 연동 |
| Step 3 (대시보드/사이드바) | ShellRoute + AppShell + SideNav + BottomNav + 대시보드 카드 | API 연동, 실시간 데이터, 통계 차트 |
| Step 4 (노트 에디터) | 분할 뷰 + 툴바 + Markdown 미리보기 | knowledge-svc 연동, 자동저장, 위키링크 |
| Step 5 (SRS 복습) | FlipCard + 난이도 버튼 + 진행 표시 | learning-svc 연동, SM-2 계산, 세션 관리 |
| Step 6 (커뮤니티 그룹) | 목록/상세 레이아웃 + 탭 구조 + 빈 상태 | engagement-svc 연동, 가입/탈퇴, 페이지네이션 |
