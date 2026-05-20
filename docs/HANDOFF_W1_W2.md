# W1+W2 프론트엔드 뼈대 — 팀원 핸드오프

> **PR**: #6 `feat(frontend): W1+W2 scaffold`  
> **브랜치**: `refactor/manual-riverpod-providers` → `main`  
> **작성일**: 2026-05-20

---

## 1. 무엇이 바뀌었는가

### 구조 변경 (전체 영향)

| Before | After |
|--------|-------|
| 40+ 플랫 GoRoute | **ShellRoute** 기반 사이드바 + AppBar + 콘텐츠 구조 |
| 라우팅만 있고 레이아웃 없음 | 반응형 AppShell (Desktop/Tablet/Mobile) |
| 인증 가드 없음 | **AuthNotifier** + GoRouter redirect (`/login` ↔ 보호 라우트) |

### 신규 파일 (6개)

| 파일 | 역할 | 팀원이 할 일 |
|------|------|-------------|
| `lib/core/auth/auth_state.dart` | AuthStatus enum + AuthState 클래스 | 필드 추가 필요 시 `copyWith` 확장 |
| `lib/core/auth/auth_notifier.dart` | 인증 Provider 뼈대 | `login()`, `signup()`, `loginWithOAuth()` 구현 |
| `lib/shared/widgets/app_shell.dart` | ShellRoute 레이아웃 (AppBar + SideNav + 콘텐츠) | 수정 불필요 |
| `lib/shared/widgets/side_nav.dart` | 사이드바 (240px/56px 토글, 반응형) | 수정 불필요 |
| `lib/shared/widgets/bottom_nav.dart` | 모바일 하단 네비게이션 (4탭) | 수정 불필요 |
| `lib/shared/widgets/flip_card.dart` | 3D 플립 카드 위젯 (300ms 애니메이션) | 그대로 사용 |

### 수정된 화면 (6개)

| 화면 | 파일 | 변경 내용 | 팀원이 채울 것 |
|------|------|-----------|---------------|
| 로그인 | `auth_screens.dart` | 폼 UI (이메일+비밀번호+OAuth 버튼) | `authNotifier.login()` 내부 — platform-svc 연동 |
| 회원가입 | `auth_screens.dart` | 폼 UI (이메일+비밀번호+확인) | `authNotifier.signup()` 내부 — platform-svc 연동 |
| 대시보드 | `dashboard_screen.dart` | 카드 3섹션 (복습/노트/통계) | 각 섹션에 API 데이터 바인딩 |
| 노트 에디터 | `note_screens.dart` | 분할 뷰 (편집+마크다운 미리보기) + 툴바 | knowledge-svc 연동, 자동저장, 위키링크 |
| 복습 | `card_screens.dart` | FlipCard + 난이도 버튼 4종 | learning-svc 연동, SM-2 rating API |
| 커뮤니티 | `community_screens.dart` | 그룹 목록/상세 탭 레이아웃 | engagement-svc 연동, 페이지네이션 |

---

## 2. 팀원별 다음 할 일

### @platform-owner (김해준) — Auth 연동

`lib/core/auth/auth_notifier.dart`의 빈 메서드 구현:

```dart
// 1. login() — platform-svc POST /api/v1/auth/login
// 2. loginWithOAuth() — OAuth PKCE 플로우
// 3. signup() — platform-svc POST /api/v1/auth/signup
// 4. flutter_secure_storage로 토큰 저장 (hive 또는 secure_storage)
```

**찾는 법**: 파일에서 `// TODO: 팀원 구현` 검색

### @knowledge-owner-1 (김현지) — 노트 에디터 연동

`lib/services/knowledge/features/notes/presentation/screens/note_screens.dart`:

```
- NoteEditorScreen의 TextField → knowledge-svc API 연동
- 자동저장 (5초 debounce)
- 위키링크 [[note-title]] 파싱
- NoteListScreen placeholder → 실제 노트 목록
```

### @learning-card-owner (김나경) — 복습 화면 연동

`lib/services/learning/features/cards/presentation/screens/card_screens.dart`:

```
- ReviewScreen의 FlipCard → learning-svc 카드 데이터 바인딩
- 난이도 버튼 onTap → SM-2 rating API 호출
- 복습 세션 관리 (다음 카드 로드, 진행 상태)
- DeckListScreen placeholder → 실제 덱 목록
```

### @engagement-owner (한승완) — 커뮤니티 연동

`lib/services/engagement/features/community/presentation/screens/community_screens.dart`:

```
- CommunityGroupsScreen → engagement-svc 그룹 목록 API
- CommunityGroupDetailScreen → 멤버/공유 콘텐츠 API
- 가입/탈퇴 기능
- 무한 스크롤 페이지네이션
```

---

## 3. 반응형 브레이크포인트

| 뷰포트 | 너비 | 레이아웃 |
|--------|------|---------|
| Desktop | >1024px | 고정 사이드바 (240px, 토글 가능) |
| Tablet | 600-1024px | 사이드바 축소 (56px, 아이콘만) |
| Mobile | <600px | 사이드바 숨김 → Drawer + BottomNav 4탭 |

> 새 화면 추가 시 **ShellRoute 안에** GoRoute를 넣으면 자동으로 사이드바 + AppBar가 적용됩니다.

---

## 4. 새 화면 추가 가이드

### Step 1: 라우트 추가

`lib/core/constants/app_routes.dart`에 경로 추가:
```dart
static const myNewScreen = '/my-new-screen';
```

### Step 2: 화면 위젯 작성

해당 도메인 폴더에 위젯 작성 (예: `lib/services/platform/features/...`)

### Step 3: GoRouter에 등록

`lib/core/router/app_router.dart`의 ShellRoute `routes` 배열에 추가:
```dart
GoRoute(
  path: AppRoutes.myNewScreen,
  builder: (context, state) => const MyNewScreen(),
),
```

> 인증 불필요 화면은 ShellRoute **바깥**에 배치

---

## 5. TODO 검색

프로젝트 전체에서 팀원이 구현할 부분 찾기:

```bash
grep -rn "// TODO: 팀원" lib/
```

현재 TODO 위치:
- `auth_notifier.dart` — login, loginWithOAuth, signup, logout
- `dashboard_screen.dart` — 복습 카드 수, 최근 노트, 학습 통계
- `note_screens.dart` — 자동저장, API 연동, 위키링크
- `card_screens.dart` — 카드 데이터, SM-2 API
- `community_screens.dart` — 그룹 목록/상세/멤버/콘텐츠 API

---

## 6. 테스트

```bash
flutter test          # 9개 테스트 통과
flutter analyze       # 0 issues
```

테스트 구성:
- `test/core/auth/auth_notifier_test.dart` — AuthNotifier 상태 전이 (2)
- `test/shared/widgets/app_shell_test.dart` — 반응형 SideNav/BottomNav (2)
- `test/shared/widgets/flip_card_test.dart` — 카드 플립 동작 (2)
- `test/widget_test.dart` — 앱 전체 라우팅/인증/서비스 경계 (3)
