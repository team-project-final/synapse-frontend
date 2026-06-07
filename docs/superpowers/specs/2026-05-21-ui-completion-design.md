# Synapse Frontend UI 완성 설계서

> **작성일**: 2026-05-21
> **목적**: 06/06A 화면기능 정의서 기준, 미구현/플레이스홀더/부분구현 화면의 UI 완성
> **범위**: 비즈니스 로직 제외, 순수 UI(그림) 레벨만 — 목업 데이터 사용
> **기준 문서**: 05 화면흐름 시퀀스, 06 화면기능 정의서, 06A 관리자 화면 정의서, storyboard v2 design spec

---

## 1. 배경

현재 Synapse 프론트엔드 구현 상태:

| 상태 | 수량 | 비율 |
|------|------|------|
| 구현 완료 | 8개 | 17% |
| 부분 구현 | 27개 | 52% |
| 플레이스홀더 | 5개 | 10% |
| 미구현 | 12개 | 23% |
| **합계** | **52개** | 100% |

주요 갭: Admin 패널 (9개 미구현), Graph 시각화 (3개 플레이스홀더), 공통 컴포넌트 8개 미구현.

## 2. 범위

### In Scope
- 공통 컴포넌트 신규 8개 + 기존 보강 5개
- 미구현 화면 12개 신규 UI 구현
- 플레이스홀더 5개 → 실제 UI로 교체
- 부분 구현 27개 누락 UI 요소 보강
- Admin 전용 레이아웃(AdminShell) + Admin 화면 9개 신규
- 모든 화면은 목업(mock) 데이터 사용, `// TODO: 팀원 구현 —` 주석으로 API 연동 포인트 표시

### Out of Scope
- 백엔드 API 연동
- 실제 인증 로직
- 비즈니스 로직 (SRS 알고리즘, 결제 처리 등)
- 테스트 코드

## 3. 설계 결정

### 3.1 작업 순서 — 하이브리드 (공통 → 핵심 → Admin → 보강)

공통 컴포넌트를 먼저 만들어 이후 화면에서 재사용. P0 화면 → Admin → 세부 보강 순서.

### 3.2 데이터 전략 — 인라인 목업

각 화면 파일 내에 `_mockXxx` 형태의 정적 목업 데이터를 선언.
팀원이 추후 Provider 연동 시 목업을 제거하고 교체하는 구조.

### 3.3 Graph 시각화 — CustomPaint

D3.js 대신 Flutter CustomPaint + GestureDetector로 노드-엣지 렌더링.
줌/팬은 InteractiveViewer 위젯 활용.

### 3.4 Admin 레이아웃 — AdminShell 분리

사용자 AppShell과 별도의 AdminShell 위젯 생성.
06A 정의서 기준: 좌측 고정 사이드바(10메뉴), 상단 환경 셀렉터, 관리자 프로필 드롭다운.

---

## 4. Phase 1: 공통 컴포넌트

### 4.1 신규 컴포넌트 (8개)

위치: `lib/shared/widgets/`

| # | 컴포넌트 | 파일명 | 사용처 | 구현 내용 |
|---|---------|--------|--------|-----------|
| 1 | Toast | `toast.dart` | 전 화면 | SnackBar 래퍼, 성공(녹)/에러(적)/정보(청) 3타입, 3초 자동 dismiss |
| 2 | ConfirmDialog | `confirm_dialog.dart` | 삭제/취소 전체 | 제목+본문+취소/확인 버튼, destructive 모드(빨간 확인 버튼) |
| 3 | ReportDialog | `report_dialog.dart` | COMM-007, Admin | 신고 사유 라디오 6개 + 상세 입력 TextField + 제출/취소 |
| 4 | CommandPalette | `command_palette.dart` | AppShell (Cmd+K) | 오버레이 검색창 + 결과 리스트(아이콘+제목+경로) + 키보드 탐색(화살표+Enter) |
| 5 | OnboardingChecklist | `onboarding_checklist.dart` | DASH-001 | 3단계 체크리스트 카드(첫 노트/첫 카드/첫 복습), 접기/펴기, 완료 시 축하 |
| 6 | CelebrationParticle | `celebration_particle.dart` | CARD-006, GAME-004 | CustomPaint 파티클 오버레이 600ms, 색상 커스텀 가능 |
| 7 | AIGenerateLoading | `ai_generate_loading.dart` | CARD-004, SEARCH-002 | 스켈레톤 카드 3개 shimmer + LinearProgressIndicator + "AI 생성 중..." |
| 8 | LevelUpCelebration | `level_up_celebration.dart` | GAME-004 | CelebrationParticle 확장, 레벨 숫자 스케일 애니메이션 + Warm Amber 파티클 |

