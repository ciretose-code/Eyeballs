import Foundation
import Combine
import AppKit

final class TimerManager: ObservableObject {
    enum Duration: String, CaseIterable, Identifiable {
        case fifteenMinutes = "15 Minutes"
        case thirtyMinutes = "30 Minutes"
        case oneHour = "1 Hour"
        case twoHours = "2 Hours"
        case fourHours = "4 Hours"
        case indefinite = "Indefinitely"

        var id: String { rawValue }

        var seconds: TimeInterval? {
            switch self {
            case .fifteenMinutes: return 15 * 60
            case .thirtyMinutes: return 30 * 60
            case .oneHour: return 60 * 60
            case .twoHours: return 2 * 60 * 60
            case .fourHours: return 4 * 60 * 60
            case .indefinite: return nil
            }
        }
    }

    @Published var isActive = false
    @Published var remainingTime: TimeInterval = 0
    @Published var selectedDuration: Duration?

    private let sleepManager = SleepManager()
    private var timer: Timer?
    private var notificationObserver: Any?

    init() {
        notificationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.deactivate()
        }
    }

    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        deactivate()
    }

    var remainingTimeFormatted: String {
        let total = Int(remainingTime)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    func activate(duration: Duration) {
        deactivate()

        guard sleepManager.enableSleepPrevention() else { return }

        isActive = true
        selectedDuration = duration

        if let seconds = duration.seconds {
            remainingTime = seconds
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.remainingTime -= 1
                if self.remainingTime <= 0 {
                    self.deactivate()
                }
            }
        }
    }

    func deactivate() {
        timer?.invalidate()
        timer = nil
        sleepManager.disableSleepPrevention()
        isActive = false
        remainingTime = 0
        selectedDuration = nil
    }
}
