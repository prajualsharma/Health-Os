# syntax=docker/dockerfile:1

# --- Build stage: compile the Flutter web bundle ---
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# API_URL is left empty so the app calls the backend same-origin (the nginx
# container reverse-proxies /auth, /me, /admin, ... to the api-gateway).
# USE_MOCK=false switches the app from canned data to the real API.
ARG API_URL=""
ARG USE_MOCK=false

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release \
    --dart-define=API_URL=${API_URL} \
    --dart-define=USE_MOCK=${USE_MOCK}

# --- Runtime stage: serve static bundle + proxy API ---
FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
