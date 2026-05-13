import Foundation
import Testing
@testable import Eyeballs

@Suite("Eyeballs Menu Tests")
struct EyeballsMenuTests {

    @Test("Status item shows remaining time for active timed sessions")
    func statusItemShowsRemainingTime() {
        let display = EyeballsMenuContent.statusItemDisplay(
            isActive: true,
            isIndefinite: false,
            remainingShort: "1:05",
            showRemainingTime: true
        )

        #expect(display == StatusItemDisplay(symbolName: "eye", title: "1:05"))
    }

    @Test("Status item falls back to icon-only for inactive or hidden state")
    func statusItemShowsIconOnly() {
        let display = EyeballsMenuContent.statusItemDisplay(
            isActive: false,
            isIndefinite: false,
            remainingShort: "1:05",
            showRemainingTime: true
        )

        #expect(display == StatusItemDisplay(symbolName: "eye.half.closed", title: ""))
    }

    @Test("Show remaining time defaults to true and toggles in defaults")
    func showRemainingTimeDefaultsAndToggles() {
        let suiteName = "EyeballsMenuTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        #expect(EyeballsMenuContent.showRemainingTime(using: defaults) == true)

        EyeballsMenuContent.toggleShowRemainingTime(using: defaults)
        #expect(EyeballsMenuContent.showRemainingTime(using: defaults) == false)

        EyeballsMenuContent.toggleShowRemainingTime(using: defaults)
        #expect(EyeballsMenuContent.showRemainingTime(using: defaults) == true)
    }
}
