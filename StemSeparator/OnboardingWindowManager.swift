import AppKit
import SwiftUI

final class OnboardingWindowManager {
    static let shared = OnboardingWindowManager()
    private var window: NSWindow?

    private init() {}

    func showIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "onboardingComplete") else { return }
        show()
    }

    func show() {
        if let existing = window {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let content = OnboardingView()
            .environmentObject(AppState.shared)

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 600),
            styleMask: NSWindow.StyleMask([.titled, .fullSizeContentView, .closable]),
            backing: .buffered,
            defer: false
        )

        let hostingView = NSHostingView(rootView: content)
        win.contentView = hostingView
        win.titlebarAppearsTransparent = true
        win.titleVisibility = .hidden
        win.isMovableByWindowBackground = true
        win.isReleasedWhenClosed = false
        win.backgroundColor = NSColor(red: 0.07, green: 0.03, blue: 0.02, alpha: 1)
        win.hasShadow = true
        win.center()
        win.makeKeyAndOrderFront(nil)
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        self.window = win
    }

    func close() {
        window?.close()
        window = nil
        NSApp.setActivationPolicy(.accessory)
    }

    func resetAndShow() {
        UserDefaults.standard.removeObject(forKey: "onboardingComplete")
        window?.close()
        window = nil
        show()
    }
}
