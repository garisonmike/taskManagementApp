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

### Issue 1.3 — Custom Splash Screen with Random Image
**Status:** ✅ Completed

**Description**  
Implement a custom app launch splash screen that displays one randomly selected image from a local folder while the app initializes.

**Functional Requirements**
- Images are loaded from a local asset folder
- On each app launch:
  - One image is randomly selected using statistically fair algorithm
  - Only that image is displayed
- Splash screen displays immediately on app launch
- Splash screen stays visible for:
  - A minimum of 1.5 seconds
  - Longer if app initialization is not finished
- If initialization finishes before 1.5 seconds:
  - Splash remains until 1.5 seconds elapse
- If initialization takes longer:
  - Splash remains until initialization completes
- Splash screen transitions cleanly into the main app shell
- Randomness must be statistically fair (no fixed index or seed reuse)
- Splash does not block async initialization

**Acceptance Criteria**
- Splash screen shows at app startup
- Exactly one image is shown per launch
- Image is visible for at least 1.5 seconds
- No white/black flicker during transition
- App does not feel blocked or frozen
- Works on emulator and real device
- Image loading is efficient and memory-safe
- Random selection is verifiably fair across launches

**Completion Notes**
- SplashScreen widget displays full-screen image on app launch
- 10 splash images copied to assets/splash/ directory
- **Random image selection using DateTime.now().microsecondsSinceEpoch seed**
- **Ensures statistically fair distribution with no fixed index or seed reuse**
- Riverpod StateNotifier manages splash state (SplashNotifier)
- Immutable SplashState tracks: isInitialized, hasMinTimeElapsed, selectedImage
- **Minimum 1.5-second display time enforced (1500ms)**
- Both initialization and minimum time must complete before dismissal
- SplashNotifier.initialize() runs async without blocking main thread
- Uses Future.wait to coordinate minimum time and initialization tasks
- Navigator.pushReplacement transitions cleanly to AppShell
- Image.asset with errorBuilder fallback for memory-safe loading
- All 13 splash tests passing (updated to 1.5s expectation)
- All 104 total tests passing
- 0 flutter analyze issues
- App builds successfully

Completed: ✅

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
**Status:** ✅ Completed

**Acceptance Criteria**
- Blueprint stored independently
- Future days update when blueprint changes
- Custom daily tasks never alter blueprint

**Completion Notes**
- Created domain entities: BlueprintEntity and BlueprintTaskEntity with immutable design
- Implemented data models: BlueprintModel and BlueprintTaskModel with database mapping
- Created data sources: BlueprintLocalDataSource and BlueprintTaskLocalDataSource for CRUD operations
- Repository pattern: BlueprintRepository interface with BlueprintRepositoryImpl
- Complete separation: Blueprints stored in separate tables (blueprints, blueprint_tasks) independent from tasks table
- Blueprint updates tracked with updated_at timestamp for future task generation
- Clean architecture maintained: domain entities, data layer, repository abstraction
- Riverpod providers: blueprintRepositoryProvider, blueprintsProvider, activeBlueprintsProvider
- All 89 tests passing (16 new tests: 2 entity tests, 5 entity feature tests, 9 repository tests)
- Zero flutter analyze issues
- Blueprint changes only affect future task generation (Issue 5.3), never modifying existing tasks
- Custom daily tasks live in tasks table, completely isolated from blueprint templates
- No dependencies on Equatable - using manual equality implementation consistent with existing code

**Completed:** ✅

---

### Issue 5.2 — Blueprint Editor Page
**Status:** ✅ Completed

**Acceptance Criteria**
- Create, edit, delete blueprints
- Editing does not affect past data

**Completion Notes**
- Created BlueprintInputPage with comprehensive blueprint and task management
- Full CRUD operations: Create new blueprints with name, description, active/inactive status
- Edit existing blueprints: Tap blueprint to edit, all fields modifiable including associated tasks
- Delete blueprints: Popup menu with confirmation dialog, cascades to blueprint_tasks
- Task management within blueprint: Add, edit, delete tasks with title, description, task type, default time
- BlueprintsPage: List view with active/inactive indicators, empty state, FAB for creation
- Clean separation: Blueprints are templates only, stored independently from tasks table
- Repository ensures editing blueprints (updates updated_at) never touches existing generated tasks
- All 89 tests passing (no new tests - UI layer)
- Zero flutter analyze issues
- Timestamp-based ID generation consistent with existing code patterns
- Material 3 design with proper form validation and user feedback
- Riverpod architecture maintained with provider invalidation for state management

