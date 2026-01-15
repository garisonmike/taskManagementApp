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
**Status:** ✅ Completed

**Acceptance Criteria**
- Clear folder structure under `/lib`
- Separation of UI, data, and services
- Architecture explained in README

**Completion Notes**
- Clean Architecture implemented with 4 layers: core, data, domain, presentation
- Clear separation: UI (presentation), Data (data layer), Business Logic (domain)
- README updated with comprehensive architecture documentation
- Riverpod state management approach documented (StateNotifier/AsyncNotifier)
- Immutable state pattern enforced
- Feature-scoped providers architecture defined

**Completed:** ✅

---

### Issue 0.3 — Local Persistence Layer
**Status:** ✅ Completed

**Acceptance Criteria**
- Offline-first storage implemented
- Data persists after restart
- Schema/versioning prepared

**Completion Notes**
- Implemented sqflite-based local persistence with DatabaseHelper singleton
- Created comprehensive database schema (v1) with 6 tables: tasks, reminders, blueprints, blueprint_tasks, task_logs, settings
- Schema versioning prepared with onCreate and onUpgrade methods for future migrations
- SettingsLocalDataSource demonstrates offline-first data operations
- All unit tests passing (6/6) including data persistence across app restarts
- Performance indexes created for frequently queried fields
- Demo app created to verify persistence functionality
- Added flutter_riverpod and sqflite dependencies

**Completed:** ✅

---

## EPIC 1: Theming & App Shell

### Issue 1.1 — App Shell & Navigation
**Status:** ✅ Completed

**Acceptance Criteria**
- WhatsApp-like navigation
- Core pages scaffolded
- Navigation stable and intuitive

**Completion Notes**
- Implemented bottom navigation bar with 4 tabs (Tasks, Reminders, Blueprints, Settings)
- WhatsApp-like UI with fixed bottom navigation and active/inactive icons
- All core pages scaffolded with appropriate empty states
- Navigation state managed using Riverpod StateProvider (immutable state)
- IndexedStack maintains page state when switching tabs
- All 7 navigation tests passing including state persistence verification
- Clean, minimal code following Riverpod architecture principles
- No business logic in widgets

**Completed:** ✅

---

### Issue 1.2 — Theme System
**Status:** ✅ Completed

**Acceptance Criteria**
- Timber Brown default theme
- Dark & Light themes available
- Theme toggle persists across restarts

