import SwiftUI

@main
struct EyeballsApp: App {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var launchAtLoginManager = LaunchAtLoginManager()

    var body: some Scene {
        MenuBarExtra {
            EyeballsMenu(timerManager: timerManager, launchAtLoginManager: launchAtLoginManager)
        } label: {
            if timerManager.isActive && !timerManager.isIndefinite {
                Label(timerManager.remainingTimeFormatted, systemImage: "eye")
                    .monospacedDigit()
            } else {
                Image(systemName: timerManager.isActive ? "eye" : "eye.half.closed")
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