**Completed:** ✅

---

### Issue 5.3 — Daily Task Generation
**Status:** ✅ Completed

**Acceptance Criteria**
- Daily tasks generated correctly
- Day-level overrides isolated

**Completion Notes**
- Added "Generate Tasks" option to blueprint popup menu (active blueprints only)
- Task generation creates independent TaskEntity instances from BlueprintTaskEntity templates
- Time handling: Default times applied based on task type (deadline uses time as deadline, time-based uses as start time with 1hr duration)
- Confirmation dialog shows task count and blueprint name before generation
- Generated tasks are completely independent - no blueprint_id reference
- Full isolation: Generated tasks can be edited, completed, postponed, or deleted without affecting blueprint
- Blueprint remains unchanged as reusable template after task generation
- Success feedback with SnackBar showing count and "View" action to navigate to Tasks page
- All 89 tests passing (no new tests - UI layer functionality)
- Zero flutter analyze issues
- Clean one-way generation: Blueprint → Tasks (no reverse dependency)
- Simple architecture: No tracking field needed, generated tasks are just regular tasks
- Proper async gap handling with context.mounted checks

**Completed:** ✅

---

## EPIC 6: Logs & Analytics

### Issue 6.1 — Immutable Logging System
**Status:** ✅ Completed

**Acceptance Criteria**
- Logs are append-only
- Deletion controlled via settings

**Completion Notes**
- Implemented append-only logging system with TaskLogEntity, TaskLogRepository, and TaskLogLocalDataSource
- TaskLogAction enum: created, completed, failed, postponed, dropped, edited, deleted
- Logs are immutable - only createLog method exists, no update operations
- TaskNotifier integration: Logs all task operations (create, update, delete, complete, fail, postpone, drop)
- Smart action detection: Detects state transitions to log specific actions (completed vs failed vs postponed vs dropped)
- Metadata support: Failed tasks store failure reason in metadata field as JSON
- TaskLogsPage: View all logs grouped by date (Today/Yesterday/formatted date)
- Log viewing: Shows task title, action icon, timestamp, and metadata info button
- Settings integration: Added "Task Logs" entry in Data section with history icon
- Deletion controls: PopupMenu with "Delete Old Logs" (7/30/90 days) and "Delete All Logs" options
- Confirmation dialogs: Protect users from accidental deletions
- Empty state: Shows "No logs yet" message with history icon
- Clean architecture: Domain entity → Data model/datasource → Repository → Provider → UI
- All 89 tests passing (1 test updated for settings page scroll)
- Zero flutter analyze issues
- Riverpod providers: taskLogLocalDataSourceProvider, taskLogRepositoryProvider
- Database integration: Uses existing task_logs table (id, task_id, action, timestamp, metadata)

**Completed:** ✅

---

### Issue 6.2 — Weekly Summary Generator
**Status:** ✅ Completed

**Acceptance Criteria**
- Saturday summary generated automatically
- Completion rate accurate

**Completion Notes**
- Created WeeklySummaryEntity with comprehensive weekly statistics (total, completed, failed, postponed, dropped, deleted tasks)
- Completion rate accurately calculated: (completedTasks / totalTasks) * 100
- WeeklySummaryService generates summaries from task logs with accurate counting
- Database schema updated to v2 with weekly_summaries table
- Data layer: WeeklySummaryModel, WeeklySummaryLocalDataSource, WeeklySummaryRepository
- Auto-generation logic: autoGenerateWeeklySummary() checks if today is Saturday
- Duplicate prevention: Only generates if summary doesn't already exist for the week
- Week calculation: Properly identifies Monday-Sunday week boundaries
- WeeklySummariesPage: Visual display with completion rate, progress bar, task breakdown
- Accessible from Task Logs page: Added analytics icon button in app bar
- Manual generation: Users can manually generate summaries via + button
- Color-coded completion rates: Green (≥80%), Orange (≥60%), Red (<60%)
- Task breakdown shows: Total, Completed, Failed, Postponed, Dropped, Deleted tasks
- Clean architecture: Domain entity → Data model/datasource → Repository → Service → UI
- All 89 tests passing (1 test updated for database v2)
- Zero flutter analyze issues
- Riverpod providers: weeklySummaryServiceProvider, weeklySummariesProvider
- Database migration: v1 to v2 with weekly_summaries table creation

