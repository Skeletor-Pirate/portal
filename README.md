# 🏫 Academic Architect — School ERP Platform

A **production-grade, multi-tenant School ERP Flutter application** with role-based dashboards for:

**Global Admin • School Admin • Teacher • Student • Parent • Accountant**

Now upgraded with **Unified Authentication, REST API layer, JWT session handling, pagination, and improved responsive UI (v4).**

---

# 🚀 Quick Start

```bash
# 1. Install dependencies
flutter pub get

# 2. Run in debug mode (connected device or emulator)
flutter run

# 3. Build release APK
flutter build apk --release

# 4. Build release App Bundle (Play Store)
flutter build appbundle --release

# 5. Build for iOS
flutter build ios --release
```

---

# 🆕 Version 4 — Platform Upgrade

## 🔐 Unified Authentication

The app now includes a **production-ready authentication flow**.

### Features
- Single screen **Sign In / Create Account toggle**
- Role-aware registration mapped to backend `user_type`
- Real-time validation for:
  - Network failures  
  - Server credential errors
- **DEV login shortcut** for UI testing without backend

File:
```
lib/screens/login_screen.dart
```

---

## 🔌 API Service Layer

Location:
```
lib/services/api_service.dart
```

### Capabilities

| Feature | Description |
|---|---|
| JWT TokenStore | Access + Refresh token storage |
| Silent Re-Authentication | Auto refresh on 401 |
| REST Client | GET / POST / PUT / PATCH unified |
| Global Headers | Authorization + JSON |
| Strong Models | StudentProfile / TeacherProfile / ParentProfile |
| Pagination | Built-in support |

Developer bypass:
```
lib/services/dev_auth.dart
```

---

## 🛠️ Responsive UI Fixes

| Issue | Fix |
|---|---|
| Bottom overflow on stat cards | Fixed |
| childAspectRatio | Updated → **1.15** |
| Large stat text overflow | FittedBox added |
| Label clipping | Multi-line enabled |
| Card layout stability | Spacer alignment fix |

---

## 🎨 Model Enhancements

Added:
- `UserRoleExtension`
- Enum ⇄ API ⇄ UI conversion helpers
- `kRoles` remains single source of truth

---

# 📁 Updated Project Structure

```
academic_architect/
├── lib/
│   ├── main.dart
│   ├── theme.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   └── dev_auth.dart
│   ├── models/
│   │   └── role_config.dart
│   ├── widgets/
│   │   ├── builders.dart
│   │   └── nav_icons.dart
│   └── screens/
│       ├── login_screen.dart
│       ├── app_screen.dart
│       ├── page_router.dart
│       ├── global/
│       ├── admin/
│       ├── teacher/
│       ├── student/
│       ├── parent/
│       ├── accountant/
│       └── common/
```

---

# 📄 File-by-File Functionality

## lib/main.dart
App entry point. Sets up MaterialApp, theme, portrait lock, routes to LoginScreen.

## lib/theme.dart
Global colors, radius constants, shadows, and AppTheme.dark.

## lib/models/role_config.dart
UserRole enum, navigation config, role branding, conversion helpers.

## lib/widgets/nav_icons.dart
Maps navigation keys → Flutter Material Icons.

## lib/widgets/builders.dart
Reusable UI toolkit used across dashboards:
- Stat cards & quick action grids  
- Timelines & timetable rows  
- Assignment cards & grade bars  
- Finance banner & invoice rows  
- Attendance calendar grid  
- Profile widgets & settings toggles  
- Form builders & buttons  
- Mini tables & system health rows  

---

# 👥 Role Dashboards Overview

### 🌐 Global Admin
Schools • Domains • System Config • Analytics • Health Monitoring

### 🏫 School Admin
Students • Teachers • Parents • Roles • Academic • Grading

### 👩‍🏫 Teacher
Attendance • Assignments • Exams • Timetable • Analytics • Materials

### 🎓 Student
Subjects • Assignments • Grades • Attendance • Timetable • Materials

### 👨‍👩‍👧 Parent
Child Insights • Payments • Attendance • Messages • AI Insights

### 💰 Accountant
Invoices • Fee Structure • Reconciliation • Reports • Authorization

---

# 🎨 Design System

| Token | Value |
|---|---|
| Primary | Indigo `#2D1B8E` → Violet `#4C35C2` |
| Accent | Blue `#4361EE` |
| Background | Soft Lavender `#F4F3FF` |
| Surface | White |
| Border | `#DDD8FF` |
| Success | Green |
| Warning | Amber |
| Error | Red |
| Fonts | DM Serif Display + Plus Jakarta Sans |

---

# 🔧 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  google_fonts: ^6.1.0
```

✔ Uses Flutter Material Icons only

---

# 🐛 Bug Fix History

## v4 Fixes
| Area | Fix |
|---|---|
| Auth Flow | Login + Register unified |
| Missing Models | ParentProfile restored |
| TokenStore | hasTokens restored |
| UI Compile Errors | BoxScale → BoxFit |

## v3 Fixes
| Bug | Fix |
|---|---|
| LucideIcons removed | Replaced with Material Icons |
| Emoji icons removed | Replaced with IconData |
| Third-party icon dependency | Removed |

---

# 📱 Supported Platforms

- Android (API 21+)  
- iOS (13+)  
- Portrait orientation enforced  

---

# 🏁 Summary

Academic Architect is now:
- Production-ready authentication  
- API integrated  
- Multi-tenant ready  
- Fully responsive UI  
- Role-driven architecture  

**Ready for backend integration & deployment 🚀**