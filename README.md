# Kyclaro

Kyclaro is a native iPhone interval timer built with SwiftUI.

## Name

Kyclaro combines the Greek *kyklos* (cycle) with *claro* (clear). The name reflects the app's purpose: to make repeated work and rest cycles clear through time, sound, vibration, and the Lock Screen. The App Store name is **Kyclaro Timer**, while the shorter **Kyclaro** appears below the app icon on the Home Screen.

## Run

1. Open `Interval.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. Run the `Interval` scheme.

The default bundle identifier is `com.bundsgaard.kyclaro`. Change `APP_BUNDLE_ID` once in the project Build Settings before another Apple Developer account publishes the app. The app, tests, and widget derive their identifiers from this value. No development team is stored in the project.

## Lock-screen timing

The app keeps an audio session active during a workout. Phase cues therefore play while the screen is locked and when the silent switch is enabled, as long as media volume is audible. A Live Activity shows the current phase, countdown, round, and repetition on the Lock Screen and in the Dynamic Island. The timer uses absolute elapsed time, so it catches up correctly after the app returns to the foreground.

## Generated project files

Run these commands after adding source files or changing bundled resources:

```sh
swift Tools/generate_sounds.swift
ruby Tools/generate_project.rb
```

## App Store release

The `AppStore` directory contains App Store metadata in English (U.S., the primary language) and Danish, plus a release checklist. The app includes a privacy manifest and does not collect data. Version and build numbers use `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the project Build Settings.

The static landing page is in `docs`. English is the default at the site root, and the Danish pages are in `docs/da`. The GitHub Pages workflow publishes it from `main` after Pages is enabled with **GitHub Actions** as its source. Replace the publisher's legal name before the App Store submission.