### 4.2 기존 컴포넌트 보강 (5개)

| # | 컴포넌트 | 파일 | 보강 내용 |
|---|---------|------|-----------|
| 1 | AutoSaveIndicator | 노트 에디터 내 | AnimatedOpacity 페이드 (2초 후 사라짐) |
| 2 | ReviewDifficultyBar | 복습 화면 내 | Row 바 레이아웃 + 색상 코드 (Again=빨강, Hard=주황, Good=파랑, Easy=초록) |
| 3 | WikilinkChip | 노트 에디터 내 | Tooltip 호버 미리보기 (첫 2줄 텍스트) |
| 4 | StreakFlame | 게이미피케이션 내 | AnimationController 펄스 (1.0→1.2 스케일, 반복) |
| 5 | CodeBlock | shared widgets | Container + SelectableText + Geist Mono 폰트 + 복사 IconButton |

---

## 5. Phase 2: 사용자 핵심 흐름 (10개)

### 5.1 Auth 마무리 (3개)

| # | 화면 ID | 화면명 | 현재 | 구현 UI |
|---|---------|--------|------|---------|
| 1 | SCR-W-AUTH-003 | MFA 검증 | 플레이스홀더 | TOTP 6자리 PinCodeField, 30초 카운트다운 타이머, 재발송 TextButton, 백업코드 링크 |
| 2 | SCR-W-AUTH-004 | 비밀번호 재설정 | 플레이스홀더 | Stepper 3단계 (이메일 입력 → 인증코드 → 새 비밀번호), 유효성 표시 |
| 3 | SCR-W-AUTH-005 | OAuth 동의 | 플레이스홀더 | 앱 정보 카드, 권한 목록 CheckboxListTile, 허용/거부 ElevatedButton |

### 5.2 Dashboard 신규 (2개)

| # | 화면 ID | 화면명 | 구현 UI |
|---|---------|--------|---------|
| 4 | SCR-W-DASH-002 | 학습 히트맵 | CustomPaint 격자 (52주x7일), 5단계 색상, GestureDetector 툴팁, 범례 |
| 5 | SCR-W-DASH-003 | 통계 상세 | 리텐션 곡선 LineChart, 정확도 BarChart, 일별 학습시간 LineChart, SegmentedButton 기간 필터 |

### 5.3 Graph 전체 (3개)

| # | 화면 ID | 화면명 | 구현 UI |
|---|---------|--------|---------|
| 6 | SCR-W-GRAPH-001 | 그래프 뷰 | InteractiveViewer + CustomPaint 노드-엣지, 필터 ExpansionTile (태그/날짜/연결수), 노드 탭→하단 시트(연결수/PageRank/액션 버튼), Fit 버튼 |
| 7 | SCR-W-GRAPH-002 | 노트 이웃 | 중심 노드 강조 + 2-hop 이웃, Slider 깊이 조절 |
| 8 | SCR-W-GRAPH-003 | 클러스터 뷰 | 클러스터별 색상 그룹, 좌측 클러스터 목록 패널, 클러스터 선택 시 해당 노드 강조 |

### 5.4 Community/Gamification 누락 (2개)

| # | 화면 ID | 화면명 | 구현 UI |
|---|---------|--------|---------|
| 9 | SCR-W-COMM-007 | 신고하기 모달 | ReportDialog 컴포넌트 호출 (Phase 1) |
| 10 | SCR-W-GAME-004 | 레벨업 축하 모달 | Dialog + LevelUpCelebration 배경 + 이전→새 레벨 Row + 보상 카드 + 확인 버튼 |

---

## 6. Phase 3: Admin 전체 (11개)

### 6.1 AdminShell 공통 레이아웃

