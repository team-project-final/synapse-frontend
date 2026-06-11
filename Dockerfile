# syntax=docker/dockerfile:1

# --- Stage 1: Flutter web 빌드 ---
# 태그는 pubspec sdk(>=3.11.0)를 만족하는 stable 사용. 재현성 위해 후속에 버전 핀 권장.
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# 의존성 캐시 레이어 (소스 변경과 분리)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# 소스 복사 후 웹 빌드. API_BASE_URL 빈 값 = 동일 오리진 상대경로.
COPY . .
ARG API_BASE_URL=""
ARG APP_ENV="prod"
RUN flutter build web --release \
      --dart-define=API_BASE_URL=${API_BASE_URL} \
      --dart-define=APP_ENV=${APP_ENV}

# --- Stage 2: nginx 정적 서빙 (non-root) ---
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime
COPY --chown=nginx:nginx nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build --chown=nginx:nginx /app/build/web /usr/share/nginx/html
EXPOSE 8080
# 베이스 이미지 기본 entrypoint(nginx) 사용 — uid 101, listen 8080.