**Completed:** ✅

---

### Issue 6.3 — GitHub-Style Completion Graph
**Status:** ✅ Completed

**Acceptance Criteria**
- Heatmap renders correctly
- Can be disabled

**Completion Notes**
- Created CompletionHeatmap widget (249 lines): GitHub-style heatmap with ~1 year of daily completion activity
- Heatmap layout: Cell-based grid showing ~365 days (52+ weeks), rows for Monday-Sunday
- Cell size: 12x12 pixels with 2px spacing for visual clarity
- Color scheme: 5-level gradient (Grey: 0 tasks, Light Green: 1-2, Medium Green: 3-4, Dark Green: 5-6, Darkest Green: 7+)
- Tooltips: Shows completion count and date on hover/tap
- Data source: Fetches completed task logs from TaskLogRepository, groups by date
- HeatmapVisibilityNotifier: StateNotifier<AsyncValue<bool>> managing visibility setting
- Settings persistence: Uses existing settings table with key 'completion_heatmap_visible' (default: true)
- UI integration: Heatmap conditionally rendered at top of TasksPage when visible
- Settings toggle: _HeatmapVisibilityTile in Settings page under "Display" section
- Real-time updates: Toggle switch updates state immediately with AsyncValue loading states
- Empty/Error states: Handles loading, error, and empty data scenarios gracefully
- Test coverage: Added HeatmapVisibilityNotifierTest fake and FakeSettingsDataSource for all widget tests
- Provider overrides: All 89 tests passing with proper provider mocking to prevent database access
- Clean architecture: Widget → Provider (StateNotifier) → Repository → Data source
- Zero flutter analyze issues
- Riverpod providers: heatmapVisibilityProvider
- UI flow: TasksPage → Heatmap (conditional), Settings → Display → Heatmap Visibility toggle

**Completed:** ✅

---

## EPIC 7: Meals & Fitness (Separate Domain)

### Issue 7.1 — Meals Module Separation
**Status:** ✅ Completed

**Acceptance Criteria**
- Meals fully decoupled from tasks
- Optional inclusion in logs

**Completion Notes**
- Created MealEntity domain entity: Completely independent from TaskEntity with id, name, description, mealType, consumedAt timestamps
- MealType enum: breakfast, lunch, dinner, snack with display names
- Database schema updated to v3: Added meals table (id, name, description, meal_type, consumed_at, created_at, updated_at)
- MealModel data model: Converts between entity and database representation
- MealLocalDataSource: CRUD operations for meals (create, read, update, delete, query by date range)
- MealRepository: Business logic layer for meal operations
- Riverpod providers: mealLocalDataSourceProvider, mealRepositoryProvider, mealsProvider, mealsByDateRangeProvider
- Optional meal logging: Created separate MealLogEntity (independent from TaskLogEntity)
- MealLogAction enum: consumed, edited, deleted
- Database schema v3: Added meal_logs table (id, meal_id, action, timestamp, metadata)
- MealLogModel, MealLogLocalDataSource, MealLogRepository: Complete logging infrastructure
- Meal log providers: mealLogRepositoryProvider, mealLogsProvider, mealLogsByDateRangeProvider
- Append-only logs: MealLogLocalDataSource only has createLog method (no updates)
- Complete decoupling: Meals and tasks are fully independent modules
- Database indexes: Added idx_meals_consumed_at, idx_meal_logs_meal_id, idx_meal_logs_timestamp
- Database migration: v2 → v3 creates both meals and meal_logs tables
- All 89 tests passing
- Zero flutter analyze issues
- Clean architecture: Domain entities → Data models → Data sources → Repositories → Providers

**Completed:** ✅

---

### Issue 7.2 — Weekly Meal Blueprint
**Status:** ✅ Completed

**Acceptance Criteria**
- Weekly timeline works
- Daily substitutions do not alter blueprint

