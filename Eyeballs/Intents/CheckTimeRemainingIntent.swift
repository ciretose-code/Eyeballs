import AppIntents

struct CheckTimeRemainingIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Eyeballs Time Remaining"
    static var description = IntentDescription("Check how much time is left on Eyeballs")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let manager = TimerManager.shared

        guard manager.isActive else {
            return .result(dialog: "Eyeballs is not currently active.")
        }

        if manager.isIndefinite {
            return .result(dialog: "Eyeballs is active indefinitely.")
        }

        let total = Int(manager.remainingTime)
        let hours = total / 3600
        let minutes = (total % 3600) / 60

        let spokenTime: String
        if hours > 0 && minutes > 0 {
            spokenTime = "\(hours) hour\(hours == 1 ? "" : "s") and \(minutes) minute\(minutes == 1 ? "" : "s")"
        } else if hours > 0 {
            spokenTime = "\(hours) hour\(hours == 1 ? "" : "s")"
        } else if minutes > 0 {
            spokenTime = "\(minutes) minute\(minutes == 1 ? "" : "s")"
        } else {
            spokenTime = "less than a minute"
        }

        return .result(dialog: "Eyeballs has \(spokenTime) remaining.")
    }
}
