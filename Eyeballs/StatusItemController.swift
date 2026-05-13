import AppKit
import Combine
import Foundation

@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private enum ClickKind {
        case left
        case right
    }

    private let timerManager: TimerManager
    private let launchAtLoginManager: LaunchAtLoginManager
    private let releaseCheckManager: ReleaseCheckManager
    private let defaults: UserDefaults
    private let statusItem: NSStatusItem
    private var cancellables = Set<AnyCancellable>()

    private weak var activeStatusItem: NSMenuItem?
    private weak var showRemainingTimeItem: NSMenuItem?
    private weak var launchAtLoginItem: NSMenuItem?
    private weak var checkForUpdatesItem: NSMenuItem?

    init(
        timerManager: TimerManager,
        launchAtLoginManager: LaunchAtLoginManager,
        releaseCheckManager: ReleaseCheckManager,
        defaults: UserDefaults = .standard
    ) {
        self.timerManager = timerManager
        self.launchAtLoginManager = launchAtLoginManager
        self.releaseCheckManager = releaseCheckManager
        self.defaults = defaults
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        super.init()

        configureStatusItem()
        bindState()
        updateStatusItemDisplay()
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }

        button.target = self
        button.action = #selector(handleStatusItemClick(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.imagePosition = .imageLeading
    }

    private func bindState() {
        timerManager.$isActive
            .sink { [weak self] _ in
                self?.updateStatusItemDisplay()
            }
            .store(in: &cancellables)

        timerManager.$isIndefinite
            .sink { [weak self] _ in
                self?.updateStatusItemDisplay()
                self?.updateActiveStatusItem()
            }
            .store(in: &cancellables)

        timerManager.countdown.$short
            .sink { [weak self] _ in
                self?.updateStatusItemDisplay()
            }
            .store(in: &cancellables)

        timerManager.countdown.$formatted
            .sink { [weak self] _ in
                self?.updateActiveStatusItem()
            }
            .store(in: &cancellables)

        launchAtLoginManager.$isEnabled
            .sink { [weak self] _ in
                self?.launchAtLoginItem?.state = self?.launchAtLoginManager.isEnabled == true ? .on : .off
            }
            .store(in: &cancellables)

        releaseCheckManager.$isChecking
            .sink { [weak self] isChecking in
                self?.checkForUpdatesItem?.title = isChecking ? "Checking for Updates…" : "Check for Updates…"
                self?.checkForUpdatesItem?.isEnabled = !isChecking
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.updateStatusItemDisplay()
                self?.showRemainingTimeItem?.state = EyeballsMenuContent.showRemainingTime(using: self?.defaults ?? .standard) ? .on : .off
            }
            .store(in: &cancellables)
    }

    private func updateStatusItemDisplay() {
        guard let button = statusItem.button else { return }

        let display = EyeballsMenuContent.statusItemDisplay(
            isActive: timerManager.isActive,
            isIndefinite: timerManager.isIndefinite,
            remainingShort: timerManager.countdown.short,
            showRemainingTime: EyeballsMenuContent.showRemainingTime(using: defaults)
        )

        button.image = NSImage(
            systemSymbolName: display.symbolName,
            accessibilityDescription: "Eyeballs"
        )
        button.image?.isTemplate = true
        button.imagePosition = display.title.isEmpty ? .imageOnly : .imageLeading
        button.attributedTitle = NSAttributedString(
            string: display.title,
            attributes: display.title.isEmpty ? [:] : [
                .font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
            ]
        )
    }

    private func updateActiveStatusItem() {
        activeStatusItem?.title = EyeballsMenuContent.activeStatusText(
            isIndefinite: timerManager.isIndefinite,
            remainingFormatted: timerManager.countdown.formatted
        )
    }

    @objc private func handleStatusItemClick(_ sender: Any?) {
        let clickKind: ClickKind
        if let event = NSApp.currentEvent,
           event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
            clickKind = .right
        } else {
            clickKind = .left
        }

        switch clickKind {
        case .left:
            present(menu: makePrimaryMenu())
        case .right:
            present(menu: makeSecondaryMenu())
        }
    }

    private func present(menu: NSMenu) {
        menu.delegate = self
        statusItem.popUpMenu(menu)
    }

    private func makePrimaryMenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false
        activeStatusItem = nil

        if timerManager.isActive {
            let statusItem = NSMenuItem(
                title: EyeballsMenuContent.activeStatusText(
                    isIndefinite: timerManager.isIndefinite,
                    remainingFormatted: timerManager.countdown.formatted
                ),
                action: nil,
                keyEquivalent: ""
            )
            statusItem.isEnabled = false
            menu.addItem(statusItem)
            activeStatusItem = statusItem

            menu.addItem(makeDurationMenu(title: "Add Minutes", options: EyeballsMenuContent.minuteOptions, unit: .minutes, action: #selector(addTime(_:))))
            menu.addItem(makeDurationMenu(title: "Add Hours", options: EyeballsMenuContent.hourOptions, unit: .hours, action: #selector(addTime(_:))))
            menu.addItem(makeUntilMenu(action: #selector(activateTime(_:))))
            menu.addItem(NSMenuItem.separator())

            let deactivateItem = NSMenuItem(title: "Deactivate", action: #selector(deactivate), keyEquivalent: "")
            deactivateItem.target = self
            menu.addItem(deactivateItem)
        } else {
            menu.addItem(makeDurationMenu(title: "Minutes", options: EyeballsMenuContent.minuteOptions, unit: .minutes, action: #selector(activateTime(_:))))
            menu.addItem(makeDurationMenu(title: "Hours", options: EyeballsMenuContent.hourOptions, unit: .hours, action: #selector(activateTime(_:))))
            menu.addItem(makeUntilMenu(action: #selector(activateTime(_:))))
            menu.addItem(NSMenuItem.separator())

            let indefiniteItem = NSMenuItem(title: "Indefinitely", action: #selector(activateIndefinitely), keyEquivalent: "")
            indefiniteItem.target = self
            menu.addItem(indefiniteItem)
        }

        return menu
    }

    private func makeSecondaryMenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let showRemainingTimeItem = NSMenuItem(
            title: "Show Remaining Time in Menu Bar",
            action: #selector(toggleShowRemainingTime(_:)),
            keyEquivalent: ""
        )
        showRemainingTimeItem.target = self
        showRemainingTimeItem.state = EyeballsMenuContent.showRemainingTime(using: defaults) ? .on : .off
        menu.addItem(showRemainingTimeItem)
        self.showRemainingTimeItem = showRemainingTimeItem

        let launchAtLoginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin(_:)),
            keyEquivalent: ""
        )
        launchAtLoginItem.target = self
        launchAtLoginItem.state = launchAtLoginManager.isEnabled ? .on : .off
        menu.addItem(launchAtLoginItem)
        self.launchAtLoginItem = launchAtLoginItem

        menu.addItem(NSMenuItem.separator())

        let checkForUpdatesItem = NSMenuItem(
            title: releaseCheckManager.isChecking ? "Checking for Updates…" : "Check for Updates…",
            action: #selector(checkForUpdates),
            keyEquivalent: ""
        )
        checkForUpdatesItem.target = self
        checkForUpdatesItem.isEnabled = !releaseCheckManager.isChecking
        menu.addItem(checkForUpdatesItem)
        self.checkForUpdatesItem = checkForUpdatesItem

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit Eyeballs", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    private func makeDurationMenu(
        title: String,
        options: [Int],
        unit: DurationUnit,
        action: Selector
    ) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: title)
        submenu.autoenablesItems = false

        for value in options {
            let duration = unit.seconds(for: value)
            let optionItem = NSMenuItem(
                title: unit.label(for: value),
                action: action,
                keyEquivalent: ""
            )
            optionItem.target = self
            optionItem.representedObject = NSNumber(value: duration)
            submenu.addItem(optionItem)
        }

        item.submenu = submenu
        return item
    }

    private func makeUntilMenu(action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: "Until", action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: "Until")
        submenu.autoenablesItems = false

        for option in EyeballsMenuContent.untilOptions() {
            let optionItem = NSMenuItem(title: option.label, action: action, keyEquivalent: "")
            optionItem.target = self
            optionItem.representedObject = NSNumber(value: option.seconds)
            submenu.addItem(optionItem)
        }

        item.submenu = submenu
        return item
    }

    @objc private func activateTime(_ sender: NSMenuItem) {
        guard let seconds = (sender.representedObject as? NSNumber)?.doubleValue else { return }
        timerManager.activate(seconds: seconds)
    }

    @objc private func addTime(_ sender: NSMenuItem) {
        guard let seconds = (sender.representedObject as? NSNumber)?.doubleValue else { return }
        timerManager.addTime(seconds: seconds)
    }

    @objc private func activateIndefinitely() {
        timerManager.activateIndefinitely()
    }

    @objc private func deactivate() {
        timerManager.deactivate()
    }

    @objc private func toggleShowRemainingTime(_ sender: NSMenuItem) {
        EyeballsMenuContent.toggleShowRemainingTime(using: defaults)
        sender.state = EyeballsMenuContent.showRemainingTime(using: defaults) ? .on : .off
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        launchAtLoginManager.toggle()
        sender.state = launchAtLoginManager.isEnabled ? .on : .off
    }

    @objc private func checkForUpdates() {
        releaseCheckManager.checkForUpdates()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    func menuDidClose(_ menu: NSMenu) {
        activeStatusItem = nil
        showRemainingTimeItem = nil
        launchAtLoginItem = nil
        checkForUpdatesItem = nil
    }
}

private enum DurationUnit {
    case minutes
    case hours

    func seconds(for value: Int) -> TimeInterval {
        switch self {
        case .minutes:
            return TimeInterval(value * 60)
        case .hours:
            return TimeInterval(value * 3600)
        }
    }

    func label(for value: Int) -> String {
        switch self {
        case .minutes:
            return "\(value) Minutes"
        case .hours:
            return "\(value) \(value == 1 ? "Hour" : "Hours")"
        }
    }
}
