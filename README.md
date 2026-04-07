# 🏫 Academic Architect — School ERP Platform

A production-grade, multi-tenant School ERP Flutter application with role-based dashboards for Global Admin, School Admin, Teacher, Student, Parent, and Accountant.

---

## 🚀 Quick Start

```bash
# 1. Install dependencies
flutter pub get

# 2. Run in debug mode (connected device or emulator)
flutter run

# 3. Build release APK
flutter build apk --release

# 4. Build release App Bundle (for Play Store)
flutter build appbundle --release

# 5. Build for iOS
flutter build ios --release
```

---

## 📁 Project Structure & File Functionality

```
academic_architect/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── theme.dart                         # Global colors, spacing, shadows
│   ├── models/
│   │   └── role_config.dart               # Role definitions & nav configs
│   ├── widgets/
│   │   ├── builders.dart                  # All reusable UI widgets
│   │   └── nav_icons.dart                 # Icon routing by nav key
│   └── screens/
│       ├── login_screen.dart              # Login/role selection screen
│       ├── app_screen.dart                # Shell: top bar, drawer, bottom nav
│       ├── page_router.dart               # Routes page key → correct screen
│       ├── global/
│       │   └── global_pages.dart          # Global Admin pages
│       ├── admin/
│       │   └── admin_pages.dart           # School Admin pages
│       ├── teacher/
│       │   └── teacher_pages.dart         # Teacher pages
│       ├── student/
│       │   └── student_pages.dart         # Student pages
│       ├── parent/
│       │   └── parent_pages.dart          # Parent pages
│       ├── accountant/
│       │   └── accountant_pages.dart      # Accountant pages
│       └── common/
│           └── profile_page.dart          # Shared profile page
├── assets/
│   └── avatars/                           # Role avatar images
│       ├── admin.png
│       ├── teacher.png
│       ├── student.png
│       ├── parent.png
│       └── accountant.png
└── pubspec.yaml                           # Dependencies & asset declarations
```

---

## 📄 File-by-File Functionality

### `lib/main.dart`
- App entry point. Sets up `MaterialApp` with `AppTheme`, initialises system UI overlay (transparent status bar, dark nav bar), forces portrait orientation, and routes to `LoginScreen`.

### `lib/theme.dart`
- Defines `AppColors` (entire color palette: indigo/violet primary, blue accent, teal, amber, green, red, text hierarchy).
- Defines radius constants: `rSm`, `rMd`, `rLg`, `rXl`, `rFull`.
- Defines shadow presets: `shadowSm`, `shadowLg`.
- Exposes `AppTheme.dark` — the `ThemeData` used throughout the app.

### `lib/models/role_config.dart`
- Defines the `UserRole` enum: `global`, `admin`, `teacher`, `student`, `parent`, `accountant`.
- Defines `NavItem` (bottom nav entries) and `DrawerItem` (side drawer entries).
- Defines `RoleConfig` — holds name, label, avatar asset, nav items, drawer items, and color per role.
- Exports `kRoles` map — the single source of truth for all role configurations used by `AppScreen`, `LoginScreen`, and all page builders.

### `lib/widgets/nav_icons.dart`
- Pure routing function `navIcon(String name) → IconData`.
- Maps every navigation key string (e.g. `'dashboard'`, `'exams'`, `'authorize'`) to a Material `Icons.*` constant.
- Used by `AppScreen` for both the bottom navigation bar and the side drawer.
- **All icons use Flutter's built-in `Icons.*` — no third-party icon package required.**

### `lib/widgets/builders.dart`
The core UI component library. Contains every reusable widget used across all role screens:

