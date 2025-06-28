# Multi-stage Dockerfile for Algebrini MVP - Full Cross-Platform Support
FROM ubuntu:22.04 as base

# Install system dependencies for all platforms
RUN apt-get update && apt-get install -y \
    curl unzip xz-utils zip git libglu1-mesa libgtk-3-0 libnss3 libasound2 \
    fonts-liberation libappindicator3-1 lsb-release wget ca-certificates sudo \
    openjdk-11-jdk-headless cmake ninja-build pkg-config libgtk-3-dev \
    libblkid-dev liblzma-dev libsecret-1-dev libjsoncpp-dev libfuse-dev \
    libdrm-dev libgbm-dev libx11-dev libxcomposite-dev libxdamage-dev \
    libxrandr-dev libxss-dev libxtst-dev libxext-dev libxfixes-dev \
    libxi-dev libxrender-dev libxcb1-dev libxcb-shm0-dev libxcb-render0-dev \
    libxcb-glx0-dev libxcb-keysyms1-dev libxcb-icccm4-dev libxcb-image0-dev \
    libxcb-shape0-dev libxcb-sync-dev libxcb-xfixes0-dev libxcb-randr0-dev \
    libxcb-render-util0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev \
    libxkbcommon-x11-dev libatspi2.0-dev libdbus-1-dev libevent-dev \
    libfontconfig1-dev libfreetype6-dev libharfbuzz-dev libjpeg-dev \
    libpng-dev libwebp-dev libzstd-dev

# Create non-root user
RUN useradd -m flutteruser && echo "flutteruser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Define Flutter archive and path
ARG FLUTTER_TAR=flutter_linux_3.19.6-stable.tar.xz
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"

# Extract Flutter SDK (from downloads directory)
COPY infra/downloads/${FLUTTER_TAR} /tmp/${FLUTTER_TAR}
RUN tar -xJf /tmp/${FLUTTER_TAR} -C /opt && \
    rm /tmp/${FLUTTER_TAR} && \
    git config --global --add safe.directory /opt/flutter

# Switch to flutteruser
USER flutteruser

# Pre-cache all platforms and enable web
RUN flutter precache --android --ios --web && \
    flutter config --enable-web && \
    flutter doctor

# Development stage
FROM base as development

WORKDIR /home/flutteruser/app

# Copy only pubspec files first for dependency caching (from parent directory)
COPY --chown=flutteruser:flutteruser pubspec.* ./
RUN flutter pub get

# Copy the rest of the code (from parent directory)
COPY --chown=flutteruser:flutteruser . ./

# Expose ports for web and debugging
EXPOSE 5000 8080

# Default command for development
CMD ["flutter", "run", "-d", "web-server", "--web-port=5000", "--web-hostname=0.0.0.0"]

# Testing stage
FROM development as testing

# Install testing dependencies
RUN flutter pub get

# Run all tests
CMD ["flutter", "test", "--coverage"]

# Web build stage
FROM base as web-build

WORKDIR /home/flutteruser/app

# Copy only pubspec files first (from parent directory)
COPY --chown=flutteruser:flutteruser pubspec.* ./
RUN flutter pub get

# Copy the rest of the code (from parent directory)
COPY --chown=flutteruser:flutteruser . ./

# Build web app
RUN flutter build web --release

# Production web server stage
FROM nginx:alpine as production

# Copy built web app
COPY --from=web-build /home/flutteruser/app/build/web /usr/share/nginx/html

# Copy custom nginx config for SPA routing
COPY infra/docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# Android build stage
FROM base as android-build

WORKDIR /home/flutteruser/app

# Copy only pubspec files first (from parent directory)
COPY --chown=flutteruser:flutteruser pubspec.* ./
RUN flutter pub get

# Copy the rest of the code (from parent directory)
COPY --chown=flutteruser:flutteruser . ./

# Build Android APK
RUN flutter build apk --release

# iOS build stage (requires macOS, but keeping structure)
FROM base as ios-build

WORKDIR /home/flutteruser/app

# Copy only pubspec files first (from parent directory)
COPY --chown=flutteruser:flutteruser pubspec.* ./
RUN flutter pub get

# Copy the rest of the code (from parent directory)
COPY --chown=flutteruser:flutteruser . ./

# Note: iOS builds require macOS and Xcode
# This stage is for structure only
CMD ["echo", "iOS builds require macOS with Xcode"]
