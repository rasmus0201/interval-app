# Design System

## Visual World

Interval uses the quiet visual discipline of an athletics timing board. The interface feels precise and readable at distance. Large tabular time, strict alignment, generous spacing, and persistent phase color make the workout state clear without decoration. Setup stays as close as possible to a clean native iOS form.

## Color

- Use semantic iOS backgrounds and labels for the main surfaces.
- Use system orange for active work.
- Use system blue for rest and round pauses.
- Use system green for completion and successful history entries.
- Color never carries phase meaning alone. Every colored state includes text and an SF Symbol.

## Typography

- Use San Francisco through SwiftUI text styles.
- Use monospaced digits for countdowns and measured values.
- Use strong weight changes and scale for hierarchy.
- Support Dynamic Type throughout. The active countdown may use a scaled display size because distance legibility is its primary task.

## Materials and Components

- Use native navigation bars, tab bars, lists, sheets, pickers, menus, buttons, and alerts.
- Use dark timing-board surfaces for the active workout and semantic grouped backgrounds elsewhere.
- Use aligned numeric columns and clear state bands only where they improve scanning.
- Avoid dashboard density, nested cards, decorative panels, and custom controls when a native control works.
- Keep touch targets at least 44 points.

## Motion and Feedback

- Phase transitions use one decisive color and content transition.
- Countdown changes do not animate spatially when Reduce Motion is enabled.
- Sound and haptic feedback communicate timing changes when configured.

## Navigation

- Use two top-level tabs: Træning and Historik.
- Use a navigation stack for settings and history detail.
- Present the active workout as a full-screen cover to protect focus.

## Shipped Patterns

- The setup screen uses grouped native form sections for intervals, structure, and the computed duration.
- Duration rows open wheel pickers for minutes and seconds. Count rows use native steppers.
- The active workout keeps phase, countdown, progress, reset, pause, and skip visible in one full-screen surface.
- At accessibility text sizes, pause and skip use labeled symbols to preserve the countdown area and VoiceOver names.
- History rows show the completion date and configuration. A detail view can load the same configuration into setup.

## Review

The finish review found no remaining visual or interaction regressions. Disposition: ship.