| Widget / Class | Purpose |
|---|---|
| `secLabel(text)` | Uppercase section label with letter-spacing |
| `pageTitle(title, subtitle)` | DM Serif Display page heading with optional subtitle |
| `appCard(child)` | Rounded bordered card with shadow |
| `StatItem` + `statGrid()` | 2-column stat card grid — uses `IconData`, color-coded icon boxes, animated delta arrows |
| `ActionItem` + `actionGrid()` | 3-column quick-action button grid — uses `IconData` |
| `listItem()` | Icon-avatar list row with badge (domains, mappings, events) |
| `appBadge(text)` | Colored pill badge (Active / Pending / Overdue etc.) |
| `ProgressBar` | Animated gradient progress bar with label + percentage |
| `ChipRow` | Horizontal scrollable filter chip row with active state |
| `searchBar()` | Styled search input with search icon |
| `timeline()` | Vertical timeline with dot connectors |
| `ttRows()` | Timetable list rows with colored left bar |
| `asgnCards()` | Assignment cards with colored side accent |
| `GradeItem` + `GradeBars` | Animated horizontal grade bars per subject |
| `finBanner()` | Finance hero banner (dark gradient, rupee amount) |
| `invRows()` | Invoice list rows with amount + status badge |
| `quickStatsBar()` | Horizontal stats bar (attendance/grade summary) |
| `ToggleRow` | Animated toggle switch row for settings |
| `fieldGroup()` + `fieldDecoration()` | Labelled form input group |
| `navyBtn()` / `outlineBtn()` / `dangerBtn()` | Three button variants |
| `miniTable()` | Compact 3-column data table |
| `sysRow()` | System health row with live/offline dot |
| `heroPortrait()` | Full-width avatar hero image with school label |
| `profileInfo()` | Name / role / ID block below hero |
| `schoolCard()` | School list row with student & teacher counts |
| `childCard()` | Parent's child summary gradient card |
| `attendanceGrid()` | Monthly attendance calendar grid |
| `authCard()` | Payment authorisation card with Approve/Reject actions |
| `examChips()` | Exam result chip grid |

### `lib/screens/login_screen.dart`
- Full-screen login UI with gradient hero background.
- Role selector: tap-to-choose role chip row (Global Admin, School Admin, Teacher, Student, Parent, Accountant).
- Animated logo and tagline.
- "Enter Platform" button navigates to `AppScreen` with the chosen role.
- No real auth in demo mode — any tap proceeds.

### `lib/screens/app_screen.dart`
- The main shell screen wrapping all role dashboards.
- **Top bar**: hamburger menu → opens animated slide-in drawer; app logo + title; notification bell → opens floating notification panel.
- **Side drawer**: role avatar + name, full navigation list with active highlight, logout/switch-role button.
- **Bottom navigation**: role-specific tabs with animated pill indicator on active tab.
- **Notification panel**: floating card with 4 sample notifications (unread highlighted).
- Manages `_currentPage` state; passes it to `PageRouter`.

### `lib/screens/page_router.dart`
- `PageRouter(role, page)` widget.
- Routes `(role, page)` pair to the correct page widget inside the matching role screen class.
- Fallback `defaultPage(page)` shows a "Coming Soon" placeholder for unimplemented pages.

### `lib/screens/global/global_pages.dart`
**Global Platform Administrator** — pages: Dashboard, Schools, Domains, System Config.

| Page | Features |
|---|---|
| Dashboard | Hero portrait, stat grid (schools online, total users, uptime SLA, avg latency), quick actions (setup school, domains, config, access, analytics, alerts), system health status rows |
| Schools | Search bar, school list with domain + student/teacher counts + status badge, "Setup New School" button |
| Domains | SSL certificate list with expiry date + validity badge, "Add Domain" button |
| System Config | Feature flag toggles (maintenance mode, auto SSL, payment gateway, email notifications, debug logging), resource usage progress bars (storage, API rate, email quota) |

### `lib/screens/admin/admin_pages.dart`
**School Administrator** — pages: Dashboard, Students, Teachers, Parents, Roles, Mapping, Academic, Grading.

| Page | Features |
|---|---|
| Dashboard | Hero portrait, stat grid (students, teachers, parents, attendance), quick actions, recent activity timeline |
| Students | Search, chip filter (All/Active/Inactive), student list with grade/status badge |
| Teachers | Teacher list with subject badge |
| Parents | Parent list with mapping status |
| Roles | Role list (Admin, Teacher, Student, Parent, Accountant) with permission count badge |
| Mapping | Parent-student relationship list |
| Academic | Academic year list with status and date range |
| Grading | Grade remark configuration list |

### `lib/screens/teacher/teacher_pages.dart`
**Teacher** — pages: Dashboard, Attendance, Assignments, Grades, Exams, Timetable, Analytics, Subjects, Materials.

| Page | Features |
|---|---|
| Dashboard | Hero portrait, quick stats bar (classes today, students, submissions, avg grade), today's timetable, pending assignments to mark |
| Attendance | Class chip selector, attendance grid (present/absent/late per student), quick-submit button |
| Assignments | Assignment cards grouped by subject with due date and submission count |
| Grades | Gradebook table with student scores and letter grade badges |
| Exams | Exam schedule chips, score entry rows per student |
| Timetable | Weekly timetable rows with room info and status |
| Analytics | Stat grid (class avg, top scorers, at-risk, attendance), subject grade bars |
| Subjects | Subject list with class and syllabus progress |
| Materials | Uploaded material list with file type and date |

