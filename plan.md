# Task Tracker App — Development Plan (V1)

## Rules for Execution (MANDATORY)

- Work strictly **issue by issue**, in the order defined below.
- Do NOT start a new issue until the current issue is:
  - Fully implemented
  - Acceptance criteria verified
  - Marked as complete in this file
- After completing an issue:
  - Re-check all acceptance criteria
  - Tick the checkbox
  - Add a short completion note
- Never mark an issue complete if any acceptance criterion is unmet.
- This file is the **single source of truth** for progress.

---

## EPIC 0: Project Foundation & Architecture

### Issue 0.1 — Initialize Flutter Project
**Status:** ✅ Completed

**Acceptance Criteria**
- Flutter project created
- Android-only configuration
- App builds and runs on emulator or physical device

**Completion Notes**
- Flutter project created with package name `task_management_app`
- Android-only platform configured (--platforms android)
- Project successfully builds (verified with `flutter build apk --debug`)
- Organization ID: com.taskmanagement
- Flutter SDK: 3.35.7, Dart SDK: 3.9.2

**Completed:** ✅

---

### Issue 0.2 — Define App Architecture
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Clear folder structure under `/lib`
- Separation of UI, data, and services
- Architecture explained in README

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 0.3 — Local Persistence Layer
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Offline-first storage implemented
- Data persists after restart
- Schema/versioning prepared

**Completion Notes**
- 

**Completed:** ⬜

---

## EPIC 1: Theming & App Shell

### Issue 1.1 — App Shell & Navigation
**Status:** ⬜ Not Started

**Acceptance Criteria**
- WhatsApp-like navigation
- Core pages scaffolded
- Navigation stable and intuitive

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 1.2 — Theme System
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Timber Brown default theme
- Dark & Light themes available
- Theme toggle persists across restarts

**Completion Notes**
- 

**Completed:** ⬜

---

## EPIC 2: Task Management (Core)

### Issue 2.1 — Task Data Model
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Task model supports:
  - Unsure / Deadline / Time-based tasks
  - Optional reminders
  - Completion & failure reasons
  - Postpone & drop states

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 2.2 — Add & Edit Tasks UI
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Add task flow is clean and minimal
- Editing does not corrupt existing data
- No mandatory fields except title

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 2.3 — Task Completion & Failure Handling
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Tasks can be completed manually
- Failure reason optional
- Postpone & extend deadline works

**Completion Notes**
- 

**Completed:** ⬜

---

## EPIC 3: Notifications & Reminders

### Issue 3.1 — Notification Engine
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Notifications fire reliably
- Works after app close & phone reboot
- Privacy settings respected

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 3.2 — Reminder Management Page
**Status:** ⬜ Not Started

**Acceptance Criteria**
- View reminders by day
- Edit or disable reminders
- No accidental task deletion

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 3.3 — Inactivity Reminder
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Triggers when no tasks exist
- User-configurable time
- Can be disabled

**Completion Notes**
- 

**Completed:** ⬜

---

## EPIC 4: Alarms

### Issue 4.1 — Native Android Alarm Integration
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Uses Android system alarm clock
- Alarm survives app uninstall
- User sets alarms manually only

**Completion Notes**
- 

**Completed:** ⬜

---

## EPIC 5: Blueprints & Routines

### Issue 5.1 — Blueprint Data Model
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Blueprint stored independently
- Future days update when blueprint changes
- Custom daily tasks never alter blueprint

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 5.2 — Blueprint Editor Page
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Create, edit, delete blueprints
- Editing does not affect past data

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 5.3 — Daily Task Generation
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Daily tasks generated correctly
- Day-level overrides isolated

**Completion Notes**
- 

**Completed:** ⬜

---

## EPIC 6: Logs & Analytics

### Issue 6.1 — Immutable Logging System
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Logs are append-only
- Deletion controlled via settings

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 6.2 — Weekly Summary Generator
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Saturday summary generated automatically
- Completion rate accurate

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 6.3 — GitHub-Style Completion Graph
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Heatmap renders correctly
- Can be disabled

**Completion Notes**
- 

**Completed:** ⬜

---

## EPIC 7: Meals & Fitness (Separate Domain)

### Issue 7.1 — Meals Module Separation
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Meals fully decoupled from tasks
- Optional inclusion in logs

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 7.2 — Weekly Meal Blueprint
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Weekly timeline works
- Daily substitutions do not alter blueprint

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 7.3 — Food Data Table
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Default nutrition columns exist
- Custom columns persist

**Completion Notes**
- 

**Completed:** ⬜

---

## EPIC 8: Settings, Privacy & Export

### Issue 8.1 — Settings Engine
**Status:** ⬜ Not Started

**Acceptance Criteria**
- Presets + advanced toggles
- Changes apply instantly

**Completion Notes**
- 

**Completed:** ⬜

---

### Issue 8.2 — Export & Import
**Status:** ⬜ Not Started

**Acceptance Criteria**
- CSV export works
- Import restores state accurately

**Completion Notes**
- 

**Completed:** ⬜
