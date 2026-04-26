# Mobile App Overview Document

## 1. Document Purpose

This document provides a high-level overview of the current mobile application implementation for **Autotel Fleet**, based on the source code and configuration present in the codebase at the time of review. The purpose of this document is to support cyber security compliance submission and to describe the application's technology stack, functional scope, data handling approach, platform permissions, backend connectivity, and currently observable security-related controls.

This document reflects the **current implementation as observed in code**. It is intended as a factual system overview and should not be interpreted as an independent certification of compliance.

## 2. Application Identification

The mobile application is branded as **Autotel Fleet** and is implemented as a cross-platform mobile application using the **Flutter** framework. The package name in the Flutter project is `trackerapp`, while the Android application identifier is `com.autotelfleet.android`. The application version defined in the project is **1.0.9+9**.

The app targets both **Android** and **iOS** platforms. Android is built with modern SDK levels and Java/Kotlin support, while iOS is configured with a minimum deployment target of **iOS 15.0**.

## 3. Application Purpose and Business Function

Based on the codebase, Autotel Fleet is a **fleet monitoring and vehicle management mobile application**. The application allows authenticated users to log in and access vehicle and fleet-related operational information from a remote backend platform.

The app’s main business functions include:

- User login and session-based access to fleet services
- Fleet dashboard and vehicle status monitoring
- Live vehicle tracking and map-based viewing
- Historical vehicle movement and trip review
- Vehicle alerts and alert settings
- Driver management
- Vehicle expense and service management
- Task management
- Geofence-related features
- Notification handling and local reminders
- Company support and contact access
- Multi-language user interface support

## 4. Technology Stack

The current application stack is as follows:

- **Framework:** Flutter
- **Programming Language:** Dart
- **State Management:** `provider`
- **HTTP Networking:** `http`
- **Local Storage:** `shared_preferences`
- **Push Notifications:** Firebase Cloud Messaging (`firebase_core`, `firebase_messaging`)
- **Local Notifications:** `flutter_local_notifications`
- **Maps and Location:** `google_maps_flutter`, `google_maps_flutter_ios_sdk9`, `flutter_map`, `latlong2`, `geolocator`
- **Image Selection:** `image_picker`
- **Document and Chart Rendering:** Syncfusion charting, gauges, and PDF viewer packages
- **External Links and Contact Actions:** `url_launcher`
- **Text-to-Speech / Audio Alerts:** local `flutter_tts` package integration
- **Responsive UI:** `responsive_sizer`

The app uses a Flutter `MultiProvider` structure to initialize and manage core modules such as authentication, dashboard, alerts, reminders, geofencing, performance, driver management, commands, and settings.

## 5. Supported Platforms and Build Configuration

### Android

The Android application is configured with:

- Namespace: `com.autotelfleet.android`
- Target SDK: `36`
- Compile SDK: `36`
- Java compatibility: `Java 17`
- Kotlin JVM target: `17`
- MultiDex enabled

Release signing is supported through a local `key.properties` configuration if present. If the keystore is not available, the build system allows an unsigned release build.

### iOS

The iOS application is configured with:

- Minimum iOS version: `15.0`
- Native integration through CocoaPods
- Native Firebase initialization
- Native Google Maps SDK initialization

## 6. Application Architecture Overview

The mobile app follows a layered Flutter architecture. The codebase separates concerns into presentation, provider/state management, data models, repositories, utility services, and configuration resources.

The main architectural layers are:

- **View Layer:** Screens and widgets under `lib/view/` and `lib/widgets/`
- **State Management Layer:** Providers under `lib/providers/`
- **Data Access Layer:** Repositories under `lib/data/repositories/`
- **Model Layer:** Data models under `lib/data/models/`
- **Utility and Service Layer:** notification, storage, localization, validation, and session logic under `lib/utils/`
- **Configuration Layer:** endpoints, white-label data, localization resources, and native platform settings

The app initializes Firebase, local notifications, theme, reminders, language preferences, and provider instances during startup in `lib/main.dart`.

## 7. Backend and API Connectivity

The application communicates with a remote backend API hosted at:

- `https://world.autotel.pk/api`

The code shows multiple REST-style endpoints for:

- Login
- Dashboard data
- Device list and status
- Vehicle history and live tracking
- Reports generation
- Password change
- Geofence management
- Driver management
- Vehicle commands
- Device updates
- Expense and service records
- Tasks
- Manager chat
- Alert management
- Performance data
- Firebase token registration

The application primarily uses HTTPS-based requests. Authentication and session association are performed using a `user_api_hash` token which is passed to backend endpoints.

## 8. Authentication and Session Management

The application supports login using user email and password. After successful authentication, the code stores user session information locally, including the API session token and user profile details.

Observed session-related data stored locally includes:

- Login state
- `user_api_hash` authentication token
- User ID
- User name
- User email
- Phone number
- Expiration date
- Device limit
- User type
- Company profile and support information
- Notification token synchronization state

The app includes a session guard mechanism that detects invalid or expired session conditions and forces logout when required. On forced logout, the app clears locally stored session information and returns the user to the login screen.

## 9. Data Handling and Local Storage

The app uses `shared_preferences` for local persistence. Based on the code, this storage is used for application preferences as well as operational user/session information.

Examples of locally stored data include:

- Session token
- User profile fields
- Company support metadata
- Feature access flags
- Language and theme preferences
- Firebase notification token state
- Local reminder data references
- Profile image path selected from the device gallery

No secure enclave or encrypted keychain/keystore-based storage abstraction is currently visible in the reviewed Flutter layer for session token persistence. Local storage is therefore implemented through standard shared preferences mechanisms.

