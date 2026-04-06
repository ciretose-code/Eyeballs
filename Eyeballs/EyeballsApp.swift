import SwiftUI

@main
struct EyeballsApp: App {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var launchAtLoginManager = LaunchAtLoginManager()

    var body: some Scene {
        MenuBarExtra {
            EyeballsMenu(timerManager: timerManager, launchAtLoginManager: launchAtLoginManager)
        } label: {
            Image(systemName: timerManager.isActive ? "eye" : "eye.slash")
        }
        .menuBarExtraStyle(.menu)
    }
}
