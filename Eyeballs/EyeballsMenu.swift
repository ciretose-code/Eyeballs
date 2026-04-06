import SwiftUI

struct EyeballsMenu: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var launchAtLoginManager: LaunchAtLoginManager

    private let minuteOptions = [5, 10, 15, 20, 30, 40, 50]
    private let hourOptions = [1, 2, 3, 4, 5, 8, 10, 12, 15, 20, 24]

    var body: some View {
        if timerManager.isActive {
            activeMenu
        } else {
            inactiveMenu
        }

        Divider()

        Button {
            launchAtLoginManager.toggle()
        } label: {
            if launchAtLoginManager.isEnabled {
                Label("Launch at Login", systemImage: "checkmark")
            } else {
                Text("Launch at Login")
            }
        }

        Divider()

        Button("Quit Eyeballs") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    @ViewBuilder
    private var activeMenu: some View {
        if timerManager.isIndefinite {
            Text("Active — Indefinitely")
        } else {
            Text("Active — \(timerManager.remainingTimeFormatted) remaining")
        }

        Menu("Add Minutes") {
            ForEach(minuteOptions, id: \.self) { minutes in
                Button("\(minutes) Minutes") {
                    timerManager.addTime(seconds: TimeInterval(minutes * 60))
                }
            }
        }

        Menu("Add Hours") {
            ForEach(hourOptions, id: \.self) { hours in
                Button("\(hours) \(hours == 1 ? "Hour" : "Hours")") {
                    timerManager.addTime(seconds: TimeInterval(hours * 3600))
                }
            }
        }

        Button("Deactivate") {
            timerManager.deactivate()
        }
    }

    @ViewBuilder
    private var inactiveMenu: some View {
        Menu("Minutes") {
            ForEach(minuteOptions, id: \.self) { minutes in
                Button("\(minutes) Minutes") {
                    timerManager.activate(seconds: TimeInterval(minutes * 60))
                }
            }
        }

        Menu("Hours") {
            ForEach(hourOptions, id: \.self) { hours in
                Button("\(hours) \(hours == 1 ? "Hour" : "Hours")") {
                    timerManager.activate(seconds: TimeInterval(hours * 3600))
                }
            }
        }

        Button("Indefinitely") {
            timerManager.activateIndefinitely()
        }
    }
}
