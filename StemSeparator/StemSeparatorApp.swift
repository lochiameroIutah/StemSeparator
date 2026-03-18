import SwiftUI

@main
struct StemSeparatorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environmentObject(appState)
        } label: {
            Image(systemName: appState.isTriggering ? "waveform.badge.checkmark" : "waveform.badge.plus")
                .symbolRenderingMode(.hierarchical)
        }
        .menuBarExtraStyle(.window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        LicenseWindowManager.shared.showIfNeeded()
    }
}
