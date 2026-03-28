import SwiftUI

struct EyeballsMenu: View {
    @ObservedObject var timerManager: TimerManager

    var body: some View {
        if timerManager.isActive {
            activeMenu
        } else {
            inactiveMenu
        }

        Divider()

        Button("Quit Eyeballs") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    @ViewBuilder
    private var activeMenu: some View {
        if let duration = timerManager.selectedDuration {
            if duration == .indefinite {
                Text("Active — Indefinitely")
            } else {
                Text("Active — \(timerManager.remainingTimeFormatted) remaining")
            }
        }

        Button("Deactivate") {
            timerManager.deactivate()
        }
    }

    @ViewBuilder
    private var inactiveMenu: some View {
        Text("Keep Awake For:")

        ForEach(TimerManager.Duration.allCases) { duration in
            Button(duration.rawValue) {
                timerManager.activate(duration: duration)
            }
        }
    }
}
