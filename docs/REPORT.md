# REPORT — synapse-frontend

작업별 코드 변경 사항·기술적 근거·이전 상태 비교 기록.

---

## 2026-06-15 — Knowledge 노트 에디터 생성/수정 API 연동 (2단계)

### 배경 / 이전 상태
- 1단계로 목록·상세(읽기)를 연동했으나, 에디터(`note_editor_screen`)는 저장 버튼이 목(TODO)이었고 수정 진입 시 기존 내용을 불러오지 않았으며 **제목 입력칸 자체가 없었다**(백엔드 `title` 필수).

### 변경 사항
| 파일 | 내용 |
|------|------|
| `data/datasources/knowledge_notes_remote_datasource.dart` | `createNote`(POST `/api/v1/notes`), `updateNote`(PATCH `/api/v1/notes/{id}`) 추가. tenantId 는 앱 기본 테넌트 상수 사용 |
| `domain/repositories/knowledge_notes_repository.dart` / `data/.../repository_impl.dart` | `createNote`/`updateNote` 추가 |
| `domain/usecases/create_note_usecase.dart`, `update_note_usecase.dart` (신규) | UseCase |
| `providers/notes_providers.dart` | `createNoteUseCaseProvider`, `updateNoteUseCaseProvider` 추가 |
| `presentation/.../note_editor_screen.dart` | **제목 입력칸 추가**, 수정 진입 시 기존 노트 로드(로딩/실패 처리), 저장 버튼 연결(신규 POST/기존 PATCH, 저장 중 스피너, 실패 SnackBar, 성공 시 상세 이동 + 목록 캐시 무효화), 태그 보존(수정 시 기존 태그 재전송) |
| `presentation/.../note_editor_screen.dart` (버그픽스) | 툴바 포맷 버튼이 선택 영역을 **치환**해 단어가 사라지던 버그 수정(`_insertMarkdown`→`_wrapSelection`). 이제 "안녕" 선택 후 볼드 → `**안녕**`. 선택 없으면 placeholder 삽입 후 선택 |
| `test/.../note_screens_render_test.dart` | 에디터 자동완성 테스트를 신규(`new`) 진입 + 본문칸 입력으로 갱신(제목칸 추가·수정모드 로드 반영) |

### 연동 API
- `POST /api/v1/notes` (생성), `PATCH /api/v1/notes/{id}` (수정)

### tenantId 처리
- 백엔드 `NoteCreateRequest` 는 tenantId 필수. 프론트는 tenant 컨텍스트가 없어 앱 기본 테넌트(`0000…0001`) 사용. 수정 시 백엔드는 이 값을 무시하고 원본 tenant 유지(데이터소스 주석 명시).

### 범위 밖 (다음 단계)
- 백링크/아웃링크(3), 버전 이력(4), 태그 편집 UI·목록 필터/정렬·위키링크 자동완성 실검색·본문 위키링크 탭(5). 위키링크 자동완성은 현재 **목 후보**.

