# Project: CraftyBay E-commerce App

## Project Overview
CraftyBay is a Flutter-based e-commerce application designed for the "Ostad" assignment. It features a modern UI, feature-driven architecture, and integrates with various services for a complete e-commerce experience.

- **Main Technologies:**
    - **Framework:** Flutter (Dart)
    - **State Management:** GetX
    - **Networking:** HTTP package (with a custom `NetworkCaller` wrapper)
    - **Backend/Services:** Firebase (Analytics, Crashlytics)
    - **Localization:** Flutter Localizations (ARB files)
    - **UI Components:** `flutter_svg`, `carousel_slider`, `pin_code_fields`
    - **Local Storage:** `shared_preferences`

- **Architecture:**
    The project follows a feature-driven modular architecture:
    - `lib/app/`: Contains global configurations, theme data (`app_theme.dart`), routing (`routes.dart`), and global controllers (`auth_controller.dart`, `language_controller.dart`).
    - `lib/core/`: Contains shared services like `NetworkCaller` and base models.
    - `lib/features/`: Each feature (e.g., `auth`, `home`, `carts`, `products`) is organized into:
        - `presentation/`: Screens, widgets, and GetX controllers.
        - `data/`: Models and potentially repositories or data sources.
    - `lib/l10n/`: Localization files (`.arb`) and generated localization classes.

## Building and Running
Navigate to the `ecommerce` directory before running these commands:

- **Get Dependencies:**
  ```bash
  flutter pub get
  ```

- **Run the App:**
  ```bash
  flutter run
  ```

- **Run Tests:**
  ```bash
  flutter test
  ```

- **Generate Localization Files:**
  ```bash
  flutter gen-l10n
  ```

- **Build APK:**
  ```bash
  flutter build apk
  ```

## Development Conventions
- **State Management:** Use GetX for state management. Controllers should be placed in the `presentation/controllers` directory of their respective features.
- **Routing:** Navigation is handled via `onGenerateRoute` in `lib/app/routes.dart`. Each screen should define a `static const String name` for routing.
- **Networking:** All API calls should use the `NetworkCaller` class in `lib/core/services/network_caller.dart` and URLs from `lib/app/urls.dart`.
- **Localization:** Strings should be defined in `lib/l10n/app_en.arb` and `app_bn.arb`. Access them using the `LocalizationExtension` (e.g., `context.l10n.key`).
- **Asset Management:** Centralized asset paths are defined in `lib/app/asset_paths.dart`.
- **Theming:** Use `AppTheme.lightThemeData` and `AppTheme.darkThemeData` defined in `lib/app/app_theme.dart`. Avoid hardcoding colors; use `AppColors`.
- **Linting:** The project uses `flutter_lints`. Ensure code passes `flutter analyze` before committing.
