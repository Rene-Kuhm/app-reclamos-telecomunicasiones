# Quick Start Guide - Get Running in 5 Minutes

## Prerequisites Check

- [ ] Flutter installed (`flutter --version`)
- [ ] Android Studio or Xcode installed
- [ ] Backend running at `http://localhost:3000`

## Steps

### 1. Install Dependencies (1 minute)

```bash
cd "D:\aplicacion de reclamos telecomunicasiones rene\app-movil"
flutter pub get
```

### 2. Generate Code (1 minute)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Wait for "Succeeded" message.

### 3. Configure Backend URL (30 seconds)

Open `lib/core/config/app_config.dart`:

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
```

**For iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:3000/api/v1';
```

**For Physical Device:**
```dart
static const String baseUrl = 'http://YOUR_LOCAL_IP:3000/api/v1';
```

### 4. Start Backend (if not running)

```bash
cd "D:\aplicacion de reclamos telecomunicasiones rene\backend"
npm start
```

Verify it's running at http://localhost:3000

### 5. Run the App (1 minute)

```bash
cd "D:\aplicacion de reclamos telecomunicasiones rene\app-movil"
flutter run
```

Select your device when prompted.

## What to Expect

1. App launches to login screen
2. Blue theme with "Reclamos Telco" branding
3. Email and password fields
4. "Iniciar Sesión" button

## Test Login

Use credentials from your backend or register a new user.

### Expected Flow

1. Enter email and password
2. Tap "Iniciar Sesión"
3. See loading indicator
4. On success → Navigate to home screen (placeholder)
5. On error → Red snackbar with error message

## Common Issues

### "Flutter command not found"

Add Flutter to PATH:
```bash
# Windows
set PATH=%PATH%;C:\src\flutter\bin

# macOS/Linux
export PATH="$PATH:[PATH_TO_FLUTTER]/flutter/bin"
```

### "Unable to connect to backend"

1. Verify backend is running: http://localhost:3000
2. Check `baseUrl` in `app_config.dart`
3. Use `10.0.2.2` for Android Emulator
4. Check firewall settings

### "Build failed" errors

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Code generation errors

Ensure these packages are in `pubspec.yaml`:
- freezed
- json_serializable
- build_runner

Run:
```bash
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Project Structure Overview

```
app-movil/
├── lib/
│   ├── main.dart              ← Entry point
│   ├── core/                  ← Infrastructure
│   │   ├── config/            ← Configuration
│   │   ├── network/           ← HTTP client
│   │   ├── storage/           ← Data storage
│   │   └── utils/             ← Utilities
│   └── features/              ← Features
│       ├── auth/              ← Authentication ✅
│       ├── reclamos/          ← Claims ⏳
│       ├── notificaciones/    ← Notifications ⏳
│       └── perfil/            ← Profile ⏳
└── (Documentation files)
```

## Next Steps

1. **Test the login** with backend credentials
2. **Review documentation:**
   - `README.md` - Overview
   - `SETUP_GUIDE.md` - Detailed setup
   - `PROJECT_STRUCTURE.md` - Architecture
   - `IMPLEMENTATION_SUMMARY.md` - What's done

3. **Start developing:**
   - Complete register screen
   - Implement reclamos list
   - Build detail screens

## Useful Commands

```bash
# Hot reload (during development)
# Press 'r' in terminal

# Hot restart
# Press 'R' in terminal

# View logs
flutter logs

# Check for issues
flutter doctor

# Format code
flutter format lib/

# Analyze code
flutter analyze

# Build APK
flutter build apk --release
```

## Getting Help

1. Check `SETUP_GUIDE.md` troubleshooting section
2. Review Flutter docs: https://flutter.dev/docs
3. Check Riverpod docs: https://riverpod.dev
4. Search Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

## Important Files to Know

| File | What to Change |
|------|---------------|
| `lib/core/config/app_config.dart` | Backend URL, API keys |
| `lib/core/config/theme.dart` | Colors, styling |
| `lib/core/network/api_endpoints.dart` | API endpoints |
| `pubspec.yaml` | Dependencies |

## Development Workflow

1. Make changes to `.dart` files
2. Save file
3. Hot reload (press 'r')
4. If adding dependencies: `flutter pub get`
5. If modifying models: run `build_runner`

## Features Status

| Feature | Status | Priority |
|---------|--------|----------|
| Login | ✅ Working | - |
| Register | ⏳ UI needed | High |
| Reclamos List | ⏳ To implement | High |
| Reclamo Detail | ⏳ To implement | High |
| Create Reclamo | ⏳ To implement | High |
| Notificaciones | ⏳ To implement | Medium |
| Perfil | ⏳ To implement | Medium |

## Support

For detailed information, see:
- `IMPLEMENTATION_SUMMARY.md` - Complete overview
- `FILES_CREATED.md` - All files and stats
- `PROJECT_STRUCTURE.md` - Architecture details

---

**Ready to code!** 🚀

Start with: `flutter run` and begin implementing features.
