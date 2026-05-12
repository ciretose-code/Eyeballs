# Copilot Instructions

## Build and test

- Build the app from the repo root with `xcodebuild -project Eyeballs.xcodeproj -scheme Eyeballs build`
- Run the full test plan with `xcodebuild -project Eyeballs.xcodeproj -scheme Eyeballs -testPlan Eyeballs test`
- Run a single test file with `xcodebuild -project Eyeballs.xcodeproj -scheme Eyeballs -testPlan Eyeballs test -only-testing:EyeballsTests/TimerManagerTests`
- Tests use Apple's Swift Testing framework (`import Testing`), not XCTest

## High-level architecture

- Eyeballs is a macOS menu bar app built with SwiftUI, AppKit, Foundation, UserNotifications, ServiceManagement, and IOKit; it has no third-party dependencies
- `EyeballsApp` is the composition root. It owns the shared `TimerManager` and `LaunchAtLoginManager`, then wires them into `MenuBarExtra` for both the menu content and the menu bar label
- `TimerManager` owns the app's runtime behavior: activating and deactivating sleep prevention, switching between timed and indefinite modes, driving the countdown timer, scheduling the one-minute expiry notification, and cleaning up on app termination
- `CountdownState` is intentionally separate from `TimerManager` so only leaf views that display remaining time re-render every second; keep ticking display state there instead of on the entire menu view
- `EyeballsMenu` is the action surface. It renders fixed minute/hour presets, computes dynamic `Until` choices at 30-minute boundaries through midnight, and routes user actions back into `TimerManager`
- `SleepManaging` isolates the IOKit assertion layer. `SleepManager` is the real implementation and `MockSleepManager` is the test double used by `TimerManagerTests`
- `LaunchAtLoginManager` is a thin `SMAppService` wrapper used only for the Launch at Login toggle in the menu

## Key conventions

- Keep `SleepManaging` injected into `TimerManager`; the default initializer can supply `SleepManager`, but call sites and tests should rely on the protocol for determinism
- State flows one way: `TimerManager` publishes state, SwiftUI views observe it, and menu actions call methods back on the manager
- Countdown timers must be added to the main run loop in `.common` mode so they continue firing while the menu is being tracked
- Sleep prevention must always be released on deactivation and in teardown paths; `TimerManager` also listens for `NSApplication.willTerminateNotification` to ensure cleanup
- The menu bar's remaining-time preference is shared through `@AppStorage("showRemainingTimeInMenuBar")` in both `EyeballsApp` and `EyeballsMenu`; keep that storage key aligned across both entry points
- `AppIcon.icon` is a top-level project resource next to `Assets/`, not part of an asset catalog
