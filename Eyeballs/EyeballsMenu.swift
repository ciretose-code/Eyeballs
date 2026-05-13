import Foundation

struct StatusItemDisplay: Equatable {
    let symbolName: String
    let title: String
}

enum EyeballsMenuContent {
    static let showRemainingTimeInMenuBarKey = "showRemainingTimeInMenuBar"
    static let minuteOptions = [5, 10, 15, 20, 30, 40, 50]
    static let hourOptions = [1, 2, 3, 4, 5, 8, 10, 12, 15, 20, 24]

    static func statusItemDisplay(
        isActive: Bool,
        isIndefinite: Bool,
        remainingShort: String,
        showRemainingTime: Bool
    ) -> StatusItemDisplay {
        if isActive && !isIndefinite && showRemainingTime {
            return StatusItemDisplay(symbolName: "eye", title: remainingShort)
        }

        return StatusItemDisplay(
            symbolName: isActive ? "eye" : "eye.half.closed",
            title: ""
        )
    }

    static func activeStatusText(isIndefinite: Bool, remainingFormatted: String) -> String {
        if isIndefinite {
            return "Active — Indefinitely"
        }

        return "Active — \(remainingFormatted) remaining"
    }

    static func untilOptions(
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [(label: String, seconds: TimeInterval)] {
        let midnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
        let halfHour: TimeInterval = 30 * 60
        let nextBoundary = (floor(now.timeIntervalSinceReferenceDate / halfHour) + 1) * halfHour

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        var slots: [(label: String, seconds: TimeInterval)] = []
        var boundary = Date(timeIntervalSinceReferenceDate: nextBoundary)

        while boundary <= midnight {
            let seconds = boundary.timeIntervalSince(now)
            if seconds >= 60 {
                slots.append((formatter.string(from: boundary), seconds))
            }
            boundary = boundary.addingTimeInterval(halfHour)
        }

        return slots
    }

    static func showRemainingTime(using defaults: UserDefaults = .standard) -> Bool {
        guard defaults.object(forKey: showRemainingTimeInMenuBarKey) != nil else {
            return true
        }

        return defaults.bool(forKey: showRemainingTimeInMenuBarKey)
    }

    static func toggleShowRemainingTime(using defaults: UserDefaults = .standard) {
        defaults.set(!showRemainingTime(using: defaults), forKey: showRemainingTimeInMenuBarKey)
    }
}
