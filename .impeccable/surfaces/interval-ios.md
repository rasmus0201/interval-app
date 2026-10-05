# Interval iOS Surface

## Direction contract

**THESIS:** One clean form starts a workout in seconds. It refuses the fitness-dashboard default.

**OWN-WORLD:** Native grouped surfaces, semantic backgrounds, orange work, blue rest, aligned tabular time, SF Symbols, and generous spacing.

**STORY:** Configure the interval, start, follow unmistakable phase cues, complete the workout, and reuse it from history.

**FIRST VIEWPORT:** A large Træning title leads into work, rest, repetition, round, and round-pause controls. A quiet duration summary follows. One wide Start træning button sits above the native two-tab bar.

**FORM:** Athletics timing board, third on the ordered grounded list, seed `3295af0f`.

**FINISH:** unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance

## Mode

Operate

## Direction

Athletics timing board.

Approved comp: `.impeccable/mocks/setup-form.png`

The active workout is the visual thesis. A large tabular countdown sits inside a strict timing field. Phase, repetition, and round align like official event data. System orange identifies work, system blue identifies rest and round pause, and semantic labels keep every state readable without color.

## First Viewport

The app opens on one clean workout form with the last configuration ready. The primary action starts the workout. During a workout, a full-screen timing surface shows phase, time, repetition, round, progress, pause, and skip controls.

## Visitor Path

Configure durations and counts, start the workout, follow audible and haptic cues, complete the session, then find it in history and load its configuration again.

## Signature Interaction

The entire timing field changes phase in one controlled transition. The time stays fixed in place while label, symbol, and accent color update together.

## Cross-Surface Reach

The same fixed numeric alignment and phase colors organize setup values, history rows, settings, and completion summaries.

## Raised Disciplines

- Split-flap board: fixed columns prevent values from jumping as time changes.
- Transit diagram: the workout sequence remains visible as a clear route through phases.
- Boarding gate board: changed state persists long enough to be noticed.

## Risk

A dark timing surface can feel like a generic fitness app. Native controls, semantic colors, strict numeric alignment, and restrained accent use keep the direction specific and trustworthy.

## Shipped Result

The app implements the approved setup as a native SwiftUI form. The active workout uses a full-screen timing field with explicit reset, pause, and skip controls. Light mode, dark mode, and accessibility text sizes were checked in the iPhone simulator.

Finish review disposition: `ship`.