**Completion Notes**
- Timber Brown (Light) set as default theme with custom color palette (#6D4C41)
- Three themes implemented: Timber Brown Light (default), Timber Brown Dark, and standard Light
- Theme system uses Riverpod StateNotifier with immutable ThemeState
- Theme persistence via ThemeRepository using local database
- Theme selection page with visual icons for each mode
- Settings page shows current theme and navigates to theme selector
- All 6 theme tests passing including persistence across app restarts
- Clean architecture: domain interfaces, data repositories, presentation providers
- No business logic in widgets

**Completed:** ✅

---

## EPIC 2: Task Management (Core)

### Issue 2.1 — Task Data Model
**Status:** ✅ Completed

**Acceptance Criteria**
- Task model supports:
  - Unsure / Deadline / Time-based tasks
  - Optional reminders
  - Completion & failure reasons
  - Postpone & drop states

**Completion Notes**
- TaskEntity with three task types: unsure, deadline, timeBased
- Complete domain entities: TaskEntity and ReminderEntity (immutable)
- Data models: TaskModel and ReminderModel with database mapping
- All required fields: title, description, task types, deadlines, time ranges
- Status fields: isCompleted, completionDate, failureReason (optional)
- State management: isPostponed, isDropped boolean flags
- ReminderEntity supports optional reminders linked to tasks via taskId
- Immutable design with copyWith methods
- Proper equality and hashCode implementations
- All 17 tests passing (11 task entity + 6 reminder entity tests)
- Clean architecture: domain entities separated from data models

**Completed:** ✅

---

### Issue 2.2 — Add & Edit Tasks UI
**Status:** ✅ Completed

**Acceptance Criteria**
- Add task flow is clean and minimal
- Editing does not corrupt existing data
- No mandatory fields except title

**Completion Notes**
- Created TaskInputPage with clean form-based UI for adding and editing tasks
- Only title field is required (validated), all other fields optional
- Three task types supported: Unsure, Deadline (with date/time picker), Time-based (with start/end time pickers)
- Full Riverpod integration: TaskNotifier manages task state, TaskRepository handles persistence
- Data layer: TaskLocalDataSource with complete CRUD operations
- Repository pattern: TaskRepository interface with TaskRepositoryImpl
- Form validation ensures only title is mandatory
- Edit mode preserves all existing data using TaskEntity.copyWith()
- Navigation: FAB on TasksPage opens TaskInputPage for add, tap task to edit
- Task list displays with icons for task types, shows completion status
- All 54 tests passing (including 24 new task tests + 7 navigation tests)
- Clean UI with Material 3 design (SegmentedButton, date/time pickers)
- No build context across async gaps (proper mounted checks)
- Zero flutter analyze issues

**Completed:** ✅

---

### Issue 2.3 — Task Completion & Failure Handling
**Status:** ✅ Completed

**Acceptance Criteria**
- Tasks can be completed manually
- Failure reason optional
- Postpone & extend deadline works

**Completion Notes**
- Added complete button (check icon) to TaskListTile for quick task completion
- Complete dialog offers two options: "Completed" (success) or "Failed" (with optional reason)
- Failure reason dialog with TextField - completely optional (can be empty or skipped)
- Task actions menu (3-dot menu) provides:
  - Mark as Complete (same as quick button)
  - Postpone (sets isPostponed flag for deadline tasks)
  - Extend Deadline (date/time picker updates deadline for deadline tasks)
  - Edit (navigate to TaskInputPage)
  - Delete (with confirmation dialog)
- All actions only available for incomplete tasks (except Edit and Delete)
- Postpone and Extend Deadline only shown for deadline-type tasks
- Proper mounted checks for all async operations
- All field updates use copyWith pattern to preserve existing data
- 8 new provider tests covering:
  - Successful completion with completionDate
  - Failed completion with optional failureReason
  - Task postponement
  - Deadline extension
  - Combined operations (postpone then complete, extend then complete)
- All 62 tests passing (8 new task action tests)
- Zero flutter analyze issues
- Clean Riverpod architecture maintained

**Completed:** ✅

---

## EPIC 3: Notifications & Reminders

### Issue 3.1 — Notification Engine
**Status:** ✅ Completed

**Acceptance Criteria**
- Notifications fire reliably
- Works after app close & phone reboot
- Privacy settings respected

**Completion Notes**
- Implemented NotificationService singleton with flutter_local_notifications integration
- Complete notification lifecycle: initialize(), scheduleNotification(), cancelNotification(), cancelAllNotifications()
- ReminderScheduler bridges ReminderEntity/TaskEntity to NotificationService
- Android permissions configured: POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, SCHEDULE_EXACT_ALARM, USE_EXACT_ALARM
- Boot persistence: ScheduledNotificationBootReceiver ensures notifications survive app close and phone reboot
- Exact timing: Uses AndroidScheduleMode.exactAllowWhileIdle for reliable notification delivery
- Privacy respected: permission_handler requests user consent before enabling notifications
- Timezone support: timezone package ensures accurate scheduling across time zones
- Main.dart initialization: async setup ensures NotificationService ready before app runs
- Smart scheduling: Past reminders silently skipped, disabled reminders respected
- All 67 tests passing (2 new service structure tests + 65 existing)
- Zero flutter analyze issues
- Android build successful with core library desugaring enabled
- Clean architecture: services layer independent of UI, ready for provider integration

**Completed:** ✅

---

### Issue 3.2 — Reminder Management Page
**Status:** ✅ Completed

**Acceptance Criteria**
- View reminders by day
- Edit or disable reminders
- No accidental task deletion

**Completion Notes**
- Implemented RemindersPage with day-based reminder grouping
- Date sections show "Today", "Tomorrow", or formatted date (e.g., "Monday, Jan 15")
- Each reminder displays: notification icon, task title, reminder time
- Enable/disable toggle: Updates database and schedules/cancels notifications in real-time
- Edit time: Date and time pickers allow changing reminder schedule
- Delete reminder: Confirmation dialog explicitly states "The task will not be deleted"
- ReminderWithTask combines reminder and task data for display
- remindersByDateProvider groups reminders by date, sorted by time
- Complete data layer: ReminderLocalDataSource, ReminderModel, ReminderRepository
- Integration with NotificationService for scheduling updates
- Empty state: Shows "No reminders" message with icon
- All 71 tests passing (4 new reminder repository tests)
- Zero flutter analyze issues
- Clean Riverpod architecture: repository pattern, immutable state

**Completed:** ✅

---

### Issue 3.3 — Inactivity Reminder
**Status:** ✅ Completed

**Acceptance Criteria**
- Triggers when no tasks exist
- User-configurable time
- Can be disabled

**Completion Notes**
- Implemented InactivityReminderService for managing daily inactivity notifications
- Automatic triggering: Monitors task count and schedules reminder only when no tasks exist
- Configuration UI in Settings page with enable/disable toggle and time picker
- Default time: 09:00 (9 AM), user can configure any time via time picker
- Settings persistence: Uses existing settings table with keys 'inactivity_reminder_enabled' and 'inactivity_reminder_time'
- Integration with TaskNotifier: Automatically updates reminder when tasks are added or deleted
- Smart scheduling: Schedules for tomorrow if configured time has passed today
- Cancellation: Automatically cancels reminder when tasks are added
- Clean UI: Shows "Daily at HH:mm" when enabled, "Disabled" when off
- Tap tile to configure time (only when enabled)
- All 72 tests passing (1 new service structure test)
- Zero flutter analyze issues
- Successful Android APK build
- Clean Riverpod architecture with provider pattern

**Completed:** ✅

---

## EPIC 4: Alarms

### Issue 4.1 — Native Android Alarm Integration
**Status:** ✅ Completed

**Acceptance Criteria**
- Uses Android system alarm clock
- Alarm survives app uninstall
- User sets alarms manually only

**Completion Notes**
- Implemented AlarmService using platform channels (MethodChannel) for Android integration
- Uses Android AlarmClock intents: ACTION_SET_ALARM and ACTION_SHOW_ALARMS
- Complete native Android implementation in MainActivity.kt with proper intent handling
- UI integration in Settings page with "Set Alarm" tile under Alarms section
- Two options provided: "Set New Alarm" (with time picker and optional label) and "Open Alarms" (view all system alarms)
- Permission added: com.android.alarm.permission.SET_ALARM in AndroidManifest.xml
- Alarms are created in Android's native clock app, ensuring persistence after app uninstall
- User manually confirms alarm creation in system clock app (EXTRA_SKIP_UI = false)
- Clean Riverpod architecture with alarmServiceProvider
- All 73 tests passing (1 new service structure test)
- Zero flutter analyze issues
- Successful Android APK build with alarm integration
- Clean separation: AlarmService in services layer, provider in presentation layer
- No data persistence needed as alarms are managed by Android system

**Completed:** ✅

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
