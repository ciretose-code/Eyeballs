# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Eyeballs is a macOS menu bar app (SwiftUI + AppKit) that prevents the display from sleeping. No external dependencies — pure Foundation, SwiftUI, AppKit, and IOKit.

## Building and Testing

Use Xcode or `xcodebuild` from the repo root:

```bash
# Build
xcodebuild -project Eyeballs.xcodeproj -scheme Eyeballs build

# Run all tests
xcodebuild -project Eyeballs.xcodeproj -scheme Eyeballs -testPlan Eyeballs test

# Run a single test file
xcodebuild -project Eyeballs.xcodeproj -scheme Eyeballs -testPlan Eyeballs test -only-testing:EyeballsTests/TimerManagerTests
```

The test suite uses Apple's native Swift Testing framework (not XCTest).

## Architecture

The app has four focused components wired together at startup:

- **`SleepManaging` protocol** — abstraction over IOKit sleep prevention; `SleepManager` is the real implementation, `MockSleepManager` is the test double
- **`TimerManager`** — owns all timer state (`@Published`); accepts a `SleepManaging` dependency; handles countdown, add-time-while-running, and indefinite mode
- **`EyeballsMenu`** — SwiftUI menu UI; observes `TimerManager` via `@ObservedObject`; renders time options (5 min – 24 hr) and Launch at Login toggle
- **`EyeballsApp`** — entry point; creates the `NSStatusItem` and populates it with `EyeballsMenu`; icon toggles between `eye` and `eye.slash` based on timer state

`LaunchAtLoginManager` wraps `SMAppService` and is called from `EyeballsMenu`.

## Key Conventions

- Inject `SleepManaging` into `TimerManager` rather than constructing it internally — keeps unit tests fast and deterministic.
- Timer state flows one way: `TimerManager` publishes state → `EyeballsMenu` reacts. Menu actions call methods on `TimerManager`.
- Sleep prevention uses `IOPMAssertion` (`kIOPMAssertionTypePreventUserIdleDisplaySleep`). Assertions are released on deactivation and in `deinit`.
- `AppIcon.icon` lives as a sibling to `Assets.xcassets`, not inside it.