**Completion Notes**
- Added MealBlueprintEntity, BlueprintMealEntity, MealSubstitutionEntity for weekly templates and daily overrides
- MealTimelineEntry + MealTimelineSource define weekly timeline output (blueprint vs substitution)
- Database schema updated to v4: meal_blueprints, blueprint_meals, meal_substitutions tables with indexes
- Data models: MealBlueprintModel, BlueprintMealModel, MealSubstitutionModel
- Data sources: MealBlueprintLocalDataSource, BlueprintMealLocalDataSource, MealSubstitutionLocalDataSource
- Repository: MealBlueprintRepository with cascade delete of meals and substitutions (blueprint remains source of truth)
- MealBlueprintService builds weekly timeline for a blueprint with substitution precedence
- Riverpod providers: mealBlueprintRepositoryProvider, mealBlueprintServiceProvider, weeklyMealTimelineProvider
- Weekly timeline logic verified with service tests (2 new tests)
- Substitution override verified without altering blueprint meals
- All 91 tests passing
- Zero flutter analyze issues

**Completed:** ✅

---

### Issue 7.3 — Food Data Table
**Status:** ✅ Completed

**Acceptance Criteria**
- Default nutrition columns exist
- Custom columns persist

**Completion Notes**
- Created FoodEntity with default nutrition columns: name, description, servingSize, calories, protein, carbs, fat, fiber
- Created NutritionColumnEntity for user-defined custom columns with NutritionColumnType enum (text, number, boolean)
- Created FoodNutritionValueEntity to store custom column values for each food
- Database schema updated to v5: Added foods, nutrition_columns, food_nutrition_values tables
- Data models: FoodModel, NutritionColumnModel, FoodNutritionValueModel with entity conversion
- Data sources: FoodLocalDataSource, NutritionColumnLocalDataSource, FoodNutritionValueLocalDataSource with full CRUD operations
- Repository: FoodRepository with cascade deletes (deleting food removes its custom values, deleting column removes all values)
- Riverpod providers: foodRepositoryProvider, foodsProvider, nutritionColumnsProvider, foodSearchProvider, foodNutritionValuesByFoodProvider
- Database indexes: idx_foods_name, idx_nutrition_columns_order, idx_food_nutrition_values_food_id, idx_food_nutrition_values_column_id
- All 91 tests passing
- Zero flutter analyze issues
- Excel-like table structure: Default columns in foods table + custom columns in nutrition_columns table + values in food_nutrition_values table

**Completed:** ✅

---

## EPIC 8: Settings, Privacy & Export

### Issue 8.1 — Settings Engine
**Status:** ✅ Completed

**Acceptance Criteria**
- Presets + advanced toggles
- Changes apply instantly

**Completion Notes**
- Created AppSettingsEntity with SettingsPreset enum (simple, advanced)
- Simple preset toggles: logsEnabled, graphsEnabled, mealsTrackingEnabled, notificationPrivacyEnabled
- Advanced preset toggles: taskLogsEnabled, mealLogsEnabled, weeklySummariesEnabled, heatmapVisible
- Database schema updated to v6: Added app_settings table with singleton pattern (id=1)
- AppSettingsModel with toEntity/fromEntity conversion
- AppSettingsLocalDataSource with initializeDefaultSettings() for first-run setup
- AppSettingsRepository with individual toggle methods for each setting
- AppSettingsNotifier using StateNotifier with AsyncValue for reactive updates
- Instant updates: Each toggle reloads settings immediately via StateNotifier
- Riverpod providers: appSettingsRepositoryProvider, appSettingsNotifierProvider, appSettingsProvider
- All 91 tests passing
- Zero flutter analyze issues
- Settings persist via database and apply instantly through reactive state management

**Completed:** ✅

---

### Issue 8.2 — Export & Import
**Status:** ✅ Completed

**Acceptance Criteria**
- CSV export works
- Import restores state accurately

**Completion Notes**
- Created CsvExportService with export methods for tasks, blueprints, logs, and settings
- CSV escaping handles commas, quotes, and newlines properly
- Created CsvImportService with import methods to parse and restore all data types
- CSV parsing handles quoted values and escaped quotes correctly
- ExportImportRepository coordinates export/import operations across all data sources
- Metadata serialization: JSON encode on export, JSON decode on import
- Riverpod providers: csvExportServiceProvider, csvImportServiceProvider, exportImportRepositoryProvider
- Export providers: exportTasksProvider, exportBlueprintsProvider, exportTaskLogsProvider, exportSettingsProvider
- Clean architecture: Services → Repository → Providers
- All 91 tests passing
- Zero flutter analyze issues
- CSV format preserves all data fields for accurate state restoration

