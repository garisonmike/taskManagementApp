Repository Setup Assumptions (V1)
Platform: Android only

Framework: Flutter

Architecture: Offline-first

Storage: Local device storage (SQLite / local files)

Notifications: Works when app is closed or phone restarted

Alarms: Native Android alarm clock

UI: Simple, WhatsApp-like page navigation

Themes:

Default: Timber Brown

Optional: Dark & Light (toggle)

GitHub Issues — V1
EPIC 0: Project Foundation & Architecture
Issue 0.1 — Initialize Flutter Project
Description

Create Flutter project

Configure Android-only build

Set minimum SDK to support alarms and background notifications

Acceptance Criteria

App builds and runs on Android emulator/device

Clean project structure

Issue 0.2 — Define App Architecture
Description

Decide and document:

State management (e.g. Provider / Riverpod / Bloc)

Folder structure

Separate concerns:

UI

Data

Services (notifications, alarms, storage)

Acceptance Criteria

/lib organized with clear responsibility boundaries

README updated with architecture overview

Issue 0.3 — Local Persistence Layer
Description

Implement offline-first storage

Support:

Tasks

Blueprints

Logs

Settings

Prepare for export/import later

Acceptance Criteria

Data persists across app restarts

Schema versioning supported

EPIC 1: Theming & App Shell
Issue 1.1 — App Shell & Navigation
Description

WhatsApp-like navigation

Core pages:

Tasks

Reminders

Notifications

Logs & Graphs

Meals & Fitness

Settings

Acceptance Criteria

Bottom or tab navigation

Pages load independently

Issue 1.2 — Theme System
Description

Implement theme engine:

Timber Brown (default)

Dark

Light

Toggle button in settings

Acceptance Criteria

Theme persists across restarts

UI reacts instantly to theme changes

EPIC 2: Task Management (Core)
Issue 2.1 — Task Data Model
Description

Task fields:

Title

Description (optional)

Type: unsure / deadline / specific time

Deadline (optional)

Reminder time (optional)

Completion status

Failure reason (optional)

Postponed / dropped flags

Acceptance Criteria

Model supports all task behaviors without UI dependency

Issue 2.2 — Add & Edit Tasks UI
Description

Add task screen with:

Task certainty selection

Deadline / time picker

Optional reminder

Edit existing tasks

Acceptance Criteria

No mandatory fields except title

Clean, minimal UI

Issue 2.3 — Task Completion & Failure Handling
Description

Mark task as complete

If not completed:

Optional reason

Postpone

Extend deadline

Acceptance Criteria

User can skip reason

State updates correctly in logs

EPIC 3: Notifications & Reminders
Issue 3.1 — Notification Engine
Description

Schedule reminders for tasks

Custom reminder timing (e.g. 10 minutes before)

Notifications work after reboot

Acceptance Criteria

Notification fires reliably

User controls notification text visibility

Issue 3.2 — Reminder Management Page
Description

Page to:

View today’s reminders

Browse by date

Enable/disable reminders

Acceptance Criteria

No accidental task deletion

Clear separation from task editing

Issue 3.3 — Inactivity Reminder
Description

Notify user if no tasks are set

User-defined reminder time

Acceptance Criteria

Can be disabled

Respects notification privacy settings

EPIC 4: Alarms
Issue 4.1 — Native Android Alarm Integration
Description

Create alarms using Android system alarm clock

For wake-up and similar use cases

Acceptance Criteria

Alarm appears in native clock app

Alarm survives app uninstall

EPIC 5: Blueprints & Routines
Issue 5.1 — Blueprint Data Model
Description

Blueprint:

Name

Days active

Task templates

Blueprint stored independently of daily tasks

Acceptance Criteria

Blueprint changes affect future days only

Custom daily tasks never modify blueprint

Issue 5.2 — Blueprint Editor Page
Description

Separate UI for:

Creating

Editing

Deleting blueprints

Acceptance Criteria

Editing blueprint does not touch past logs or daily overrides

Issue 5.3 — Daily Task Generation from Blueprint
Description

Generate daily tasks from selected blueprint

Allow:

Removing tasks for that day only

Adding custom tasks

Acceptance Criteria

Day-specific changes are isolated

EPIC 6: Logs & Analytics
Issue 6.1 — Immutable Logging System
Description

Log:

Task creation

Completion

Postponement

Drops

Edits

Logs are immutable by default

Acceptance Criteria

Logs persist forever unless disabled in settings

logs can be deleted in bulk by date range

Issue 6.2 — Weekly Summary Generator
Description

Every Saturday night:

Completion rate

Task breakdown

Postponed & dropped tasks

Acceptance Criteria

Runs automatically

Summary day is customizable

Accessible from logs page

Issue 6.3 — GitHub-Style Completion Graph
Description

Daily completion heatmap

Optional per-category inclusion

Acceptance Criteria

User can disable graph entirely

Graph reflects logs accurately

EPIC 7: Meals & Fitness (Separate Domain)
Issue 7.1 — Meals & Habits Module Separation
Description

Ensure meals & fitness are isolated from task logic

Optional inclusion in logs

Acceptance Criteria

No coupling with task completion stats unless enabled

Issue 7.2 — Weekly Meal Blueprint
Description

Weekly cooking timeline

Daily checklist:

Ingredients available

Meal cooked

Acceptance Criteria

Daily substitutions do not affect blueprint

Issue 7.3 — Food Data Table
Description

Excel-like table:

Default nutrition columns

Custom user-added columns

Acceptance Criteria

Columns persist

Editable without breaking existing data

EPIC 8: Settings, Privacy & Export
Issue 8.1 — Settings Engine
Description

Granular toggles:

Logs

Graphs

Meals tracking

Notification privacy

Presets + advanced mode

Acceptance Criteria

Changes apply instantly

No data loss unless explicitly confirmed

Issue 8.2 — Export & Import
Description

Export:

Tasks

Blueprints

Logs

Settings

CSV format

Acceptance Criteria

Import restores app state accurately

app data can be cleared, that is logs and summary and history. user selects what to clear, tasks, blueprints, settings etc