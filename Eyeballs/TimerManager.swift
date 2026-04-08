import Foundation
import Combine
import AppKit
import UserNotifications

// Isolated countdown state so only leaf views re-render each tick,
// leaving EyeballsMenu.body (and the NSMenu structure) untouched.
final class CountdownState: ObservableObject {
    @Published private(set) var formatted: String = ""
    @Published private(set) var short: String = ""

    func update(_ remainingTime: TimeInterval) {
        let total = Int(remainingTime)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        formatted = h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
        short = String(format: "%d:%02d", h, m)
    }

    func clear() {
        formatted = ""
        short = ""
    }
}

final class TimerManager: ObservableObject {
    @Published var isActive = false
    @Published var isIndefinite = false

    let countdown = CountdownState()

    private let sleepManager: SleepManaging
    private var remainingTime: TimeInterval = 0
    private var timer: Timer?
    private var notificationObserver: Any?

    init(sleepManager: SleepManaging = SleepManager()) {
        self.sleepManager = sleepManager
        notificationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.deactivate()
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        deactivate()
    }

    func activate(seconds: TimeInterval) {
        deactivate()

        guard sleepManager.enableSleepPrevention() else { return }

        isActive = true
        isIndefinite = false
        remainingTime = seconds
        countdown.update(seconds)
        scheduleExpiryNotification(in: seconds)

        timer = makeCountdownTimer()
    }

    func activateIndefinitely() {
        deactivate()

        guard sleepManager.enableSleepPrevention() else { return }

        isActive = true
        isIndefinite = true
    }

    func addTime(seconds: TimeInterval) {
        if isIndefinite {
            isIndefinite = false
            remainingTime = seconds
            countdown.update(seconds)
            scheduleExpiryNotification(in: seconds)
            timer = makeCountdownTimer()
        } else {
            remainingTime += seconds
            countdown.update(remainingTime)
            scheduleExpiryNotification(in: remainingTime)
        }
    }

    func deactivate() {
        timer?.invalidate()
        timer = nil
        sleepManager.disableSleepPrevention()
        cancelExpiryNotification()
        isActive = false
        isIndefinite = false
        remainingTime = 0
        countdown.clear()
    }

    // MARK: - Timer

    /// Scheduled on `.common` so it fires during menu tracking (event-tracking run loop mode).
    private func makeCountdownTimer() -> Timer {
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.remainingTime -= 1
            self.countdown.update(self.remainingTime)
            if self.remainingTime <= 0 {
                self.deactivate()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        return t
    }

    // MARK: - Notifications

    private func scheduleExpiryNotification(in seconds: TimeInterval) {
        cancelExpiryNotification()
        let warningAt = seconds - 60
        guard warningAt > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Eyeballs"
        content.body = "Screen will sleep in 1 minute."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: warningAt, repeats: false)
        let request = UNNotificationRequest(identifier: "eyeballs.expiry", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelExpiryNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["eyeballs.expiry"])
    }
}
