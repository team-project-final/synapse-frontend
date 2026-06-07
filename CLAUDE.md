# 프로젝트 지침: synapse-frontend

## 워크플로우 및 컨벤션

- **초안 검토 필수:** 모든 코드 수정 작업을 수행하기 전에, 변경될 코드의 초안(Draft)을 반드시 사용자에게 보여주고 승인을 받아야 합니다. 규모가 큰 변경의 경우 `/plan` 모드를 활용하세요.
- **작업 설명:** 모든 작업(구현, 수정 등)을 완료한 후에는 수행한 내용을 사용자가 쉽게 이해할 수 있도록 반드시 **한국어**로 상세히 설명합니다.
- **진행 상황 기록:** 주요 구현 단계나 아키텍처 변경을 완료한 후, 반드시 Claude의 메모리 시스템(`C:\Users\G\.claude\projects\D--workspace-synapse-synapse-frontend\memory\`)의 `MEMORY.md`를 업데이트하여 현재 상태, 완료된 작업 및 다음 단계를 기록합니다.
- **보고서 작성:** 각 단계가 완료될 때마다 `docs/REPORT.md`를 업데이트하여 구체적인 코드 변경 사항, 기술적 근거, 이전 상태와의 비교 내용을 상세히 기록합니다. 모든 기록에는 반드시 작업 일자(`YYYY-MM-DD`)를 포함합니다.
- **문서 동기화 필수:** 모든 작업(구현, 수정, 리팩토링 등)이 완료된 후에는 반드시 `docs/project-management/` 폴더 내의 `HISTORY`, `TASK`, `WORKFLOW` 문서들을 현재 상태에 맞게 갱신합니다.
- **브랜치 전략:** 작업 시작 전 반드시 `dev` 브랜치를 remote에서 pull하고, `feat/<기능명>` 브랜치를 따서 작업합니다. `dev`에 직접 커밋하지 않습니다.

## 코딩 스타일

- **Linting:** `flutter analyze` 기준 경고 0개를 유지합니다.
- **타입:** 명시적 타입 선언을 사용하며, `dynamic`은 불가피한 경우에만 사용합니다.
- **상태 관리:** Riverpod manual providers (codegen 사용 안 함). 모든 Provider는 직접 `Provider(...)` / `NotifierProvider(...)` 작성.
- **비동기:** I/O 바운드 작업에는 `async`/`await`를 사용합니다.
- **주석:** 코드의 WHY가 명확하지 않을 때만 주석을 추가합니다. `// TODO: 팀원 구현 —` 형식으로 미구현 항목을 표시합니다.

## 프로젝트 구조

- `lib/core/` — 공통 상수, 라우터, 네트워크, 테마
- `lib/services/<boundary>/features/<feature>/` — 서비스 경계별 feature 디렉토리
  - `data/` — Repository 구현, DTO, DataSource
  - `domain/` — Entity, UseCase, Repository 인터페이스(Port)
  - `presentation/screens/` — UI 화면
  - `providers/` — Riverpod Provider 등록
- `lib/shared/` — 여러 boundary에서 공통 사용하는 위젯 및 feature
- `test/` — 단위 테스트 및 위젯 테스트

## 설계 원칙 (03-D Port/Adapter)

- Screen / Widget이 Dio 직접 호출 금지 → 항상 Repository(Port) 경유
- DTO를 Widget까지 전달 금지 → Entity로 변환 후 전달
- Repository 인터페이스가 `dio` import 금지 → 도메인은 HTTP 라이브러리 무지
- Provider 안에 비즈니스 로직 금지 → UseCase로 추출
