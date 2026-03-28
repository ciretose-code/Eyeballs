import AppIntents

enum EyeballsDuration: String, AppEnum {
    case fiveMinutes = "5 minutes"
    case tenMinutes = "10 minutes"
    case fifteenMinutes = "15 minutes"
    case twentyMinutes = "20 minutes"
    case thirtyMinutes = "30 minutes"
    case fortyMinutes = "40 minutes"
    case fiftyMinutes = "50 minutes"
    case oneHour = "1 hour"
    case twoHours = "2 hours"
    case threeHours = "3 hours"
    case fourHours = "4 hours"
    case fiveHours = "5 hours"
    case eightHours = "8 hours"
    case tenHours = "10 hours"
    case twelveHours = "12 hours"
    case fifteenHours = "15 hours"
    case twentyHours = "20 hours"
    case twentyFourHours = "24 hours"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Duration")

    static var caseDisplayRepresentations: [EyeballsDuration: DisplayRepresentation] {
        [
            .fiveMinutes: "5 Minutes",
            .tenMinutes: "10 Minutes",
            .fifteenMinutes: "15 Minutes",
            .twentyMinutes: "20 Minutes",
            .thirtyMinutes: "30 Minutes",
            .fortyMinutes: "40 Minutes",
            .fiftyMinutes: "50 Minutes",
            .oneHour: "1 Hour",
            .twoHours: "2 Hours",
            .threeHours: "3 Hours",
            .fourHours: "4 Hours",
            .fiveHours: "5 Hours",
            .eightHours: "8 Hours",
            .tenHours: "10 Hours",
            .twelveHours: "12 Hours",
            .fifteenHours: "15 Hours",
            .twentyHours: "20 Hours",
            .twentyFourHours: "24 Hours",
        ]
    }

    var seconds: TimeInterval {
        switch self {
        case .fiveMinutes: return 5 * 60
        case .tenMinutes: return 10 * 60
        case .fifteenMinutes: return 15 * 60
        case .twentyMinutes: return 20 * 60
        case .thirtyMinutes: return 30 * 60
        case .fortyMinutes: return 40 * 60
        case .fiftyMinutes: return 50 * 60
        case .oneHour: return 3600
        case .twoHours: return 2 * 3600
        case .threeHours: return 3 * 3600
        case .fourHours: return 4 * 3600
        case .fiveHours: return 5 * 3600
        case .eightHours: return 8 * 3600
        case .tenHours: return 10 * 3600
        case .twelveHours: return 12 * 3600
        case .fifteenHours: return 15 * 3600
        case .twentyHours: return 20 * 3600
        case .twentyFourHours: return 24 * 3600
        }
    }

    var spokenDescription: String {
        rawValue
    }
}

struct ActivateEyeballsIntent: AppIntent {
    static var title: LocalizedStringResource = "Activate Eyeballs"
    static var description = IntentDescription("Keep your Mac awake for a specified duration")

    @Parameter(title: "Duration")
    var duration: EyeballsDuration

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        TimerManager.shared.activate(seconds: duration.seconds)
        return .result(dialog: "Eyeballs is now active for \(duration.spokenDescription).")
    }
}
