import AppIntents

struct EyeballsShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ActivateEyeballsIntent(),
            phrases: [
                "Turn on \(.applicationName) for \(\.$duration)",
                "Start \(.applicationName) for \(\.$duration)",
                "Activate \(.applicationName) for \(\.$duration)"
            ],
            shortTitle: "Activate Eyeballs",
            systemImageName: "eye"
        )

        AppShortcut(
            intent: ActivateIndefinitelyIntent(),
            phrases: [
                "Turn on \(.applicationName)",
                "Start \(.applicationName)",
                "Activate \(.applicationName)"
            ],
            shortTitle: "Activate Indefinitely",
            systemImageName: "eye"
        )

        AppShortcut(
            intent: CheckTimeRemainingIntent(),
            phrases: [
                "How much time is left on \(.applicationName)",
                "Check \(.applicationName) time remaining"
            ],
            shortTitle: "Check Time Remaining",
            systemImageName: "clock"
        )

        AppShortcut(
            intent: DeactivateEyeballsIntent(),
            phrases: [
                "Turn off \(.applicationName)",
                "Stop \(.applicationName)",
                "Deactivate \(.applicationName)"
            ],
            shortTitle: "Deactivate Eyeballs",
            systemImageName: "eye.slash"
        )
    }
}
