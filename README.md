# Interval

Interval is a native iPhone interval timer built with SwiftUI.

## Run

1. Open `Interval.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. Run the `Interval` scheme.

The app uses the bundle identifier `com.bundsgaard.interval`. No development team is stored in the project. Xcode can assign a personal team when a physical device build needs signing.

## Lock-screen timing

The app keeps an audio session active during a workout. Phase cues therefore play while the screen is locked and when the silent switch is enabled, as long as media volume is audible. A Live Activity shows the current phase, countdown, round, and repetition on the Lock Screen and in the Dynamic Island. The timer uses absolute elapsed time, so it catches up correctly after the app returns to the foreground.

## Generated project files

Run these commands after adding source files or changing bundled resources:

```sh
swift Tools/generate_sounds.swift
ruby Tools/generate_project.rb
```
