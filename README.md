# Academic Architect — Flutter App

A faithful Flutter conversion of the Academic Architect School ERP web app.
All screens, layouts, colors, and aesthetics match the original exactly.

## Screens Included

### Login / Landing Screen
- Hero headline, preview card, AI insight tag
- Role selector grid (6 roles)

### Global Admin
- Dashboard (system health, stats, quick actions)
- Schools (list with search)
- Domains (SSL status)
- System Config (feature flags, resource usage)
- Profile & Settings

### School Admin
- Dashboard (stats, quick actions, activity timeline)
- Students (search, filter chips, list)
- Teachers (list)
- Roles & Permissions
- Academic Years (progress bars)
- Grading Remarks (table with bands)
- Parent–Student Mapping
- Parents list
- Profile & Settings

### Teacher
- Dashboard (today's classes timetable, quick actions)
- Attendance (mark present/late/absent per student)
- Assignments (card list with submission counts)
- Grades (table with score entry)
- My Timetable (day chips, class rows, attendance progress)
- Exams (schedule list)
- Student Analytics (AI insights)
- Profile & Settings

### Student
- Dashboard (schedule, due assignments)
- My Subjects (teacher, grade)
- Learning Materials (file list)
- Assignments (status chips)
- Grades & Report Card (grade bars + exam chips)
- Attendance (calendar grid + subject bars)
- Timetable (day chips)
- Profile & Settings

### Parent
- Dashboard (child card, recent updates timeline)
- Child Overview (stats + grade bars)
- Grades & Report Card
- Attendance
- Assignments
- Payments (finance banner + invoice history)
- AI Insights (colored insight cards)
- Profile & Settings

### Accountant
- Dashboard (finance banner, stats, recent transactions)
- Invoices (search + filter chips)
- Fee Structure (grade-tier fee table)
- Reconcile Payments (unmatched transactions)
- Manual Payment (form)
- Authorize Transactions (approve/reject cards)
- Financial Reports (grade collection bars)
- Profile & Settings

## Setup

```bash
flutter pub get
flutter run
```

## Dependencies
- flutter
- google_fonts (Plus Jakarta Sans + DM Serif Display — matching the original)

## Design Tokens
All CSS variables from the original are mapped exactly:
- `--navy` → `AppColors.navy` (#0D1F3C)
- `--blue` → `AppColors.blue` (#1A56DB)
- `--teal` → `AppColors.teal` (#0B6E8A)
- `--amber` → `AppColors.amber` (#A05C0D)
- `--green` → `AppColors.green` (#127A37)
- `--red` → `AppColors.red` (#B01C28)
- Border radius: rSm=8, rMd=12, rLg=18, rXl=24, rFull=999

## Notes
- Avatar images (admin, teacher, student, parent, accountant) are in `assets/avatars/`
- App displays in a phone-frame style (390×844) centered on the screen, matching the original web app
- Drawer navigation + bottom nav tab bar match the original exactly
- Notification panel slides in from the top-right bell icon
