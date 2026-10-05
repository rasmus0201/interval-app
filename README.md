# Kyclaro

Kyclaro is a native iPhone interval timer built with SwiftUI.

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

The `AppStore` directory contains Danish metadata and a release checklist. The app includes a privacy manifest and does not collect data. Version and build numbers use `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the project Build Settings.

The static landing page is in `docs`. The GitHub Pages workflow publishes it from `main` after Pages is enabled with **GitHub Actions** as its source. Replace the publisher's legal name before the App Store submission.
