import AppKit
import SwiftUI

final class ShortcutRecorderWindowManager {
    static let shared = ShortcutRecorderWindowManager()
    private var window: NSWindow?

    private init() {}

    func show() {
        if let existing = window {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 180),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        win.title = L.isItalian ? "Modifica Shortcut" : "Change Shortcut"
        win.titlebarAppearsTransparent = true
        win.isMovableByWindowBackground = true
        win.isReleasedWhenClosed = false
        win.backgroundColor = NSColor(red: 0.07, green: 0.03, blue: 0.02, alpha: 1)
        win.level = .floating

        let view = ShortcutRecorderView(onDismiss: { [weak self] in
            self?.window?.close()
            self?.window = nil
        })
        .environmentObject(AppState.shared)

        win.contentView = NSHostingView(rootView: view)
        win.center()
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = win
    }
}

private struct ShortcutRecorderView: View {
    @EnvironmentObject var appState: AppState
    let onDismiss: () -> Void

    @State private var isRecording = false
    @State private var liveModifiers: String = ""
    @State private var keyMonitor: Any?
    @State private var flagsMonitor: Any?

    var body: some View {
        VStack(spacing: 20) {
            Text(L.isItalian ? "Modifica Shortcut" : "Change Shortcut")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)

            if isRecording {
                VStack(spacing: 10) {
                    if liveModifiers.isEmpty {
                        Text(L.shortcutRecording)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.4))
                    } else {
                        ShortcutBadgesView(displayString: liveModifiers + "?")
                    }
                    Button(L.cancelBtn) { stopRecording() }
                        .buttonStyle(.plain)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.fireOrange.opacity(0.07))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.fireOrange.opacity(0.35), lineWidth: 1))
                )
            } else {
                VStack(spacing: 10) {
                    ShortcutBadgesView(displayString: appState.hotkey.displayString)
                    Button(L.shortcutChangeBtn) { startRecording() }
                        .buttonStyle(.plain)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.fireOrange)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.05))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.1), lineWidth: 1))
                )
            }

            FireButton(label: L.isItalian ? "Fatto" : "Done") {
                stopRecording()
                onDismiss()
            }
        }
        .padding(24)
        .frame(width: 340)
        .background(Color.brandBg)
        .onDisappear { stopRecording() }
    }

    private func startRecording() {
        HotkeyManager.shared.unregister()
        isRecording = true
        liveModifiers = ""

        flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
            let flags = event.modifierFlags.intersection([.command, .shift, .option, .control])
            DispatchQueue.main.async { self.liveModifiers = HotkeyManager.modifierString(flags) }
            return event
        }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let pureMods: Set<UInt16> = [54,55,56,57,58,59,60,61,62,63]
            if pureMods.contains(event.keyCode) { return event }
            let filtered = event.modifierFlags.intersection([.command, .shift, .option, .control])
            guard !filtered.isEmpty else { return event }
            let hotkey = HotkeyManager.makeHotkey(keyCode: event.keyCode, nsModifiers: filtered)
            DispatchQueue.main.async { self.appState.hotkey = hotkey; self.stopRecording() }
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        liveModifiers = ""
        if let m = keyMonitor   { NSEvent.removeMonitor(m); keyMonitor   = nil }
        if let m = flagsMonitor { NSEvent.removeMonitor(m); flagsMonitor = nil }
        HotkeyManager.shared.register(hotkey: appState.hotkey) {
            Task { @MainActor in AppState.shared.triggerStemSeparation() }
        }
    }
}