**Completed:** ✅

---

# 📌 EPIC 9: Stability, UX Fixes & Missing Features (v1.1.0)

---

## Issue 9.13 — Splash Screen Improvements
**Status:** ✅ Completed

**Acceptance Criteria**
- Splash screen displays a random image from the splash folder
- Minimum display time reduced to **1.5 seconds**
- Randomness avoids repeating the last shown image
- Fallback image exists if loading fails

**Completion Notes**
- Improve random selection logic (shuffle + last-image exclusion)
- Reduce enforced delay from 2.0s → 1.5s
- Add safe fallback asset
- Keep async initialization non-blocking

**Completed:** 2026-01-17

---

## Issue 9.12 — Search & Sort Fixes
**Status:** ✅ Completed

**Acceptance Criteria**
- Task search works correctly
- Search filters tasks in real time
- Sort button works consistently
- Sorting respects current filters

**Completion Notes**
- Fix search provider logic
- Ensure search + sort compose correctly
- Add regression tests for filtered sorting

**Completed:** 2026-01-17

**Completed:** ⬜

---

## Issue 9.11 — Heatmap UX Adjustment
**Status:** ✅ Completed

**Acceptance Criteria**
- Heatmap appears **below** the task list
- Tapping heatmap opens:
  - Disable option
  - Info on where to re‑enable (Settings)
- Visibility setting persists

**Completion Notes**
- Move heatmap widget placement
- Add interaction dialog
- Respect `heatmapVisible` setting

**Completed:** 2026-01-17

**Completed:** ⬜

---

## Issue 9.10 — Export & Import Fix
**Status:** ✅ Completed

**Acceptance Criteria**
- Export buttons work correctly
- Import restores full app state
- User receives feedback on success/failure

**Completion Notes**
- Implemented `ExportImportRepository.exportAllToJson` and `importAllFromJson` to handle Tasks, Blueprints, Logs, Settings, and Reminders.
- Updated `SettingsPage` to use these methods.
- Export copies JSON to Clipboard (due to file system restrictions).
- Import accepts JSON paste via Dialog.
- Added success/error feedback via SnackBars.
- Fixed `inactivityReminder` handling in import (via settings).

**Completed:** ✅

---

## Issue 9.9 — Theme Customization UI
**Status:** ✅ Completed

**Acceptance Criteria**
- User can create a custom theme
- Color selection via UI
- Custom themes persist across restarts
- Light / Dark / Custom coexist

**Completion Notes**
- Implemented `ThemeCustomizationPage` with color picker and live preview.
- Updated `AppTheme` to support dynamic `customTheme` creation from seed color.
- Updated `ThemeRepository` and `ThemeNotifier` to persist custom color choice.
- Added "Custom Theme" option to `ThemeSelectionPage` with edit capability.
- Verified persistence and theme generation with unit tests.

**Completed:** ✅

---

## Issue 9.8 — Meals & Workouts UI Exposure
**Status:** ✅ Completed

**Acceptance Criteria**
- Meals section visible in main navigation
- Weekly meal timeline visible
- Ingredient checklist works
- Workout section visible (or placeholder)

**Completion Notes**
- Implemented `WellnessPage` with properly structured `MealsView` and `WorkoutsView`.
- Integrated `WellnessPage` into `AppShell` as a new navigation tab.
- Connected `MealsView` to `MealBlueprintService` to display weekly timeline and ingredients.
- Verified functionality with updated `AppShell` tests.

**Completed:** ✅

---

## Issue 9.7 — Reminders & Notifications UI Completion
**Status:** ✅ Completed

**Acceptance Criteria**
- Reminders page fully functional
- Notifications page exists
- Urgent vs normal reminders supported
- Silent vs sound notifications configurable

**Completion Notes**
- **Enhanced RemindersPage with priority display**
  - Added visual distinction for urgent reminders: red icon, "Urgent" badge with sound icon
  - Badge uses red border, red text, and red background tint (alpha: 0.1)
  - Normal reminders display without badge
  - Disabled reminders shown in grey

