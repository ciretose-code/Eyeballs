import Testing
import Foundation
@testable import Eyeballs

@Suite("TimerManager Tests")
struct TimerManagerTests {

    // MARK: - Activate with seconds

    @Test("Activate sets isActive and remainingTime")
    func activateWithSeconds() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)
        manager.activate(seconds: 600)

        #expect(manager.isActive == true)
        #expect(manager.isIndefinite == false)
        #expect(manager.remainingTime == 600)
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
        #expect(manager.remainingTime == 300)
        #expect(mock.enableCallCount == 2)
        // disableCallCount is 2: first activate calls deactivate (noop but still calls disable),
        // second activate calls deactivate which disables the first session
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
        #expect(manager.remainingTime == 0)
    }

    // MARK: - Activate indefinitely

    @Test("Activate indefinitely sets correct state")
    func activateIndefinitely() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)
        manager.activateIndefinitely()

        #expect(manager.isActive == true)
        #expect(manager.isIndefinite == true)
        #expect(manager.remainingTime == 0)
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

    // MARK: - Add time

    @Test("Add time to timed session increases remaining time")
    func addTimeToTimedSession() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)
        manager.activate(seconds: 600)
        manager.addTime(seconds: 300)

        #expect(manager.remainingTime == 900)
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
        #expect(manager.remainingTime == 600)
        #expect(manager.isActive == true)

        manager.deactivate()
    }

    // MARK: - Deactivate

    @Test("Deactivate resets all state")
    func deactivateResetsState() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)
        manager.activate(seconds: 600)
        manager.deactivate()

        #expect(manager.isActive == false)
        #expect(manager.isIndefinite == false)
        #expect(manager.remainingTime == 0)
        #expect(mock.disableCallCount == 2) // once from activate's deactivate, once explicit
    }

    @Test("Deactivate from indefinite resets all state")
    func deactivateFromIndefinite() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)
        manager.activateIndefinitely()
        manager.deactivate()

        #expect(manager.isActive == false)
        #expect(manager.isIndefinite == false)
        #expect(mock.disableCallCount == 2)
    }

    // MARK: - Time formatting

    @Test("Format minutes and seconds")
    func formatMinutesSeconds() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)
        manager.activate(seconds: 125)

        #expect(manager.remainingTimeFormatted == "2:05")

        manager.deactivate()
    }

    @Test("Format hours minutes seconds")
    func formatHoursMinutesSeconds() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)
        manager.activate(seconds: 3661)

        #expect(manager.remainingTimeFormatted == "1:01:01")

        manager.deactivate()
    }

    @Test("Format zero")
    func formatZero() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)

        #expect(manager.remainingTimeFormatted == "0:00")
    }

    @Test("Format exactly one hour")
    func formatExactlyOneHour() {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)
        manager.activate(seconds: 3600)

        #expect(manager.remainingTimeFormatted == "1:00:00")

        manager.deactivate()
    }

    // MARK: - Timer countdown

    @Test("Timer counts down")
    @MainActor
    func timerCountsDown() async throws {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)
        manager.activate(seconds: 3)

        // Pump the RunLoop to let the timer fire
        let deadline = Date().addingTimeInterval(1.5)
        while Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        }

        #expect(manager.remainingTime <= 2)
        #expect(manager.isActive == true)

        manager.deactivate()
    }

    @Test("Timer auto-deactivates at zero")
    @MainActor
    func timerAutoDeactivates() async throws {
        let mock = MockSleepManager()
        let manager = TimerManager(sleepManager: mock)
        manager.activate(seconds: 1)

        let deadline = Date().addingTimeInterval(1.5)
        while Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        }

        #expect(manager.isActive == false)
        #expect(manager.remainingTime == 0)
    }
}
