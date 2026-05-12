import Foundation
import Testing
@testable import Eyeballs

@Suite("TimerManager Tests")
struct TimerManagerTests {

    @Test("Activate sets active timed state")
    func activateWithSeconds() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)

        manager.activate(seconds: 600)

        #expect(manager.isActive == true)
        #expect(manager.isIndefinite == false)
        #expect(manager.countdown.formatted == "10:00")
        #expect(manager.countdown.short == "0:10")
        #expect(mock.enableCallCount == 1)

        manager.deactivate()
    }

    @Test("Activate deactivates previous session first")
    func activateDeactivatesPrevious() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)

        manager.activate(seconds: 600)
        manager.activate(seconds: 300)

        #expect(manager.isActive == true)
        #expect(manager.countdown.formatted == "5:00")
        #expect(mock.enableCallCount == 2)
        #expect(mock.disableCallCount == 2)

        manager.deactivate()
    }

    @Test("Activate does nothing when sleep prevention fails")
    func activateFailsGracefully() {
        let mock = MockSleepManager()
        mock.shouldSucceed = false
        let manager = TimerManager(sleepManager: mock)

        manager.activate(seconds: 600)

        #expect(manager.isActive == false)
        #expect(manager.isIndefinite == false)
        #expect(manager.countdown.formatted.isEmpty)
        #expect(manager.countdown.short.isEmpty)
    }

    @Test("Activate indefinitely sets correct state")
    func activateIndefinitely() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)

        manager.activateIndefinitely()

        #expect(manager.isActive == true)
        #expect(manager.isIndefinite == true)
        #expect(manager.countdown.formatted.isEmpty)
        #expect(mock.enableCallCount == 1)

        manager.deactivate()
    }

    @Test("Activate indefinitely fails gracefully")
    func activateIndefinitelyFails() {
        let mock = MockSleepManager()
        mock.shouldSucceed = false
        let manager = TimerManager(sleepManager: mock)

        manager.activateIndefinitely()

        #expect(manager.isActive == false)
        #expect(manager.isIndefinite == false)
    }

    @Test("Add time to timed session increases remaining time")
    func addTimeToTimedSession() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)

        manager.activate(seconds: 600)
        manager.addTime(seconds: 300)

        #expect(manager.countdown.formatted == "15:00")
        #expect(manager.isIndefinite == false)

        manager.deactivate()
    }

    @Test("Add time to indefinite session converts to timed")
    func addTimeToIndefiniteSession() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)

        manager.activateIndefinitely()
        manager.addTime(seconds: 600)

        #expect(manager.isIndefinite == false)
        #expect(manager.countdown.formatted == "10:00")
        #expect(manager.isActive == true)

        manager.deactivate()
    }

    @Test("Deactivate resets all state")
    func deactivateResetsState() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)

        manager.activate(seconds: 600)
        manager.deactivate()

        #expect(manager.isActive == false)
        #expect(manager.isIndefinite == false)
        #expect(manager.countdown.formatted.isEmpty)
        #expect(mock.disableCallCount == 2)
    }

    @Test("Deactivate from indefinite resets all state")
    func deactivateFromIndefinite() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)

        manager.activateIndefinitely()
        manager.deactivate()

        #expect(manager.isActive == false)
        #expect(manager.isIndefinite == false)
        #expect(manager.countdown.formatted.isEmpty)
        #expect(mock.disableCallCount == 2)
    }

    @Test("Countdown formats minutes and seconds")
    func formatMinutesSeconds() {
        let countdown = CountdownState()

        countdown.update(125)

        #expect(countdown.formatted == "2:05")
        #expect(countdown.short == "0:02")
    }

    @Test("Countdown formats hours minutes and seconds")
    func formatHoursMinutesSeconds() {
        let countdown = CountdownState()

        countdown.update(3661)

        #expect(countdown.formatted == "1:01:01")
        #expect(countdown.short == "1:01")
    }

    @Test("Countdown formats zero")
    func formatZero() {
        let countdown = CountdownState()

        countdown.update(0)

        #expect(countdown.formatted == "0:00")
        #expect(countdown.short == "0:00")
    }

    @Test("Countdown formats exactly one hour")
    func formatExactlyOneHour() {
        let countdown = CountdownState()

        countdown.update(3600)

        #expect(countdown.formatted == "1:00:00")
        #expect(countdown.short == "1:00")
    }

    @Test("Timer counts down")
    @MainActor
    func timerCountsDown() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)

        manager.activate(seconds: 3)
        pumpRunLoop(for: 1.5)

        #expect(manager.countdown.formatted == "0:02" || manager.countdown.formatted == "0:01")
        #expect(manager.isActive == true)

        manager.deactivate()
    }

    @Test("Timer auto-deactivates at zero")
    @MainActor
    func timerAutoDeactivates() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)

        manager.activate(seconds: 1)
        pumpRunLoop(for: 1.5)

        #expect(manager.isActive == false)
        #expect(manager.countdown.formatted.isEmpty)
    }

    @MainActor
    private func pumpRunLoop(for duration: TimeInterval) {
        let deadline = Date().addingTimeInterval(duration)
        while Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        }
    }
}
