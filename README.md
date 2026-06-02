# Synapse Frontend

**Synapse**는 노트 기반 지식 관리(PKM), 간격 반복(SRS) 학습 카드, AI 보조 검색·카드 생성,
학습 커뮤니티, 게이미피케이션, 계정/결제를 하나로 묶은 **학습 플랫폼**입니다.
이 저장소는 그 **Flutter 프론트엔드(웹/모바일)** 입니다.

> **현재 단계: 디자인 프로토타입.** 화면·디자인·내비게이션·UX 흐름이 구현되어 있고,
> 데이터는 mock으로 동작합니다. 실제 백엔드 API 연동은 각 feature 안의
> `// TODO: 팀원 구현` 지점에서 담당 작업자가 채웁니다.

---

## 주요 기능 (화면)

| 영역 | 화면 |
|---|---|
| **홈** | 편집 가능한 위젯 보드(오늘 복습·AI 추천·인사이트·스트릭·내 프로필·지식 그래프·AI 질문 등) |
| **플래너** | 월 캘린더(연·월 헤더) + 선택 날짜의 칸반 보드(수집/학습/복습/완료) |
| **노트** | 라이브러리(검색·태그 필터·Sliver) · 상세(위키링크) · 편집 · 버전 · 태그 관리 |
| **복습/덱** | 덱 목록·생성, 카드 목록·편집, **AI 카드 생성**, SRS 복습·결과 |
| **그래프** | 지식 그래프(중심성=노드 크기, 태그=색, 중앙 정렬) · 이웃 확장 · 클러스터 |
| **검색** | 통합 검색 · AI Q&A |
| **커뮤니티** | 그룹(목록·상세·생성) · 공유 덱/노트(목록·상세·검색) · 공유하기/공유받기·복사(fork)·공유 취소 · 신고 |
| **게이미피케이션** | 내 프로필(XP·레벨·스트릭) · XP 이력 · 배지 갤러리 · 리더보드 |
| **설정** | 프로필·보안(MFA)·알림·데이터·테넌트 · 로그아웃 |
| **관리자(웹)** | 대시보드·테넌트·사용자·감사 로그·시스템 설정·신고 모더레이션·콘텐츠·그룹·게이미피케이션·데이터 요청 |
| **기타** | 알림 센터 · 결제(요금제·사용량·내역) · 인증(로그인·회원가입·MFA·비밀번호 재설정·OAuth) |

> 로그인 화면에서 **로그인 버튼만 누르면** 앱으로 진입합니다(개발용 바이패스, 실제 인증 미연동).

---

## 기술 스택

| 영역 | 기술 |
|---|---|
| 프레임워크 | Flutter 3.x |
| 언어 | Dart (`>=3.11.0 <4.0.0`) |
| 상태 관리 | Riverpod 3 — **manual providers**(codegen 미사용) |
| 라우팅 | GoRouter (해시 URL, ShellRoute + AppShell) |
| HTTP | Dio |
| 로컬 저장 | Hive · flutter_secure_storage |
| 마크다운 | flutter_markdown |
| 애니메이션 | lottie |
| 타이포그래피 | Pretendard(번들 폰트) · google_fonts |
| 테스트 | flutter_test · integration_test · mockito |
| 린트 | flutter_lints (`analysis_options.yaml`) |

---

## 아키텍처

백엔드 4개 서비스 경계를 프론트에도 그대로 반영합니다. 한 백엔드 서비스에 매핑되는
feature는 `lib/services/<boundary>` 아래, 여러 경계를 가로지르는 화면은 `lib/shared`에 둡니다.

### 서비스 경계

| 프론트 경계 | 백엔드 서비스 | 도메인 |
|---|---|---|
| `platform` | platform-svc | auth · billing · notifications · settings · admin |
| `learning` | learning-svc | cards · SRS · AI 카드 생성 |
| `knowledge` | knowledge-svc | notes · graph · search |
| `engagement` | engagement-svc | community · gamification |
| `shared` | (공통) | dashboard(홈·플래너) · 공통 위젯 |

### 설계 원칙 (Port/Adapter)

- 화면/위젯은 Dio를 직접 호출하지 않고 **Repository(Port)** 를 경유합니다.
- DTO는 위젯까지 전달하지 않고 **Entity**로 변환해 넘깁니다.
- Repository 인터페이스(도메인)는 HTTP 라이브러리를 알지 못합니다(`dio` import 금지).
- 비즈니스 로직은 Provider가 아니라 **UseCase**로 추출합니다.

