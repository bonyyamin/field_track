# Field Tracker 📍

A production-ready, enterprise-grade Flutter mobile application designed for field force management, location tracking, automated geofence monitoring, task management, and offline-first background synchronization.

Built adhering strictly to **Clean Architecture** principles, the **BLoC (Business Logic Component)** pattern, and reactive offline storage with **Hive** and **WorkManager**.

---

## 📋 Table of Contents
1. [Executive Summary & Features](#-executive-summary--features)
2. [Architecture & Project Structure](#-architecture--project-structure)
3. [State Management (BLoC / Cubit)](#-state-management-bloc--cubit)
4. [API Integration & Network Layer](#-api-integration--network-layer)
5. [Offline Synchronization Strategy](#-offline-synchronization-strategy)
6. [Geofencing, Background Location & Notifications](#-geofencing-background-location--notifications)
7. [Error Handling & Edge Case Management](#-error-handling--edge-case-management)
8. [UI & Design System](#-ui--design-system)
9. [Engineering Assumptions & Design Decisions](#-engineering-assumptions--design-decisions)
10. [Feature Matrix & Completed vs. Remaining Work](#-feature-matrix--completed-vs-remaining-work)
11. [Setup & Execution Guide](#-setup--execution-guide)

---

## 🌟 Executive Summary & Features

**Field Tracker** solves critical operational challenges for remote field teams operating in unpredictable network environments. Field workers can track assigned locations, trigger automated geofence notifications, manage task checklists offline, and automatically synchronize data when network connectivity resumes.

### Core Capabilities:
- 🔐 **Secure Authentication**: JWT-based login/registration with secure token storage in Android Keystore / iOS Keychain (`flutter_secure_storage`).
- 📍 **Location & Geofencing**: Real-time GPS tracking and geofence evaluation engine with boundary hysteresis protection.
- 🔄 **Offline-First Synchronization**: Local mutation queueing with optimistic UI updates and background synchronization via `WorkManager`.
- 🔔 **Local Notifications**: Immediate notifications when entering or exiting active geofence boundaries and upon sync completion.
- 📋 **Field Task Management**: Complete Todo management with status filters and progress tracking.
- ⚙️ **Customizable Settings & Theme**: Dynamic light/dark theme toggling, configurable GPS accuracy modes, and sync preferences.

---

## 🏗️ Architecture & Project Structure

The project strictly implements Uncle Bob's **Clean Architecture** decoupled into three distinct layers (*Presentation*, *Domain*, and *Data*), alongside a shared `core` module.

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                   │
│         (UI Widgets, Pages, BLoCs, Cubits, Routing)     │
└────────────────────────────┬────────────────────────────┘
                             │ (Depends on Domain)
                             ▼
┌─────────────────────────────────────────────────────────┐
│                      Domain Layer                       │
│      (Entities, Repository Contracts, Use Cases)        │
└────────────────────────────▲────────────────────────────┘
                             │ (Implemented by Data)
┌─────────────────────────────────────────────────────────┐
│                       Data Layer                        │
│   (Repository Impls, Remote/Local Data Sources, Models) │
└─────────────────────────────────────────────────────────┘
```

### Key Principles Applied:
- **Dependency Inversion**: Domain layer has zero dependencies on Flutter framework or external packages. Data layer implements domain repository contracts.
- **Single Responsibility Principle (SRP)**: Each UseCase encapsulates a single business operation (e.g., `ToggleTodoUseCase`, `GetProfileStatsUseCase`).
- **Dependency Injection**: Centralized service locator using `get_it` and compile-time injection via `injectable`.

### 📂 Directory Structure Overview

```
lib/
├── app.dart                           # Root FieldTrackApp widget & theme provider
├── main.dart                          # Application bootstrap, Hive & WorkManager init
├── core/                              # Cross-cutting core infrastructure
│   ├── constants/                     # API endpoints, design tokens & app constants
│   ├── di/                            # GetIt service locator & Injectable setup
│   ├── error/                         # Exceptions, Failures & ErrorMapper
│   ├── network/                       # Dio client, Auth/Connectivity/Log Interceptors
│   ├── router/                        # GoRouter navigation configuration & route names
│   ├── services/                      # Background tasks, Geofence & Notification engines
│   │   ├── geofence/                  # GeofenceService, Cache & Background Task
│   │   ├── notification/              # NotificationService & Permission Handlers
│   │   └── sync/                      # SyncService & Background Sync Task
│   ├── storage/                       # LocalDatabase (Hive boxes) & SecureStorageService
│   ├── theme/                         # AppTheme, AppColors, AppTextStyles & AppSpacing
│   ├── usecase/                       # Base UseCase abstract class
│   └── widgets/                       # Shared UI components (AppScaffold, OfflineBanner, etc.)
└── features/                          # Feature Modules (Clean Architecture per feature)
    ├── auth/                          # Login, Register, User entities & auth state
    ├── locations/                     # Geofence location list, Add/Edit pages & Geofence BLoC
    ├── profile/                       # User profile, statistics, help & notifications config
    ├── settings/                      # App preferences Cubit (Theme, GPS modes, Sync toggles)
    ├── splash/                        # Animated splash screen & auth checking
    ├── sync/                          # Pending sync dashboard & sync status stream BLoC
    └── todos/                         # Task checklist, offline mutations & todo BLoC
```

---

## ⚡ State Management (BLoC / Cubit)

State management is handled using `flutter_bloc` combined with `equatable` for value-based equality checking.

### BLoC Architecture & Responsibilities:

| BLoC / Cubit | Scope & Purpose | Key States |
|---|---|---|
| `AuthBloc` | User authentication lifecycle, login/register requests, session persistence | `AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`, `AuthError` |
| `LocationBloc` | Loading geofence locations, adding/editing fences, toggling active states | `LocationInitial`, `LocationLoading`, `LocationLoaded`, `LocationError` |
| `TodoBloc` | Fetching tasks, optimistic toggles, offline change queueing | `TodoInitial`, `TodoLoading`, `TodoLoaded`, `TodoError` |
| `SyncBloc` | Monitoring network connectivity, tracking pending changes, executing manual sync | `SyncInitial`, `SyncStatusUpdated`, `SyncingInProgress`, `SyncSuccess`, `SyncFailure` |
| `ProfileBloc` | User stats computation (completed tasks, active geofences) | `ProfileInitial`, `ProfileLoading`, `ProfileLoaded`, `ProfileError` |
| `SettingsCubit` | Global application preferences (ThemeMode, GPS accuracy mode) | `SettingsState` |

---

## 🌐 API Integration & Network Layer

The application utilizes `dio` configured with standard custom interceptors for resilient network communication:

1. **`AuthInterceptor`**: Automatically attaches JWT Bearer tokens from `FlutterSecureStorage` to outgoing requests and handles unauthorized (`401`) errors.
2. **`ConnectivityInterceptor`**: Checks network availability before firing HTTP requests to prevent unnecessary network timeouts when offline.
3. **`LoggingInterceptor`**: Logs request/response payloads in debug builds for diagnostics.

### Remote & Local Datasource Fallback Strategy:
- When network connectivity is active, the app attempts remote API requests via `RemoteDataSource`.
- Responses are cached into local **Hive** storage.
- If network requests fail or the device is offline, `LocalDataSource` serves cached data seamlessly, ensuring zero app crashes or blank screens.

---

## 🔄 Offline Synchronization Strategy

The application features a robust **Offline-First Synchronization Pipeline**:

```
[ User Action (e.g. Toggle Todo) ]
               │
               ▼
   [ Save to Local Hive Box ] ──(Optimistic UI Update)──► [ UI Renders Instantly ]
               │
               ▼
[ Write to PendingChanges Hive Box ]
               │
               ▼
     [ Network Listener / WorkManager ]
               │
      (Online Detected)
               ▼
[ SyncService Batch Flushes Pending Queue to API ] ──► [ Mark Synced & Clear Queue ]
```

### Offline Engine Components:
1. **Optimistic Updates**: User actions update local state immediately for instant feedback.
2. **Pending Mutation Queue**: Local modifications (creates, updates, toggles) are written to a specialized `pending_changes` Hive box.
3. **Automated Background Sync**:
   - **`SyncService`**: Listens to network connectivity changes (`connectivity_plus`). When transitioning from offline to online, it automatically initiates batch synchronization.
   - **`WorkManager`**: Registers a periodic background task (`kSyncTaskName`) running every 15 minutes when `NetworkType.connected` is satisfied.
4. **Conflict Resolution**: Mutations use client timestamps and unique entity identifiers. In case of concurrent updates, the latest local mutation takes precedence.

---

## 🛰️ Geofencing, Background Location & Notifications

### 1. Geofence Evaluation Engine (`GeofenceService`)
- Evaluates device current position against registered active geofences.
- **Hysteresis Protection**: Integrates a configurable boundary buffer (`AppConstants.geofenceHysteresisMeters = 30m`) to prevent notification toggling/spamming when a user lingers on the perimeter of a geofence.

### 2. Background Location Processing (`BackgroundLocationTask`)
- Utilizes `WorkManager` to run periodic background checks (`kGeofenceTaskName`) every 15 minutes.
- Evaluates cached geofence coordinates against `Geolocator.getCurrentPosition()`.
- Dynamically adjusts GPS accuracy based on user settings (`High`, `Balanced`, or `Battery Saver`).

### 3. Notification Dispatch (`NotificationService`)
- Configured via `flutter_local_notifications` with dedicated Android Notification Channels (`field_tracker_geofence_channel`).
- Dispatches instant alerts when:
  - Entering a geofence zone: *"Entered [Location Name]"*
  - Synchronizing offline changes successfully.

### 4. Permission Management
- Modular permission handlers (`LocationPermissionHandler`, `NotificationPermissionHandler`) gracefully handle system permission requests (`WhenInUse`, `Always`, `Notifications`) and direct users to system settings if denied.

---

## 🛡️ Error Handling & Edge Case Management

The codebase implements standardized, type-safe error handling across all layers:

```
[ Data Source Exception ] ──► [ ErrorMapper ] ──► [ Domain Failure ] ──► [ UI State Error ]
  (DioException / CacheException)                   (ServerFailure / NetworkFailure)
```

- **`Exceptions`**: Data layer abstractions (`ServerException`, `CacheException`, `NetworkException`, `UnauthorizedException`).
- **`Failures`**: Domain layer abstractions subclassing `Equatable` (`ServerFailure`, `CacheFailure`, `NetworkFailure`).
- **`ErrorMapper`**: Maps raw exceptions into clean, user-friendly localized error strings shown via `AppToast` or `ErrorView`.

---

## 🎨 UI & Design System

The application features a modern Material 3 design system with dynamic light and dark theme support (`AppTheme`).

### Key Design Tokens:
- **Palette (`AppColors`)**:
  - Primary: Deep Indigo (`#2563EB`)
  - Accent: Emerald Green (`#10B981`)
  - Warning/Pending: Amber (`#F59E0B`)
  - Error: Coral Red (`#EF4444`)
- **Typography (`AppTextStyles`)**: Clean hierarchy using Google Fonts (`Inter`).
- **Shared Components**:
  - `OfflineBanner`: Non-intrusive banner indicating offline status.
  - `StatusBadge`: Color-coded badge for active/inactive/pending states.
  - `LocationCard` & `TodoProgressCard`: Interactive cards with progress bars and smooth state transitions.

---

## 💡 Engineering Assumptions & Design Decisions

1. **Hive for Storage**: Chosen over SQLite/Drift for its lightweight key-value speed, zero native toolchain compilation overhead, and seamless object serialization.
2. **WorkManager for Background Tasks**: Selected for cross-platform background execution that respects native OS battery optimizations (Android Doze mode / iOS background fetch).
3. **Optimistic UI Updates**: Prioritized immediate UI responsiveness over awaiting server responses, critical for field workers with intermittent network access.
4. **Geofence Hysteresis**: Added a 30-meter buffer zone around geofence boundaries to eliminate false enter/exit triggers caused by GPS drift.

---

## 📊 Feature Matrix & Completed vs. Remaining Work

| Feature Module | Status | Technical Implementation Details |
|---|---|---|
| Clean Architecture & DI | ✅ Complete | Full decoupling, `get_it` + `injectable` container |
| State Management (BLoC) | ✅ Complete | Complete coverage with `AuthBloc`, `LocationBloc`, `TodoBloc`, `SyncBloc`, `ProfileBloc`, `SettingsCubit` |
| Authentication & Security | ✅ Complete | Form validation, JWT storage in `FlutterSecureStorage` |
| Geofencing Engine | ✅ Complete | `GeofenceService` with distance evaluation & hysteresis buffer |
| Background Tracking | ✅ Complete | `WorkManager` periodic tasks with configurable GPS accuracy modes |
| Local Notifications | ✅ Complete | `flutter_local_notifications` for geofence triggers & sync progress |
| Offline Sync Engine | ✅ Complete | Pending change queueing in Hive + auto sync on reconnect |
| Settings & Design System | ✅ Complete | Material 3 light/dark mode, custom design tokens, responsive widgets |
| Live Interactive Map Tiles | ⏳ Planned Roadmap | Currently represented by location lists & coordinate inputs; Google Maps / Mapbox SDK integration planned for v1.1. |
| Remote Push Server Sync | ⏳ Planned Roadmap | Local notifications fully active; Firebase Cloud Messaging (FCM) server trigger integration planned for backend deployment. |

---

## 🚀 Setup & Execution Guide

### Prerequisites
- **Flutter SDK**: `>= 3.12.1`
- **Dart SDK**: `>= 3.0.0`
- **Android Studio / Xcode** for device emulation.

### 1. Environment Configuration
Create a `.env` file in the root directory of the project:

```env
BASE_URL=https://api.example.com
```

> **Note**: `.env` is listed in `.gitignore` and must not be committed to source control.

### 2. Dependency Installation & Code Generation
Run the following commands:

```bash
# Fetch dependencies
flutter pub get

# Generate freezed models, injectable DI configs, and Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Running the Application

```bash
# Run on an active emulator or connected device
flutter run
```

### 4. Code Quality & Automated Testing

```bash
# Run static code analysis
flutter analyze

# Run unit and widget tests
flutter test
```

### 5. Building Release Binaries

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS Bundle
flutter build ios --release
```

---

## 📄 License & Ownership
Developed with ownership mindset for **Progressive Byte Ltd.** field tracking requirements.