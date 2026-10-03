#!/usr/bin/env bash
set -euo pipefail
FLUTTER_VERSION="3.35.5"
FLUTTER_DIR="/tmp/flutter"
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi
export PATH="$FLUTTER_DIR/bin:$PATH"
flutter config --enable-web
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=https://watchlist-backend-one.vercel.app/api/v1
