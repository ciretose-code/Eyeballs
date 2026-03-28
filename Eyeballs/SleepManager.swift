import IOKit.pwr_mgt

protocol SleepManaging {
    var isAssertionActive: Bool { get }
    func enableSleepPrevention() -> Bool
    func disableSleepPrevention()
}

final class SleepManager: SleepManaging {
    private var assertionID: IOPMAssertionID = IOPMAssertionID(0)
    private(set) var isAssertionActive = false

    func enableSleepPrevention() -> Bool {
        guard !isAssertionActive else { return true }

        let reason = "Eyeballs is keeping your Mac awake" as CFString
        let success = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )

        isAssertionActive = (success == kIOReturnSuccess)
        return isAssertionActive
    }

    func disableSleepPrevention() {
        guard isAssertionActive else { return }
        IOPMAssertionRelease(assertionID)
        isAssertionActive = false
        assertionID = IOPMAssertionID(0)
    }
}
