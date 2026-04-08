import Foundation
import Combine
import AppKit
import UserNotifications

final class TimerManager: ObservableObject {
    @Published var isActive = false
    @Published var remainingTime: TimeInterval = 0
    @Published var isIndefinite = false

    private let sleepManager: SleepManaging
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

    func activate(seconds: TimeInterval) {
        deactivate()

        guard sleepManager.enableSleepPrevention() else { return }

        isActive = true
        isIndefinite = false
        remainingTime = seconds
        scheduleExpiryNotification(in: seconds)

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.remainingTime -= 1
            if self.remainingTime <= 0 {
                self.deactivate()
            }
        }
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
            scheduleExpiryNotification(in: seconds)
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.remainingTime -= 1
                if self.remainingTime <= 0 {
                    self.deactivate()
                }
            }
        } else {
            remainingTime += seconds
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
