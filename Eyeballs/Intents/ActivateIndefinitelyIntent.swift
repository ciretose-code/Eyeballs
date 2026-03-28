import AppIntents

struct ActivateIndefinitelyIntent: AppIntent {
    static var title: LocalizedStringResource = "Activate Eyeballs Indefinitely"
    static var description = IntentDescription("Keep your Mac awake indefinitely")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        TimerManager.shared.activateIndefinitely()
        return .result(dialog: "Eyeballs is now active indefinitely.")
    }
}
