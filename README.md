# Eyeballs

A lightweight macOS menu bar app that prevents your display from sleeping.

**[ciretose.com/eyeballs](https://ciretose.com/eyeballs/)**

## What it does

Eyeballs sits in your menu bar and uses an IOKit power assertion to keep your display awake for a chosen duration. Click the icon to set a timer — by minutes (5–50), hours (1–24), until a specific half-hour boundary before midnight, or indefinitely. While active, the icon changes and the remaining time is shown in the menu bar. You can add more time while a timer is already running, or deactivate it at any time.

## Requirements

- macOS 13 Ventura or later
- Xcode 15 or later (to build from source)

## Building from source

```bash
# Clone the repo
git clone https://github.com/ciretose-code/Eyeballs.git
cd Eyeballs

# Build
xcodebuild -project Eyeballs.xcodeproj -scheme Eyeballs build

# Run tests
xcodebuild -project Eyeballs.xcodeproj -scheme Eyeballs -testPlan Eyeballs test
```

Open `Eyeballs.xcodeproj` in Xcode to build and run directly.

## Architecture

| Component | Role |
|---|---|
| `SleepManager` | Wraps IOKit (`IOPMAssertion`) to prevent display sleep; conforms to `SleepManaging` for testability |
| `TimerManager` | Owns all timer state (`@Published`); handles countdown, add-time-while-running, and indefinite mode |
| `EyeballsMenu` | SwiftUI menu UI; observes `TimerManager`; renders time options and the Launch at Login toggle |
| `EyeballsApp` | Entry point; creates the `NSStatusItem`; toggles the icon between `eye` and `eye.slash` |
| `LaunchAtLoginManager` | Wraps `SMAppService` to register/unregister the app as a login item |

No external dependencies — pure Foundation, SwiftUI, AppKit, and IOKit.

## License

See [LICENSE](LICENSE).