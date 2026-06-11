# REPORT — synapse-frontend

작업별 코드 변경 사항·기술적 근거·이전 상태 비교 기록.

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
