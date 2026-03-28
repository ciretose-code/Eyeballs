import SwiftUI

@main
struct EyeballsApp: App {
    @StateObject private var timerManager = TimerManager()

    var body: some Scene {
        MenuBarExtra {
            EyeballsMenu(timerManager: timerManager)
        } label: {
            Image(systemName: timerManager.isActive ? "eye" : "eye.slash")
        }
        .menuBarExtraStyle(.menu)
    }
}
