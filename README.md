# Task Management App

An offline-first Android task management application built with Flutter.

## Features

- Offline-first architecture with local persistence
- Task management with multiple task types (Unsure, Deadline, Time-based)
- Reminders and notifications
- Blueprint system for recurring tasks
- Weekly summaries and analytics
- Meals and fitness tracking
- Dark and Light themes with Timber Brown default
- Data export and import

## Architecture

This project follows **Clean Architecture** principles to ensure maintainability, testability, and separation of concerns.

### Project Structure

```
lib/
├── core/                   # Core application components
│   ├── constants/         # App-wide constants
│   ├── errors/            # Error definitions and handlers
│   ├── theme/             # Theme configuration (Dark/Light/Timber Brown)
│   └── utils/             # Utility functions and helpers
│
├── data/                   # Data layer (Framework & Drivers)
│   ├── datasources/       # Data sources (Local DB, APIs)
│   ├── models/            # Data models (JSON serialization)
│   └── repositories/      # Repository implementations
│
├── domain/                 # Business logic layer (Entities & Use Cases)
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business use cases
│
└── presentation/           # Presentation layer (UI)
    ├── pages/             # App screens/pages
    ├── providers/         # State management (Provider/Riverpod)
    └── widgets/           # Reusable UI components
```

### Architecture Layers

#### 1. **Presentation Layer** (`presentation/`)
- Contains all UI components (pages, widgets)
- Manages state using **Riverpod** (StateNotifier/AsyncNotifier)
- Uses feature-scoped providers
- Immutable state only
- No business logic in widgets (delegated to use cases)
- Interacts with domain layer through use cases
- **Dependency**: Domain layer only

#### 2. **Domain Layer** (`domain/`)
- Core business logic and entities
- Repository interfaces (contracts)
- Use cases (application-specific business rules)
- **Dependency**: None (completely independent)

#### 3. **Data Layer** (`data/`)
- Repository implementations
- Data models with serialization/deserialization
- Data sources (local database, shared preferences)
- **Dependency**: Domain layer only

#### 4. **Core Layer** (`core/`)
- Shared utilities and constants
- Theme configuration
- Error handling
- **Dependency**: None (used by all layers)

### Design Principles

1. **Dependency Rule**: Dependencies point inward (Presentation → Domain ← Data)
2. **Separation of Concerns**: Each layer has a single, well-defined responsibility
3. **Testability**: Business logic is isolated and easily testable
4. **Offline-First**: All data operations work offline by default
5. **Immutability**: Entities and models are immutable where possible

## Getting Started

### Prerequisites

- Flutter SDK 3.35.7 or higher
- Dart SDK 3.9.2 or higher
- Android SDK with minimum API level 21

### Installation

```bash
# Get dependencies
flutter pub get

# Build and run
flutter run

# Build APK
flutter build apk --release
```

### Development

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **Architecture**: Clean Architecture
- **State Management**: Riverpod (StateNotifier/AsyncNotifier)
- **Local Storage**: sqflite / Hive (to be determined)
- **Notifications**: flutter_local_notifications
- **Platform**: Android only

## Contributing

This is a private project. Please follow the development plan in `plan.md`.

## License

See LICENSE file for details.

