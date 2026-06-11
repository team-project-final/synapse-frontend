# syntax=docker/dockerfile:1

# ---- Build: Flutter web ----
# CI(ci-flutter.yml)와 동일하게 stable 채널 사용. cirruslabs 이미지는 Flutter SDK 사전설치본.
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# 의존성 레이어 캐시: pubspec만 먼저 복사해 소스 변경 시 pub get 재실행 회피
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# 소스 복사 후 web 릴리스 빌드 → build/web 생성
COPY . .
RUN flutter build web --release

# ---- Runtime: nginx-unprivileged ----
# gitops apps/frontend/base/deployment.yaml 계약과 정합:
#   - containerPort 8080 · runAsUser/Group 101 · readOnlyRootFilesystem
#   - /healthz 프로브 (startup/liveness/readiness)
# nginx-unprivileged는 uid 101로 8080을 listen하고 pid를 /tmp/nginx.pid에 쓴다
# (deployment.yaml이 /tmp·/var/cache/nginx를 emptyDir로 제공하므로 RO 루트와 호환).
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 8080