위치: `lib/shared/widgets/admin_shell.dart`

구성:
- 좌측 고정 사이드바 (240px): 대시보드/테넌트/사용자/감사로그/신고/콘텐츠/그룹/게임화/데이터요청/설정
- 상단 AppBar: 환경 셀렉터 DropdownButton(dev/staging/prod), 관리자 프로필 PopupMenuButton
- 콘텐츠 영역: child 라우팅

### 6.2 공통 패턴: AdminDataGrid

위치: `lib/shared/widgets/admin_data_grid.dart`

재사용 데이터 그리드: 검색 TextField + 다중 필터 Chip + DataTable + 커서 페이지네이션.
Admin 화면 대부분이 이 패턴 사용.

### 6.3 Admin 화면 (10개)

| # | 화면 ID | 화면명 | 구현 UI |
|---|---------|--------|---------|
| 1 | SCR-A-ADMIN-001 | 관리자 대시보드 (보강) | KPI 4카드(DAU/MAU/MRR/신규), 사용량 게이지 3개(AI토큰/스토리지/Kafka), 처리대기 요약(신고/GDPR/할당량), 최근 활동 리스트 |
| 2 | SCR-A-ADMIN-002 | 테넌트 관리 | AdminDataGrid(플랜/상태 필터), 상세 사이드시트(사용량 차트+멤버수), 상태변경 ConfirmDialog |
| 3 | SCR-A-ADMIN-003 | 사용자 관리 | AdminDataGrid(역할/상태 필터), 상세 사이드시트(활동 타임라인), 정지/삭제/MFA해제 모달 |
| 4 | SCR-A-ADMIN-004 | 감사 로그 | AdminDataGrid(날짜범위+액터+액션 필터), 행 확장→JSON 상세, CSV 내보내기 버튼 |
| 5 | SCR-A-ADMIN-005 | 시스템 설정 | 탭 3개(플랜 쿼터 편집 테이블 / 기능 플래그 SwitchListTile / Rate Limit TextFormField), 저장 버튼 |
| 6 | SCR-A-ADMIN-006 | 신고 관리 | 상태 탭(대기/처리중/완료/기각), AdminDataGrid, 상세 패널(신고자/대상/사유/증거), 처리 버튼 4개 |
| 7 | SCR-A-ADMIN-007 | 콘텐츠 모더레이션 | 탭(공유 덱/공유 노트), AdminDataGrid, 상태 DropdownButton, 체크박스 벌크 선택+일괄처리 버튼 |
| 8 | SCR-A-ADMIN-008 | 스터디 그룹 관리 | AdminDataGrid(상태 필터), 상세 사이드시트(멤버 목록/활동), 정지/활성화/강제해체 모달 |
| 9 | SCR-A-ADMIN-009 | 게이미피케이션 관리 | 탭 4개(통계 카드 / 배지 CRUD GridView / 레벨 편집 DataTable / XP 설정 폼) |
| 10 | SCR-A-ADMIN-010 | 데이터 요청 관리 | 상태 탭(대기/처리중/완료/거부), AdminDataGrid, 상세 패널(보유데이터 요약/실행로그/30일 카운트다운), 내보내기실행/삭제승인/거부 버튼 |

---

## 7. Phase 4: 부분 구현 보강 (27개)

### 7.1 Dashboard

| 화면 | 보강 UI |
|------|---------|
| DASH-001 | 히트맵 위젯 삽입, OnboardingChecklist 삽입, 주간/월간 SegmentedButton, StreakFlame 위젯 |

### 7.2 Note (4개)

| 화면 | 보강 UI |
|------|---------|
| NOTE-001 | 폴더 TreeView 사이드 패널, SortBy DropdownButton |
| NOTE-003 | 백링크 패널(링크 카운트+미리보기 카드), 참조 노트 패널 |
| NOTE-004 | Diff 뷰 (좌우 분할, RichText 추가=녹/삭제=적 하이라이트) |
| NOTE-005 | 태그 색상 ColorPicker, 태그 병합 다이얼로그 |

### 7.3 Card (5개)