### feature 내부 구조

```text
feature/
├── data/         # Repository 구현, DTO, DataSource
├── domain/       # Entity, UseCase, Repository 인터페이스(Port)
├── presentation/
│   └── screens/  # UI 화면
└── providers/    # Riverpod Provider 등록
```

---

## 프로젝트 구조

```text
lib/
├── main.dart
├── core/
│   ├── auth/         # 인증 상태(AuthNotifier) · 토큰 저장
│   ├── constants/    # AppRoutes 등 상수
│   ├── network/      # Dio 클라이언트 · 환경(APP_ENV) 선택
│   ├── platform/     # 웹/네이티브 분기 헬퍼
│   ├── router/       # GoRouter 라우트 테이블
│   ├── services/     # 서비스 경계 레지스트리
│   └── theme/        # 디자인 토큰(AppColors/AppSpacing/AppRadius) · ThemeData
├── services/
│   ├── platform/     # auth · settings · notifications · billing · admin
│   ├── learning/     # cards
│   ├── knowledge/    # notes · graph · search
│   └── engagement/   # community · gamification
└── shared/
    ├── features/     # dashboard(홈 위젯보드 · 플래너)
    └── widgets/      # SynapseOrb · concept 키트 · study board 키트 · 공용 다이얼로그 등
└── assets/
    ├── fonts/        # Pretendard
    └── lottie/       # Lottie 애니메이션(추후 추가)
```

---

## 시작하기

### 사전 요구

- Flutter stable SDK (Dart 포함)
- 웹 실행 시 Chrome 등 지원 타깃

```bash
flutter --version
flutter doctor
```

### 설치 & 실행

```bash
flutter pub get

# 웹 서버로 실행
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8088
# → http://127.0.0.1:8088

# 또는 Chrome
flutter run -d chrome
```

### 환경 변수 (APP_ENV)

Dio 클라이언트가 `--dart-define=APP_ENV` 값으로 base URL을 고릅니다(기본 `dev`).

| APP_ENV | Base URL |
|---|---|
| `dev` (기본) | `http://localhost:8080` |
| `platform-dev` | `http://localhost:8081` |
| `staging` | `https://api-staging.synapse.app` |
| `prod` | `https://api.synapse.app` |

```bash
flutter run -d chrome --dart-define=APP_ENV=dev
```

---

## 검증

```bash
flutter analyze        # 경고 0 유지
flutter test           # 단위·위젯 테스트
flutter build web --release
```

---

## 디자인 프리뷰 (GitHub Pages)

디자인 시안/통합본은 정적 갤러리로 배포됩니다.

- 갤러리: <https://maoemong.github.io/synapse-design-preview/>
- 통합본(현재 메인): `.../tutor-integrated/`
- **컬러 팔레트 선택기**: `.../palette.html` — Primary/Accent/Due 등 토큰 15개를 실시간으로
  바꿔 보고, 고른 색을 `AppColors` Dart 코드로 내보낼 수 있습니다(팀 색상 결정용).

> 빌드 후 산출물을 `tutor-integrated/`에 복사해 배포합니다. 캐시 때문에 확인 시
> 강력 새로고침(Ctrl+Shift+R)을 권장합니다.

---

## 개발 컨벤션

- **린트**: `flutter analyze` 경고 0 유지.
- **타입**: 명시적 타입 선언. `dynamic`은 불가피할 때만.
- **상태 관리**: Riverpod manual providers(codegen 미사용) — `Provider(...)` / `NotifierProvider(...)` 직접 작성.
- **디자인 토큰**: 색·간격·라운드는 항상 `AppColors`/`AppSpacing`/`AppRadius` 경유(hex 하드코딩 금지).
- **주석**: WHY가 불명확할 때만. 미구현은 `// TODO: 팀원 구현 —` 형식으로 표시.
- **브랜치**: `dev`에 직접 커밋 금지. `dev`를 pull 후 `feat/<기능명>` 브랜치에서 작업.

---

## 현재 상태 / 한계

- 화면·내비게이션·디자인 토큰·반응형(웹/모바일)·주요 UX 흐름 구현 완료.
- 데이터는 **mock**, 인증은 **개발용 바이패스**로 동작.
- 실제 API/비즈니스 로직 연동은 각 feature의 `// TODO: 팀원 구현` 지점에서 담당자가 진행.
