import AppIntents

struct DeactivateEyeballsIntent: AppIntent {
    static var title: LocalizedStringResource = "Deactivate Eyeballs"
    static var description = IntentDescription("Stop keeping your Mac awake")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = TimerManager.shared
        guard manager.isActive else {
            return .result(dialog: "Eyeballs is already inactive.")
        }
        manager.deactivate()
        return .result(dialog: "Eyeballs has been deactivated.")
    }
}
