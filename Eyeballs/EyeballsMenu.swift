import SwiftUI

private struct ActiveStatusLabel: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject private var countdown: CountdownState

    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        self.countdown = timerManager.countdown
    }

    var body: some View {
        if timerManager.isIndefinite {
            Text("Active — Indefinitely")
        } else {
            Text("Active — \(countdown.formatted) remaining")
                .monospacedDigit()
        }
    }
}

struct EyeballsMenu: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var launchAtLoginManager: LaunchAtLoginManager
    @ObservedObject var releaseCheckManager: ReleaseCheckManager
    @AppStorage("showRemainingTimeInMenuBar") private var showRemainingTime = true

    private let minuteOptions = [5, 10, 15, 20, 30, 40, 50]
    private let hourOptions = [1, 2, 3, 4, 5, 8, 10, 12, 15, 20, 24]

    /// Upcoming 30-minute boundaries from now until midnight.
    private var untilOptions: [(label: String, seconds: TimeInterval)] {
        let now = Date()
        let cal = Calendar.current
        let midnight = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: now)!)
        let halfHour: TimeInterval = 30 * 60

        let nextBoundary = (floor(now.timeIntervalSinceReferenceDate / halfHour) + 1) * halfHour
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        var slots: [(String, TimeInterval)] = []
        var t = Date(timeIntervalSinceReferenceDate: nextBoundary)
        while t <= midnight {
            let seconds = t.timeIntervalSince(now)
            if seconds >= 60 {
                slots.append((formatter.string(from: t), seconds))
            }
            t = t.addingTimeInterval(halfHour)
        }
        return slots
    }

    var body: some View {
        if timerManager.isActive {
            activeMenu
        } else {
            inactiveMenu
        }

        Divider()

        Toggle("Show Remaining Time in Menu Bar", isOn: $showRemainingTime)

        Toggle("Launch at Login", isOn: Binding(
            get: { launchAtLoginManager.isEnabled },
            set: { _ in launchAtLoginManager.toggle() }
        ))

        Button(releaseCheckManager.isChecking ? "Checking for Updates…" : "Check for Updates…") {
            releaseCheckManager.checkForUpdates()
        }
        .disabled(releaseCheckManager.isChecking)

        Divider()

        Button("Quit Eyeballs") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    @ViewBuilder
    private var activeMenu: some View {
        ActiveStatusLabel(timerManager: timerManager)

        Menu("Add Minutes") {
            ForEach(minuteOptions, id: \.self) { minutes in
                Button("\(minutes) Minutes") {
                    timerManager.addTime(seconds: TimeInterval(minutes * 60))
                }
            }
        }

        Menu("Add Hours") {
            ForEach(hourOptions, id: \.self) { hours in
                Button("\(hours) \(hours == 1 ? "Hour" : "Hours")") {
                    timerManager.addTime(seconds: TimeInterval(hours * 3600))
                }
            }
        }

        Menu("Until") {
            ForEach(untilOptions, id: \.label) { option in
                Button(option.label) {
                    timerManager.activate(seconds: option.seconds)
                }
            }
        }

        Button("Deactivate") {
            timerManager.deactivate()
        }
    }

    @ViewBuilder
    private var inactiveMenu: some View {
        Menu("Minutes") {
            ForEach(minuteOptions, id: \.self) { minutes in
                Button("\(minutes) Minutes") {
                    timerManager.activate(seconds: TimeInterval(minutes * 60))
                }
            }
        }

        Menu("Hours") {
            ForEach(hourOptions, id: \.self) { hours in
                Button("\(hours) \(hours == 1 ? "Hour" : "Hours")") {
                    timerManager.activate(seconds: TimeInterval(hours * 3600))
                }
            }
        }

        Menu("Until") {
            ForEach(untilOptions, id: \.label) { option in
                Button(option.label) {
                    timerManager.activate(seconds: option.seconds)
                }
            }
        }

        Button("Indefinitely") {
            timerManager.activateIndefinitely()
        }
    }
}