| 화면 | 보강 UI |
|------|---------|
| CARD-001 | 서브덱 ExpansionTile, CircularProgressIndicator 진행도, ReorderableListView |
| CARD-002 | 타입 FilterChip(Basic/Cloze), Checkbox 벌크 선택+삭제 버튼 |
| CARD-003 | Cloze 편집 ({{c1::}} RichText 하이라이트), 이미지 첨부 Container |
| CARD-004 | AIGenerateLoading 삽입, 결과 GridView(체크박스 선택)+일괄저장 |
| CARD-006 | 정확도 도넛 PieChart, 난이도 분포 BarChart, 다음 복습 예정 리스트 |

### 7.4 Search (2개)

| 화면 | 보강 UI |
|------|---------|
| SEARCH-001 | 검색어 TextSpan 하이라이팅, 카테고리 TabBar, 결과 카운트 Badge |
| SEARCH-002 | AnimatedTextKit 스트리밍 효과, 인용 소스 ActionChip, 피드백 IconButton(thumbs) |

### 7.5 Billing (1개)

| 화면 | 보강 UI |
|------|---------|
| BILLING-003 | DataTable(날짜/금액/상태/PDF IconButton), EmptyState→Free 플랜 안내 |

### 7.6 Settings (5개)

| 화면 | 보강 UI |
|------|---------|
| SETTINGS-001 | 아바타 Stack(CircleAvatar + 카메라 IconButton), 언어 DropdownButton |
| SETTINGS-002 | MFA 섹션(QR Container placeholder + 백업코드 Wrap), 비밀번호 변경 폼, OAuth 계정 ListTile |
| SETTINGS-003 | 카테고리별 3열 토글 GridView(Push/Email/InApp), 방해금지 시간 RangeSlider |
| SETTINGS-004 | 내보내기 3버튼(Markdown/PDF/전체), LinearProgressIndicator, 계정 삭제 ConfirmDialog 연동 |
| SETTINGS-005 | 멤버 초대 AlertDialog(이메일+역할 DropdownButton), 역할 변경 PopupMenuButton, 멤버 제거 |

### 7.7 Community (6개)

| 화면 | 보강 UI |
|------|---------|
| COMM-001 | 마지막 활동 timeago 텍스트, 멤버 아바타 Stack (최대 3개+숫자) |
| COMM-002 | 멤버 ListTile(역할 Chip), 활동 로그 Timeline, 초대/강퇴 버튼 |
| COMM-003 | 가입 방식 RadioListTile(공개/승인/초대), 태그 InputChip |
| COMM-004 | 평점 Row(Icon star), 다운로드 수 Text, 카테고리+난이도 FilterChip |
| COMM-005 | 카드 미리보기 PageView 캐러셀, 복사+Toast, 별점 GestureDetector, 신고 TextButton |
| COMM-006 | 공유 노트 Card(작성자/태그/미리보기 2줄), DropdownButton 필터 |

### 7.8 Gamification (2개)

| 화면 | 보강 UI |
|------|---------|
| GAME-001 | 배지 탭→showModalBottomSheet(조건+획득일), 이번 주 통계 Row(복습수/노트수/XP) |
| GAME-002 | ChoiceChip 필터(전체/획득/미획득), 배지 탭→BottomSheet(조건+LinearProgressIndicator) |

### 7.9 Notification (2개)

| 화면 | 보강 UI |
|------|---------|
| NOTI-001 | TabBar 카테고리(전체/복습/커뮤니티/성취), 날짜 그룹 헤더 Text, "모두 읽음" TextButton |
| NOTI-002 | 카테고리별 3열 토글 GridView, 방해금지 showTimePicker 연동 |

---

## 8. 총 작업 단위

| Phase | 내용 | 수량 |
|-------|------|------|
| Phase 1 | 공통 컴포넌트 | 13개 (신규 8 + 보강 5) |
| Phase 2 | 핵심 누락 화면 | 10개 |
| Phase 3 | Admin (Shell + DataGrid + 화면) | 12개 (공통 2 + 화면 10) |
| Phase 4 | 부분 구현 보강 | 27개 |
| **합계** | | **62개** |

---

## 변경 이력

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|-----------|
| v1.0 | 2026-05-21 | Synapse Team | UI 완성 설계서 초안 |