### `lib/screens/student/student_pages.dart`
**Student** — pages: Dashboard, Subjects, Assignments, Grades, Attendance, Timetable, Materials.

| Page | Features |
|---|---|
| Dashboard | Hero portrait, quick stats bar (average, attendance, pending, GPA), today's timetable with status badges, due-soon assignment cards |
| Subjects | Subject list with teacher name and current grade |
| Assignments | Chip filter (All/Pending/Submitted/Late), assignment cards with status badge |
| Grades | Grade bars per subject with animated fill, exam results chips |
| Attendance | Monthly attendance calendar grid (green=present, amber=late, red=absent), attendance stats bar |
| Timetable | Full weekly timetable with time, subject, room, teacher |
| Materials | Study material list by subject with file type icon |

### `lib/screens/parent/parent_pages.dart`
**Parent** — pages: Dashboard, Child's Grades, Attendance, Assignments, Payments, AI Insights, Messages.

| Page | Features |
|---|---|
| Dashboard | Child summary gradient card (grade/attendance/pending), quick action grid, recent notices timeline |
| Child's Grades | Grade bars per subject, exam results chips |
| Attendance | Monthly attendance calendar grid, attendance stats bar |
| Assignments | Child's assignment list with submission status |
| Payments | Finance banner (total fee), invoice rows with paid/pending status, "Pay Now" button |
| AI Insights | Performance insights cards with trend indicators |
| Messages | Message thread list with teacher names and timestamps |

### `lib/screens/accountant/accountant_pages.dart`
**Accountant** — pages: Dashboard, Invoices, Fee Structure, Reconcile, Manual Pay, Authorize, Reports.

| Page | Features |
|---|---|
| Dashboard | Finance banner (total collected), stat grid (total invoices, paid, pending, overdue), quick action grid, recent transaction timeline |
| Invoices | Chip filter (All/Paid/Pending/Overdue), invoice rows with student name, amount, status badge |
| Fee Structure | Fee category list with amount and term/annual label, "Add Fee" button |
| Reconcile | Stat grid (matched/unmatched), reconciliation rows with match status |
| Manual Pay | Form: student search, amount input, payment method chips, submit button |
| Authorize | Pending payment auth cards each with Approve/Reject action buttons |
| Reports | Stat grid (collected, collection rate), monthly breakdown table, export button |

### `lib/screens/common/profile_page.dart`
- Shared profile page used by all roles.
- Displays hero portrait, name, role, ID, contact details.
- Settings toggles (notifications, dark mode, biometric).
- Logout / Switch Role button.

---

## 🎨 Design System

| Token | Value |
|---|---|
| Primary | Indigo `#2D1B8E` → Violet `#4C35C2` |
| Accent | Blue `#4361EE` |
| Background | Soft lavender `#F4F3FF` |
| Surface | White `#FFFFFF` |
| Border | `#DDD8FF` |
| Success | Green `#15803D` |
| Warning | Amber `#B45309` |
| Error | Red `#B91C1C` |
| Fonts | DM Serif Display (headings) + Plus Jakarta Sans (body) |

---

## 🔧 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0   # DM Serif Display + Plus Jakarta Sans
```

> **No third-party icon package needed** — all icons use Flutter's built-in `Icons.*` (Material Icons). This eliminates the `LucideIcons.pencilLine` / `LucideIcons.lockOpen` build errors from the previous version.

---

## 🐛 Bugs Fixed in This Version (v3)

| Bug | Fix |
|---|---|
| `LucideIcons.pencilLine` — Member not found | Replaced with `Icons.edit_rounded` |
| `LucideIcons.lockOpen` — Member not found | Replaced with `Icons.lock_open_rounded` |
| All `LucideIcons.*` usage | Replaced with equivalent `Icons.*` throughout all 11 files |
| `lucide_icons` package dependency | Removed from `pubspec.yaml` — no longer needed |
| Emoji strings in `StatItem.icon` / `ActionItem.icon` | Replaced with proper `IconData` fields |
| Emoji `av:` strings in `listItem()` | Replaced with `avIcon: IconData` parameter |
| Emoji in `schoolCard()` (🏫, 🎓, 📚) | Replaced with `Icon` widgets |
| Emoji in `searchBar()` (🔍) | Replaced with `Icons.search_rounded` |
| Emoji in `authCard()` (✓ ✗) | Replaced with `Icons.check_circle_outline_rounded` / `Icons.cancel_outlined` |
| Top bar "A" logo bubble | Removed — replaced with clean icon + text |

---

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (13+)
- ✅ Portrait orientation enforced