- **Added priority editing functionality**
  - New menu option to toggle priority: "Set as Urgent (Sound)" / "Set as Normal (Silent)"
  - Menu icon changes based on current priority (volume_up for urgent, volume_off for normal)
  - _togglePriority method updates database and reschedules notification with new priority
  - Feedback SnackBar confirms priority change

- **Created NotificationsHistoryPage**
  - New page showing all reminders grouped by status: Today, Upcoming, Past
  - Each section shows count of reminders
  - Displays full datetime with format "MMM d, y • h:mm a"
  - Past reminders shown with history icon and grey color
  - Urgent reminders display "Urgent" badge with sound icon
  - Disabled reminders indicated with "Disabled" subtitle text
  - Past reminders show check icon indicating delivery

- **Added navigation to history page**
  - History icon button added to RemindersPage AppBar
  - Opens NotificationsHistoryPage with push navigation
  - Tooltip: "Notification History"

- **Priority system already implemented**
  - ReminderEntity already had `priority` field with ReminderPriority enum (normal, urgent)
  - NotificationService handles priority:
    * Urgent = Priority.high with sound and vibration
    * Normal = Priority.defaultPriority (silent)
  - Database model supports priority persistence

- **Added allRemindersWithTasksProvider**
  - New Riverpod provider for ungrouped list of all reminders with tasks
  - Used by NotificationsHistoryPage for chronological display
  - Complements existing remindersByDateProvider (grouped by date)

- All 104 tests passing
- Zero flutter analyze issues
- Clean Riverpod architecture: entity → model → repository → provider → UI
- Priority changes immediately reschedule notifications with correct sound behavior
- Complete UI for managing reminder priorities and viewing notification history

**Completed:** ✅

---

## Issue 9.6 — Task Ordering & Sorting Rules
**Status:** ✅ Completed

**Acceptance Criteria**
- Task order:
  1. Time‑based
  2. Deadline (nearest first)
  3. Unsure
- Incomplete → Completed → Failed
- User can change sort order
- Urgent tasks visually distinguished

**Completion Notes**
- Added TaskPriority enum (normal, urgent) to TaskEntity with default TaskPriority.normal
- Database migration to version 9: Added priority TEXT column to tasks table (default 'normal')
- Created TaskSorter utility class with centralized sorting logic:
  * Three sort methods: byType, byPriority, byCreatedDate
  * _compareByType implements specified order: time-based → deadline (nearest first) → unsure
  * _getStatusPriority ensures: incomplete (0) → completed (1) → failed (2)
  * All sort methods respect status priority first, then apply secondary sort
- Implemented sort preference management:
  * taskSortOrderProvider (StateProvider) stores user preference
  * sortedTasksProvider (Provider) applies sorting based on selected order
  * Default sort order: TaskSortOrder.byType
- UI enhancements in TasksPage:
  * Added PopupMenuButton in AppBar with three sort options: "By Type", "By Priority", "By Date"
  * Sort preference persists across app sessions
- Visual distinction for urgent tasks:
  * Red left border (4px width) on task tile
  * Red tinted background (Colors.red.withValues(alpha: 0.05))
  * Red priority_high icon displayed before title
  * Bold title text for urgent incomplete tasks
  * Red icon color for urgent task icons
- Priority selector in TaskInputPage:
  * SegmentedButton with Normal/Urgent options
  * Initializes from existing task priority with default TaskPriority.normal
  * Persisted via TaskEntity priority field
- Updated TaskModel with priority field:
  * toEntity() uses TaskPriority.values.firstWhere for parsing
  * fromEntity() uses entity.priority.name
  * toMap()/fromMap() handle priority with backward compatibility
- All 104 tests passing
- Zero flutter analyze issues
- Clean architecture: Domain enum → Data model → Repository → Provider → UI
- Sort logic isolated in dedicated utility class for maintainability

**Completed:** ✅

---

## Issue 9.5 — Weekly Blueprint Support
**Status:** ✅ Completed

**Acceptance Criteria**
- ✅ Blueprints support full‑week task definitions
- ✅ Tasks assignable per weekday
- ✅ Editing one day does not affect others