### 검증
- `flutter analyze` (notes feature) 경고 0개.
- 위젯 테스트 `note_screens_render_test.dart` 12/12 통과.
- 인메모리 가짜 레포로 목록·상세·생성·수정·볼드픽스 **육안 확인 완료**(확인 후 가짜 코드 제거).
- 실제 저장(서버 반영) 검증은 미실시 — gateway/경로 정합([#68](https://github.com/team-project-final/synapse-frontend/issues/68)) + knowledge-svc 기동 필요.

---

## 2026-06-12 — Knowledge 노트 목록·상세 API 연동 (1단계)

### 배경 / 이전 상태
- `notes` feature 화면(목록·상세·에디터·버전·태그)은 존재하나 `data/domain/providers` 가 비어 있고 `_mock.dart` 의 가짜 노트로만 동작 (`// TODO: 팀원 구현` 마커).
- `search` feature 는 이미 Clean Architecture + Port/Adapter 로 완성되어 있어 이를 참고 패턴으로 사용.

### 변경 사항 (1단계: 목록 + 상세, 읽기 경로)
| 파일 | 내용 |
|------|------|
| `notes/domain/entities/note.dart` (신규) | Note 엔티티 (백엔드 NoteResponse 대응) |
| `notes/domain/repositories/knowledge_notes_repository.dart` (신규) | Port 인터페이스 (getNotes/getNote) |
| `notes/domain/usecases/get_notes_usecase.dart`, `get_note_usecase.dart` (신규) | UseCase |
| `notes/data/models/note_model.dart` (신규) | NoteResponse JSON → Entity 변환 |
| `notes/data/datasources/knowledge_notes_remote_datasource.dart` (신규) | Dio 호출. 목록은 `ApiResponse.data.content`(Spring Page) 언랩 |
| `notes/data/repositories/knowledge_notes_repository_impl.dart` (신규) | Repository 구현 |
| `notes/providers/notes_providers.dart` (신규) | `notesListProvider`, `noteDetailProvider`(family) + ds/repo/usecase provider |
| `note_screens.dart` | `_mock.dart` part 제거, Note/providers import 추가 |
| `note_list_screen.dart` | `_mockNotes` → `notesListProvider` 연결. `_NoteCard`가 Note 사용(스니펫←contentPlain, 시간←updatedAt). 로딩/빈목록/에러+재시도 처리 |
| `note_detail_screen.dart` | 하드코딩 제목·태그·본문 → `noteDetailProvider(noteId)` 연결. 본문은 `contentMd` 마크다운 렌더. 로딩/에러 처리. (인라인 위키링크 `_WikiBody`/`_Span` 제거 → 5단계로 분리) |
| `note_screens/_mock.dart` (삭제) | 목 데이터 제거 |
| `test/.../note_screens_render_test.dart` | 옛 목 동작(인라인 위키링크 `[[…]]`, "백링크 4") 검증 테스트를 provider override 기반 실데이터 렌더 검증으로 교체 |

### 연동 API
- `GET /api/v1/notes` (목록), `GET /api/v1/notes/{id}` (상세)

### 설계 원칙 준수
- Screen → Repository(Port) 경유, Dio 직접 호출 없음 / DTO(NoteModel) → Entity(Note) 변환 후 전달 / Provider 안 비즈니스 로직 없음(UseCase)

### 범위 밖 (다음 단계)
- 에디터 생성/수정(2단계), 백링크/아웃링크(3단계), 버전 이력(4단계), 태그 관리·목록 필터/정렬·위키링크 탭(5단계) — 해당 영역은 기존 목 + `// TODO` 유지.

### 검증
- `flutter analyze` (notes feature + 테스트) 경고 0개.
- 위젯 테스트 `note_screens_render_test.dart` 12/12 통과 (목록·상세 로딩/에러 상태 포함).
- **라이브 데이터 확인은 미실시** — knowledge-svc + 인증이 떠 있어야 가능. 현재는 정적 검증(analyze·widget test)까지.

---

## 2026-06-11 — dev 배포 인프라를 main 정본에 정합 (재발산 방지)

### 배경
- 아래 #54로 dev에 추가한 인프라가 main 기존 인프라(#21 Dockerfile, #22 deploy.yml)와 **평행하게 발산**해 있었음. main은 PR #55로 deploy.yml을 semver 자체-deploy로 통일.
- dev→main 재충돌을 막기 위해 dev 인프라를 main 정본과 **1:1 일치**시킴.

### 변경 사항
| 파일 | 내용 |
|------|------|
| `Dockerfile` | main 정본으로 교체 — `--dart-define=API_BASE_URL/APP_ENV`(동일 오리진), `--chown=nginx:nginx`, 루트 `nginx.conf` 참조 |
| `nginx.conf` (신규, 루트) | main 정본. 기존 `nginx/default.conf`(하위폴더)는 **삭제** |
| `.github/workflows/deploy.yml` | main #55 정본(semver 통일 주석 반영)과 동일화 |
| `.dockerignore` | main 정본으로 정합 |

### 근거
- 배포 모델은 **semver로 통일**(2026-06-11 결정) — gitops `apps/frontend` 1.0.0 semver 핀과 정합. shared SHA caller 미사용.
- main의 Dockerfile이 dart-define 동일오리진 빌드를 지원해 더 우수 → 이를 정본으로 채택, dev의 단순본은 폐기.

---

## 2026-06-11 — 컨테이너 이미지 파이프라인 신설 (이슈 #52)

### 배경 / 이전 상태
- frontend가 EKS dev/staging에서 **ImagePullBackOff** (2026-06-11 라이브 윈도우). ECR `synapse/frontend` 레포는 존재하나 **이미지 0개**.
- 근본 원인: frontend 레포에 **컨테이너 이미지 빌드/배포 파이프라인 부재**.
  - `.github/workflows/`에 `ci-flutter.yml`(테스트/빌드)만 있고 ECR push·docker build 단계 없음.
  - **Dockerfile 부재**.
  - gitops `apps/frontend` 오버레이는 `synapse/frontend` ECR 이미지를 참조하나 **그 이미지를 만드는 주체가 없었음**.

### 변경 사항
| 파일 | 내용 |
|------|------|
| `Dockerfile` (신규) | 멀티스테이지 — `ghcr.io/cirruslabs/flutter:stable`로 `flutter build web --release` → `nginxinc/nginx-unprivileged:1.27-alpine`로 `build/web` 서빙 |
| `nginx/default.conf` (신규) | 8080 listen, `/healthz` 200 응답, Flutter web SPA `try_files` 폴백 |
| `.github/workflows/deploy.yml` (신규) | semver release tag(`*.*.*`)/`workflow_dispatch` 트리거 → ECR `synapse/frontend:<semver>` build & push |
| `.dockerignore` (신규) | `build/`·`.dart_tool/`·`.git/`·`docs/` 등 컨텍스트 제외 |

### 기술적 근거
- **nginx-unprivileged + 8080**: gitops `apps/frontend/base/deployment.yaml` 계약과 정합 — `containerPort: 8080`, `runAsUser/Group: 101`, `readOnlyRootFilesystem: true`, `/healthz` 프로브. nginx-unprivileged는 uid 101로 8080을 listen하고 pid를 `/tmp/nginx.pid`에 기록하며, deployment가 `/tmp`·`/var/cache/nginx`를 emptyDir로 제공하므로 RO 루트와 호환.
- **semver 태그 배포 모델 채택 (shared `deploy-service.yml` 미사용)**: gitops dev 오버레이가 `newTag: 1.0.0` + *"image-updater A안: semver update-strategy"*로 핀되어 있음. shared의 SHA 기반 deploy-service.yml은 dev 오버레이 `newTag`를 SHA로 git-push하므로 semver/image-updater 설정과 충돌. 따라서 engagement-svc의 (수정된) semver 배포 패턴을 템플릿으로 사용.
- **액션 버전**: `configure-aws-credentials@v6` · `amazon-ecr-login@v2`로 shared·engagement와 정합 (engagement #41에서 드러난 `amazon-ecr-login@v3` 부재 버그 회피).

### 검증(DoD) — 머지/배포 후
- [ ] `aws ecr describe-images --repository-name synapse/frontend` 이미지 존재
- [ ] EKS frontend Running (ImagePullBackOff 해소)

### 전제 조건
- frontend 레포에 `AWS_ROLE_ARN` 시크릿 필요(engagement와 동일 OIDC role).
- 첫 `1.0.0` 태그 푸시로 ECR `synapse/frontend:1.0.0` 생성 → gitops 오버레이 핀(1.0.0) 충족.

## 2026-06-12 — 대시보드 보드 위젯 구성 디바이스 영속화 (Hive)

### 배경 / 이전 상태
- 대시보드 위젯 보드는 편집(추가/제거 → '완료')이 가능했지만 구성이 `_HomeBoardSectionState`의 로컬 `setState` 리스트에만 있어 **새로고침/재방문 시 항상 디폴트로 초기화**. (`board.dart`에 `// TODO: 팀원 구현 — 보드 구성 영속화` 표시돼 있던 항목)

### 변경 사항
| 파일 | 내용 |
|------|------|
| `shared/features/dashboard/domain/board_config.dart` (신규) | `BoardConfig` 엔티티(위젯 id 순서 리스트, `defaults` 상수) + `BoardConfigRepositoryPort` |
| `shared/features/dashboard/data/hive_board_config_repository.dart` (신규) | Port의 Hive 구현 — 웹(IndexedDB)/앱(파일) 동일 코드. 스토리지 장애는 미저장과 동일 취급(대시보드 표출 차단 금지) |
| `shared/features/dashboard/providers/board_config_providers.dart` (신규) | `AsyncNotifierProvider`(manual). 시작 시 로드(없으면 defaults), add/remove 즉시 반영, `apply()`('완료')에서만 저장 |
| `home_board_section/board.dart` (수정) | `StatefulWidget` 로컬 리스트 → `ConsumerStatefulWidget` + provider 구독. 저장된 미지(未知) 위젯 id는 조용히 무시 |
| `test/shared/features/dashboard/board_config_test.dart` (신규) | 7건 — Notifier(디폴트 폴백·순서 복원·중복 add 무시·apply 시점 저장) + 위젯(저장 구성 렌더·미지 id 무시·편집→제거→완료 저장) |

### 기술적 근거
- **Hive 채택 (SQLite 대신)**: 요구사항이 "웹+앱 양쪽 디바이스 저장"인데 sqflite는 웹 미지원(웹은 wasm/worker 별도 셋업 필요). Hive는 순수 Dart라 양쪽 모두 추가 셋업 없이 동작하고, **이미 `token_store.dart`가 사용 중인 의존성이라 신규 의존성 0**. 데이터가 위젯 id 리스트 1개라 관계형 DB 불필요. Port 뒤에 격리했으므로 추후 SQLite 전환 시 data 계층만 교체.
- **id 문자열 저장**: 보드 enum(`_BoardKind`)이 라이브러리 private이므로 `enum.name` 문자열로 저장 — enum 공개 전환 없이 매핑되고, 위젯 종류가 바뀌어도 미지 id를 버리는 방식으로 마이그레이션 내성 확보.
- **저장 시점 = '완료'**: 편집 중 이탈 시 저장 안 됨(요구 UX). retry 타이머 누수 방지를 위해 테스트는 `ProviderContainer(retry: ...)` 비활성 패턴(admin 가드 테스트와 동일).

### 검증
- `flutter analyze` 0 이슈 · `flutter test` 294/294 (신규 7 포함)
- 웹 실검증: 제거→완료→IndexedDB `synapse_dashboard` 생성 확인→**새로고침+재진입 후 구성 유지** 스크린샷 확인

### (보강 2026-06-12) 로드 전 디폴트 깜빡임 제거
- 사용자 리포트: 로그인→대시보드 진입 시 디폴트 보드가 먼저 보였다가 저장 구성으로 점프. 원래 "로드 전 찰나엔 defaults"로 설계했으나 디버그 빌드에선 IndexedDB 로드가 수백 ms라 점프가 또렷 — **틀린 콘텐츠 깜빡임이 짧은 로딩보다 나쁘다**고 판단 변경.
- `board.dart`: `isLoading` 동안 `CircularProgressIndicator` 표시 → 데이터 있으면 그 구성, 없으면 defaults. (위젯 실데이터 연동 시 이 구간이 선로딩 시간 겸용 — 사용자 의견)
- **테스트 함정 발견/해결**: 실제 Hive 구현은 파일 IO라 위젯 테스트 fake async 에서 완료 안 됨 → 스피너 무한 애니메이션 → `pumpAndSettle` 타임아웃. **대시보드에 도달하는 위젯 테스트는 `boardConfigRepositoryProvider` 를 `FakeBoardConfigRepository`(공용 `test/shared/features/dashboard/board_config_fakes.dart`)로 override 필수.** 보드가 한 프레임 늦게 빌드되며 타일 dio 0ms 타이머가 마지막 pump 뒤에 생기므로 드레인 pump 도 필요.
- analyze 0 · test 295 green · 브라우저 검증 완료(저장 구성 즉시 표출, 깜빡임 없음).

## 2026-06-12 — 개발용 로그인 바이패스 제거 (팀 요청)

### 배경 / 이전 상태
- 팀원들의 프론트 작업 편의를 위해 로그인 버튼이 입력/검증 없이 인증 상태로 진입하는 바이패스가 적용돼 있었음(PR #59에 "팀 작업 마무리 시 제거 예정" 명시). 팀 작업 마무리로 제거 요청.

### 변경 사항
| 파일 | 내용 |
|------|------|
| `login_screen.dart` | 폼 검증 복구 + 실 로그인 호출. **인트로 오버레이(스크림)를 먼저 띄워 화면을 덮고 재생과 병행해 로그인** — 성공 시 라우터가 스크림 아래에서 대시보드로 전환, 재생 후 축소되며 공개(기존 UX 유지). **실패 시 `ref.listen`이 인트로를 즉시 중단**(OverlayEntry 보관 + `_dismissTransition`)하고 에러 노출 + 버튼 복구. 오버레이의 `onPlayed`(인증 트리거) 파라미터 제거 |
| `auth_notifier.dart` | `bypassLoginForDevelopment()` 삭제 |
| 테스트 | 바이패스 전제 2건 → 실 로그인 기준 4건 재작성: 빈 폼 검증 차단 / 자격증명 제출 / **실패 시 인트로 중단·에러·버튼 복구** / 앱 라우터 경유 대시보드 도달 |

### 기술적 근거
- **오버레이 선표출 + 로그인 병행**: 성공 시 인증 즉시 라우터가 로그인 화면을 unmount하므로(과거 "ref.listen이 못 따라가는" 버그 이력) 성공 후 오버레이를 띄우는 방식은 레이스가 있다. 스크림이 전환을 가려주는 현 구조를 유지하고, 실패만 외부에서 오버레이를 중단하는 쪽이 안전.
- BREAKING: 로컬 개발 시 platform-svc(8081) + 가입 계정 필요.

### 검증
- analyze: 이번 변경 파일 0건 · 관련 테스트 전부 통과(선행 실패 2건은 #60·#61 유입 — dev 순정에서도 동일)
- **브라우저 E2E (127.0.0.1:8088 ← minikube platform 8081 포워딩)**: ① 빈 폼 → 검증 차단 ② 틀린 비밀번호 → 401 → "이메일 또는 비밀번호가 올바르지 않습니다" + 인트로 중단 + 버튼 복구 ③ 올바른 자격증명(ssar 계정) → 인트로 → 대시보드, **admin 메뉴 숨김(실 ROLE_USER 토큰의 가드 동작 확인)**

## 2026-06-12 — 로그인 인트로 재생 보장 (앱 레벨 레이어 + phase 게이트)

### 배경 / 이전 상태
바이패스 제거 후 실 로그인에서 인트로가 ① 아예 안 보이거나 ② 재생 중 대시보드 전환이 스크림 너머로 비쳐 보임(사용자 리포트 2건).

### 원인
- ① 인트로가 Navigator 의 Overlay(OverlayEntry)에 꽂혀 있는데, `appRouterProvider`가 auth 를 watch 해 로그인 즉시(loading) 라우터·Navigator 가 재생성되며 인트로가 통째로 파괴. 바이패스 시절(재생 후 인증)엔 안 드러나던 구조적 문제.
- ② 인증이 재생 도중(수백 ms) 끝나 라우터가 즉시 전환 — 스크림이 86% 반투명이라 전환이 비쳐 보임.

### 변경 사항
| 파일 | 내용 |
|------|------|
| `auth/presentation/widgets/login_intro_overlay.dart` (신규) | 인트로 위젯 이동 + `loginIntroProvider`(LoginIntroState{token, phase}) + `LoginIntroLayer` |
| `app.dart` | `MaterialApp.router(builder:)` 로 **Navigator 위에 항상 떠 있는 레이어** — 라우터가 몇 번 재생성돼도 인트로 생존 |
| `app_router.dart` | redirect 게이트: `covering && authenticated` 면 로그인에 머묾(라우터 재생성이 initialLocation=대시보드에서 시작해도 강제 유지). reveal 시 전환 |
| `login_screen.dart` | OverlayEntry 수동 관리 삭제 → provider show/hide |

### 시퀀스 (바이패스 시절 UX 복원)
팝업·재생(로그인 화면 위, 인증 완료돼도 보류) → 재생 끝(reveal) → 대시보드 전환(스크림이 덮은 채) → 축소되며 공개.

### 함정 기록
- 라우터 재생성은 **initialLocation 에서 시작**하므로 redirect 게이트는 "entry route 에 있을 때"가 아니라 "어디서 평가되든" 걸어야 함.
- 위젯 테스트에서 축소(reverse) 애니메이션은 **첫 틱에서 시작 시각이 기록**되므로 pump 를 나눠야 완료됨.

### 검증
- 회귀 테스트: 재생 중 로그인 유지(전환 보류) → 재생 후 전환 → 축소 종료 후 숨김. 전체 296 green(선행 2건 제외)
- 사용자 육안 확인 완료(재생 끝 → 전환)
