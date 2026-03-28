import Testing
@testable import Eyeballs

@Suite("SleepManager Tests")
struct SleepManagerTests {

    @Test("Enable sleep prevention activates assertion")
    func enableSleepPrevention() {
        let manager = SleepManager()
        let result = manager.enableSleepPrevention()
        #expect(result == true)
        #expect(manager.isAssertionActive == true)
        manager.disableSleepPrevention()
    }

    @Test("Disable sleep prevention deactivates assertion")
    func disableSleepPrevention() {
        let manager = SleepManager()
        _ = manager.enableSleepPrevention()
        manager.disableSleepPrevention()
        #expect(manager.isAssertionActive == false)
    }

    @Test("Enable when already active returns true without creating new assertion")
    func enableWhenAlreadyActive() {
        let manager = SleepManager()
        _ = manager.enableSleepPrevention()
        let result = manager.enableSleepPrevention()
        #expect(result == true)
        #expect(manager.isAssertionActive == true)
        manager.disableSleepPrevention()
    }

    @Test("Disable when not active is a no-op")
    func disableWhenNotActive() {
        let manager = SleepManager()
        manager.disableSleepPrevention()
        #expect(manager.isAssertionActive == false)
    }
}