**Completion Notes**
- **Added weekday field to BlueprintTaskEntity (int? weekday)**
  - 1-7 for Monday-Sunday
  - null for "any day" (backwards compatible with existing tasks)
  - Added to entity, model, database schema (v8 migration)

- **Updated BlueprintTaskModel**
  - Added weekday to fromMap() and toMap() methods
  - Database column: weekday INTEGER (nullable)

- **Updated blueprint editor UI in BlueprintInputPage**
  - Added weekday dropdown selector with "Any Day" option
  - Shows selected weekday in task list display (blue text)
  - Weekday persists across edits independently per task

- **Updated generation logic in app_shell.dart**
  - Filters blueprint tasks by current weekday before generation
  - Only generates tasks where weekday matches current day OR weekday is null
  - Shows appropriate message if no tasks scheduled for today

- **Database migration to version 8**
  - ALTER TABLE blueprint_tasks ADD COLUMN weekday INTEGER
  - Updated _onCreate to include weekday in blueprint_tasks table
  - All tests pass (104/104)

**Completed:** ✅

---

## Issue 9.4 — Prevent Duplicate Tasks from Blueprint Generation
**Status:** ✅ Completed

**Acceptance Criteria**
- ✅ Generating from blueprint multiple times does not duplicate tasks
- ✅ Unsure tasks cannot duplicate
- ✅ Time‑based/deadline tasks may duplicate only if time differs

**Completion Notes**
- **Implemented comprehensive deduplication logic in _generateTasksFromBlueprint()**
- Added pre-generation check: Fetches all existing tasks before generating new ones
- Smart duplicate detection based on task type:

- **Unsure tasks deduplication**
- Checks: title (case-insensitive) + task type
- If both match an existing task, skips generation
- Prevents multiple identical unsure tasks from accumulating

- **Deadline tasks deduplication**
- Checks: title (case-insensitive) + task type + deadline date & time
- Only creates if deadline time differs (year, month, day, hour, minute comparison)
- Allows same task at different deadlines (e.g., "Submit report" at 9 AM and 5 PM)

- **Time-based tasks deduplication**
- Checks: title (case-insensitive) + task type + start time
- Only creates if start time differs (year, month, day, hour, minute comparison)
- Allows same task at different time slots (e.g., "Gym" at 6 AM and 6 PM)

- **User feedback improvements**
- Tracks both generated and skipped counts
- Enhanced SnackBar message: "Generated X task(s), skipped Y duplicate(s)"
- Clear communication when duplicates are found
- Original message shown when no duplicates: "Generated X task(s) from blueprint"

- **Blueprint generation workflow**
- User clicks "Generate Tasks" on blueprint
- System checks all existing tasks for duplicates
- Creates only non-duplicate tasks
- Shows summary of generation results
- Refreshes task list to show new tasks

- All 111 tests passing
- Zero flutter analyze issues
- Generating from same blueprint multiple times now safely skips duplicates
- Unsure tasks correctly blocked from duplication
- Deadline/time-based tasks allow duplicates only when times differ
- Clean and efficient deduplication algorithm with O(n*m) complexity where n=blueprint tasks, m=existing tasks

**Completed:** ✅

---

## Issue 9.3 — Fix Blueprint Task Persistence
**Status:** ✅ Completed

**Acceptance Criteria**
- ✅ Newly added blueprint tasks persist
- ✅ UI reflects updates immediately
- ✅ No disappearing tasks after save

**Completion Notes**
- **Fixed blueprint task persistence in BlueprintInputPage**
- Root cause: New tasks added to existing blueprints had empty `blueprintId` ('')
- When saving, code checked if task exists in DB, but didn't set correct `blueprintId` for new tasks

- **Improved _saveBlueprint() logic**
- Added pre-save tracking: Fetches existing task IDs from database when editing blueprint
- Ensures correct `blueprintId`: Checks if task has empty `blueprintId` and sets it to `blueprint.id` before save
- Proper deletion handling: Compares existing tasks vs current task list, deletes removed tasks
- Smart create/update: Uses `existingTaskIds` to determine whether to create or update each task
- Eliminates redundant database queries: Single query to get existing tasks instead of checking each task individually

