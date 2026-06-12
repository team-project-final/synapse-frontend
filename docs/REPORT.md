# REPORT — synapse-frontend

작업별 코드 변경 사항·기술적 근거·이전 상태 비교 기록.

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
