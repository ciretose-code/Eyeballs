@testable import Eyeballs

final class MockSleepManager: SleepManaging {
    private(set) var isAssertionActive = false
    var shouldSucceed = true
    var enableCallCount = 0
    var disableCallCount = 0

    func enableSleepPrevention() -> Bool {
        enableCallCount += 1
        if shouldSucceed {
            isAssertionActive = true
        }
        return shouldSucceed
    }

    func disableSleepPrevention() {
        disableCallCount += 1
        isAssertionActive = false
    }
}