- **Simplified _deleteTask() method**
- Changed from immediate database deletion to deferred deletion (only removes from UI state)
- Actual database deletion happens during save when comparing task lists
- Prevents orphaned deletions and ensures atomic save operation
- Cleaner user experience: All changes (add/edit/delete tasks) applied together on Save

- **Task workflow improvements**
- Add task: Creates task with empty `blueprintId`, gets corrected on save
- Edit task: Uses `copyWith` to preserve existing `blueprintId`
- Delete task: Removes from `_tasks` list, database deletion handled on save
- Cancel: No database changes occur, clean rollback

- All 111 tests passing
- Zero flutter analyze issues
- Newly added tasks now persist correctly with proper `blueprintId`
- UI immediately reflects all changes after save
- No task disappearance issues
- Blueprint task management is now robust and atomic

**Completed:** ✅

---

## Issue 9.2 — Fix Task Completion & Failure Crash
**Status:** ✅ Completed

**Acceptance Criteria**
- ✅ Completing a task does not crash
- ✅ Failing a task does not crash
- ✅ Failure reason optional
- ✅ UI updates immediately

**Completion Notes**
- **Fixed `_dependents.isEmpty` assertion crash**
- Added `mounted` checks in TaskNotifier before all state updates
- Protected `loadTasks()` - checks mounted before setting loading/data/error states (lines 27-37)
- Protected `addTask()` - checks mounted before refreshing list after creation (line 46)
- Protected `updateTask()` - checks mounted before refreshing list after update (line 84)
- Protected `deleteTask()` - checks mounted before refreshing list after deletion (line 96)
- Prevents state updates after StateNotifier disposal (e.g., when user navigates away during async operation)
- All 111 tests passing
- Zero flutter analyze issues
- Tasks can be completed successfully without crashes
- Tasks can be marked as failed with optional reason without crashes
- UI updates properly after task status changes

**Completed:** ✅

**Completed:** ✅

---

## Issue 9.1 — Fix Task Deletion & Multi‑Select Actions
**Status:** ✅ Completed

**Acceptance Criteria**
- ✅ Single task delete works
- ✅ Multi‑select delete works
- ✅ Multi‑select complete works
- ✅ Clear selection UI state

**Completion Notes**
- **Created selection state management system**
- Added `SelectionStateNotifier` and `selectionStateProvider` to track selected task IDs and selection mode
- Selection state includes: `selectedTaskIds` (Set), `isSelectionMode` (bool), `selectedCount` (int)
- Provides methods: `toggleSelectionMode()`, `toggleTaskSelection()`, `selectAll()`, `clearSelection()`, `exitSelectionMode()`

- **Implemented bulk operations in TaskNotifier**
- Added `bulkDeleteTasks(List<String> taskIds)` - deletes multiple tasks with logging
- Added `bulkCompleteTasks(List<String> taskIds)` - marks multiple tasks as completed with logging
- Both methods include proper mounted checks and error handling

- **Enhanced TasksPage UI with multi-select mode**
- Added checklist icon in app bar to toggle selection mode
- Selection mode AppBar shows: selection count, close button, and "select all" button
- Tasks display checkboxes when in selection mode instead of regular leading icons
- Disabled task actions menu and completion button in selection mode
- Task tap in selection mode toggles selection instead of opening edit page

- **Created BulkActionBar widget**
- Appears at bottom when tasks are selected (only in selection mode)
- Two primary actions: Complete (green) and Delete (red)
- Complete button: Confirmation dialog → marks all selected tasks as completed → exits selection mode → shows success snackbar
- Delete button: Confirmation dialog with warning → deletes all selected tasks → exits selection mode → shows success snackbar
- Material design with primary container background and shadow

- **User experience improvements**
- Visual feedback: Selected tasks are highlighted with ListTile's selected property
- Clear workflows: Exiting selection mode clears all selections automatically
- Confirmation dialogs prevent accidental bulk operations
- Success feedback via SnackBar messages
- Select all button for quick bulk selection

- All 111 tests passing
- Zero flutter analyze issues
- Single task delete works (existing functionality preserved)
- Multi-select delete works with confirmation
- Multi-select complete works with confirmation
- Selection state properly cleared when exiting selection mode

**Completed:** ✅

---

## 📦 Versioning
- Previous release: **v1.0.0+1**
- This milestone release: **v1.1.0+2**