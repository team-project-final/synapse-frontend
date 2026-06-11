# REPORT — synapse-frontend

작업별 코드 변경 사항·기술적 근거·이전 상태 비교 기록.

---

## 2026-06-11 — (main) 배포 모델 semver 통일 (이슈 #52)

### 배경 / 이전 상태
- frontend가 EKS dev/staging에서 **ImagePullBackOff** (2026-06-11 라이브 윈도우). ECR `synapse/frontend` 이미지 0개.
- main엔 이미 컨테이너 인프라가 있었음(#21 Dockerfile, #22 deploy.yml). 그러나 **태그 전략 불일치**가 근본 원인:
  - main `deploy.yml`은 shared `deploy-service.yml`(SHA 모델) caller → `synapse/frontend:<SHA>`·`:dev-latest` push.
  - gitops `apps/frontend` dev 오버레이는 `newTag: 1.0.0`(semver, image-updater) 핀 (과거 SHA `e4532fee…`에서 변경).
  - **아무도 `1.0.0` 이미지를 만들지 않아** 클러스터가 이미지를 못 당김.

### 변경 사항
| 파일 | 내용 |
|------|------|
| `.github/workflows/deploy.yml` | shared `deploy-service.yml` caller(SHA) → **semver 자체-deploy**로 교체. semver tag(`*.*.*`)/`workflow_dispatch` → ECR `synapse/frontend:<semver>` build & push |
| `Dockerfile` | **변경 없음** — main 기존본 유지(멀티스테이지 + `--dart-define=API_BASE_URL/APP_ENV` 동일 오리진, nginx-unprivileged 8080) |
| `nginx.conf` | **변경 없음** |

### 기술적 근거
- **semver 모델로 통일(2026-06-11 결정)**: gitops 오버레이가 semver/image-updater 전제이므로 deploy.yml도 semver 태그 배포로 맞춤(engagement-svc 패턴과 동일). shared SHA caller는 dev 오버레이를 SHA로 git-push해 image-updater와 충돌하므로 제거.
- **전체 dev→main 머지 안 함**: main의 #24 승인 디자인 "배포본"(#30 복원)을 보존하기 위해 인프라(deploy.yml)만 정합. dev의 중복 Dockerfile/`nginx/default.conf`(#54)는 채택하지 않음.
- 액션 버전 `configure-aws-credentials@v6`·`amazon-ecr-login@v2`(shared/engagement 정합).

### 검증(DoD) — 머지/배포 후
- [ ] `AWS_ROLE_ARN` 시크릿 존재 확인 → `gh workflow run deploy.yml -f image_tag=1.0.0`
- [ ] `aws ecr describe-images --repository-name synapse/frontend --image-ids imageTag=1.0.0` 존재
- [ ] EKS frontend Running (ImagePullBackOff 해소)

### 후속(별도)
- dev 브랜치의 중복 인프라(#54의 `Dockerfile`·`nginx/default.conf`·semver `deploy.yml`)를 main 정본과 일치시켜 재발산 방지 필요.
