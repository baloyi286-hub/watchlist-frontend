# WatchCue Frontend

Flutter Web/PWA frontend for WatchCue.

## Run locally

```powershell
flutter pub get
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

## Production build

```powershell
flutter build web --release --dart-define=API_BASE_URL=https://YOUR-BACKEND/api/v1
```
