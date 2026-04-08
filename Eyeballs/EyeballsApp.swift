import SwiftUI

private struct MenuBarLabel: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var countdown: CountdownState
    let showRemainingTime: Bool

    init(timerManager: TimerManager, showRemainingTime: Bool) {
        self.timerManager = timerManager
        self.countdown = timerManager.countdown
        self.showRemainingTime = showRemainingTime
    }

    var body: some View {
        if timerManager.isActive && !timerManager.isIndefinite && showRemainingTime {
            HStack(spacing: 4) {
                Image(systemName: "eye")
                Text(countdown.short)
                    .monospacedDigit()
            }
        } else {
            Image(systemName: timerManager.isActive ? "eye" : "eye.half.closed")
        }
    }
}

@main
struct EyeballsApp: App {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var launchAtLoginManager = LaunchAtLoginManager()
    @AppStorage("showRemainingTimeInMenuBar") private var showRemainingTime = true

    var body: some Scene {
        MenuBarExtra {
            EyeballsMenu(timerManager: timerManager, launchAtLoginManager: launchAtLoginManager)
        } label: {
            MenuBarLabel(timerManager: timerManager, showRemainingTime: showRemainingTime)
        }
        .menuBarExtraStyle(.menu)
    }
}