## 10. Core Functional Modules

### Dashboard and Fleet Monitoring

The app provides a dashboard view containing fleet status summaries, maintenance indicators, analytics cards, alert summaries, and vehicle-related operational information.

### Vehicle Tracking and Maps

The application supports map-based vehicle tracking through Google Maps and also uses `flutter_map` with OpenStreetMap tile loading in some screens. Users can review live tracking and vehicle history through map interfaces.

### Alerts and Notifications

The application receives remote push notifications through Firebase Cloud Messaging and also generates local notifications. The app includes alert-related screens, filtering options, and text-to-speech announcement logic for alert playback on supported scenarios.

### Driver, Task, Expense, and Service Management

The app includes business modules for managing drivers, vehicle expenses, services, reminders, and tasks. This indicates that the mobile application is not limited to passive tracking but also supports operational fleet workflows.

### Settings, Contact, and Localization

The app includes user settings, appearance controls, password change support, contact/company information, and localization resources for English, Urdu, and Arabic.

## 11. Mobile Platform Permissions

### Android Permissions Observed

The Android manifest currently requests the following permissions:

- Internet access
- Post notifications
- Fine location
- Coarse location
- Read media images
- Read external storage on older Android versions

The Android app also declares package and URL query support for text-to-speech services, web URLs, telephone links, email links, and selected third-party social media apps.

### iOS Permissions Observed

The iOS configuration currently declares usage descriptions for:

- Location while in use
- Photo library access
- Photo library add access

The iOS app also enables background modes for:

- Fetch
- Remote notifications
- Audio
- Processing

## 12. Notifications and Messaging

The application integrates Firebase Cloud Messaging for push notification delivery. On startup, the app requests notification permissions and attempts to synchronize the device token with the backend service.

The app supports:

- Foreground notification handling
- Background notification handling
- Notification tap processing
- Local notification channel creation
- Reminder notifications
- Alert speech playback through text-to-speech in some Android scenarios

This indicates the app is designed to support operational alerting for fleet events and scheduled reminders.

## 13. Mapping, Geolocation, and External Services

The app integrates mapping and geolocation capabilities for vehicle and alert visualization. It uses:

- Google Maps SDK
- OpenStreetMap tile services on `flutter_map`
- Device geolocation services
- External launch capability for Google Maps, phone calls, email, WhatsApp, Facebook, Instagram, and website links

The codebase contains Google Maps API keys configured in native Android and iOS startup configuration.

## 14. Security Controls Currently Observable in Code

Based on the current codebase, the following security-relevant controls or mechanisms are observable:

- Backend communication is primarily configured over HTTPS
- Session expiration handling is implemented in application logic
- Notification token registration and deletion flows are implemented
- Platform permission usage descriptions are declared
- Login access appears restricted by backend mobile access permissions
- Forced logout is triggered when session invalidation conditions are detected
- Background notification handling is explicitly registered

## 15. Security-Relevant Observations from Current Implementation

The following points are materially relevant for cyber security review because they are visible in the present code and configuration:

- The Android application manifest enables `usesCleartextTraffic="true"`.
- Android network security configuration explicitly permits cleartext traffic.
- The iOS `Info.plist` enables `NSAllowsArbitraryLoads`, which relaxes App Transport Security restrictions.
- The app stores the session token and related user data in `SharedPreferences`, which is application-local storage but not the same as dedicated encrypted secret storage.
- Google Maps API keys are embedded in native application configuration.
- The login request and password change request construct URLs with credential-related query parameters before issuing HTTP POST requests.
- Android release configuration currently has code shrinking and resource shrinking disabled.

These observations do not by themselves determine compliance status, but they are important for any authority review because they affect transport security posture, secret handling, and hardening level.

## 16. Third-Party and Cloud Dependencies

The application currently relies on the following external or third-party service categories:

- Firebase services for push messaging
- Google Maps SDK
- OpenStreetMap tile services
- Flutter and Dart package ecosystem libraries
- Syncfusion UI components

Any formal compliance submission should ensure that dependency governance, licensing, and third-party data processing considerations are documented separately if required by the reviewing authority.

## 17. Summary of Current Security Posture from Code Review

Autotel Fleet is a Flutter-based fleet operations mobile application with remote API connectivity, authenticated access, live and historical vehicle monitoring, alerting, reminders, geofencing, driver management, and task/expense/service features. The application is integrated with Firebase Cloud Messaging, Google Maps, device location services, local notifications, and local preference storage.

From a cyber security documentation perspective, the app demonstrates a defined application structure, backend-connected authenticated workflows, and implemented notification/session handling. At the same time, the present codebase shows several areas that are important to disclose and review during compliance assessment, especially cleartext transport allowances, broad iOS transport exceptions, locally stored session tokens in shared preferences, embedded API keys, and limited Android release hardening.

## 18. Codebase References Used for This Document

This document was prepared from the current implementation observed in the following project files:

- `pubspec.yaml`
- `lib/main.dart`
- `lib/res/app_endpoints.dart`
- `lib/data/repositories/auth_repository.dart`
- `lib/data/repositories/fcm_token_repository.dart`
- `lib/utils/shared_preference.dart`
- `lib/utils/session_guard.dart`
- `lib/utils/local_notification_service.dart`
- `lib/view/auth_screens/login_screen.dart`
- `lib/view/splashscreen.dart`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/xml/network_security_config.xml`
- `ios/Runner/Info.plist`
- `ios/Runner/AppDelegate.swift`
- `ios/Podfile`

