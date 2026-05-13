import SwiftUI

@main
struct EyeballsApp: App {
    private let timerManager: TimerManager
    private let launchAtLoginManager: LaunchAtLoginManager
    private let releaseCheckManager: ReleaseCheckManager
    private let statusItemController: StatusItemController

    init() {
        let timerManager = TimerManager()
        let launchAtLoginManager = LaunchAtLoginManager()
        let releaseCheckManager = ReleaseCheckManager()

        self.timerManager = timerManager
        self.launchAtLoginManager = launchAtLoginManager
        self.releaseCheckManager = releaseCheckManager
        statusItemController = StatusItemController(
            timerManager: timerManager,
            launchAtLoginManager: launchAtLoginManager,
            releaseCheckManager: releaseCheckManager
        )
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
