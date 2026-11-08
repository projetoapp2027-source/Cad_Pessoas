# Etapa 1: build do Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.44.0 AS build
ARG API_URL
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get
COPY . .
RUN flutter build web --release --dart-define=API_URL=${API_URL}

# Etapa 2: servir os arquivos estaticos
FROM caddy:2.8-alpine
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=build /app/build/web /srv
