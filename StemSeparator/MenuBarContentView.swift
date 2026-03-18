import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var updater = UpdaterManager.shared
    @State private var isRecordingHotkey = false
    @State private var localMonitor: Any?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Label("Stems Shortcut", systemImage: "waveform.badge.plus")
                    .font(.headline)
                    .symbolRenderingMode(.hierarchical)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()

            VStack(spacing: 12) {
                shortcutSection

                Divider()
                loginItemRow

                if !appState.accessibilityGranted {
                    Divider()
                    permissionWarning
                }

                if let result = appState.lastResult {
                    Divider()
                    resultBanner(result)
                }
            }
            .padding(16)

            // Update available banner
            if updater.updateAvailable {
                Divider()
                Button(action: { updater.checkForUpdates() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.subheadline)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(L.isItalian ? "Aggiornamento disponibile" : "Update available")
                                .font(.caption).fontWeight(.medium)
                            Text(L.isItalian ? "Clicca per installare" : "Click to install")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.08)))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }

            Divider()

            // Weero CTA
            Button(action: {
                NSWorkspace.shared.open(URL(string: "https://www.instagram.com/doitweero")!)
            }) {
                HStack(spacing: 8) {
                    Image("WeeroAvatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 22, height: 22)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Text(L.isItalian ? "Scopri Weero" : "Discover Weero")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .fill(Color(red: 1.0, green: 0.42, blue: 0.08).opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Color(red: 1.0, green: 0.42, blue: 0.08).opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)

            // Footer
            HStack {
                Button(action: {
                    UpdaterManager.shared.checkForUpdates()
                }) {
                    Label(L.isItalian ? "Aggiornamenti" : "Check for Updates", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .disabled(!UpdaterManager.shared.canCheckForUpdates)

                Spacer()
                Button(action: {
                    let alert = NSAlert()
                    alert.messageText = L.isItalian ? "Chiudi Stems Shortcut?" : "Quit Stems Shortcut?"
                    alert.informativeText = L.isItalian ? "Lo shortcut non funzionerà più." : "The shortcut will stop working."
                    alert.addButton(withTitle: L.isItalian ? "Chiudi" : "Quit")
                    alert.addButton(withTitle: L.isItalian ? "Annulla" : "Cancel")
                    alert.alertStyle = .warning
                    if alert.runModal() == .alertFirstButtonReturn {
                        NSApplication.shared.terminate(nil)
                    }
                }) {
                    Label("Quit", systemImage: "power").font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 300)
        .onAppear { appState.refreshPermissions() }
    }

    // MARK: - Subviews

    private var statusRow: some View {
        let running = !NSRunningApplication
            .runningApplications(withBundleIdentifier: "com.ableton.live").isEmpty
        return HStack(spacing: 10) {
            Circle()
                .fill(running ? Color.green : Color.secondary.opacity(0.4))
                .frame(width: 8, height: 8)
            Text(running ? "Ableton Live is running" : "Ableton Live is not running")
                .font(.subheadline)
                .foregroundStyle(running ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var shortcutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SHORTCUT")
                .font(.caption2).fontWeight(.semibold)
                .foregroundStyle(.secondary).tracking(0.8)

            HStack {
                if isRecordingHotkey {
                    Text("Press any key combination…")
                        .font(.subheadline).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button("Cancel") { stopRecording() }.buttonStyle(.bordered).controlSize(.small)
                } else {
                    Text(appState.hotkey.displayString)
                        .font(.system(.body, design: .monospaced)).fontWeight(.medium)
                        .tracking(3)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(NSColor.controlBackgroundColor))
                                .overlay(RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color(NSColor.separatorColor), lineWidth: 1))
                        )
                    Spacer()
                    Button("Change") { startRecording() }.buttonStyle(.bordered).controlSize(.small)
                }
            }
        }
    }

    private var loginItemRow: some View {
        HStack {
            Image(systemName: "clock")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(L.loginItemToggle)
                .font(.subheadline)
            Spacer()
            LoginItemToggle()
        }
    }

    private var permissionWarning: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange).font(.subheadline)
            VStack(alignment: .leading, spacing: 2) {
                Text("Accessibility required").font(.caption).fontWeight(.medium)
                Text("Needed to control Ableton's menus.").font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Button("Fix") { PermissionsManager.openAccessibilitySettings() }
                .buttonStyle(.bordered).controlSize(.mini)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.08)))
    }

    @ViewBuilder
    private func resultBanner(_ result: TriggerResult) -> some View {
        HStack(spacing: 8) {
            Image(systemName: result.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(result.isSuccess ? Color.green : Color.red).font(.subheadline)
            Text(result.message)
                .font(.caption)
                .foregroundStyle(result.isSuccess ? Color.primary : Color.red)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Hotkey recording

    private func startRecording() {
        HotkeyManager.shared.unregister()
        isRecordingHotkey = true
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let pureMods: Set<UInt16> = [54, 55, 56, 57, 58, 59, 60, 61, 62, 63]
            if pureMods.contains(event.keyCode) { return event }
            let filtered = event.modifierFlags.intersection([.command, .shift, .option, .control])
            guard !filtered.isEmpty else { return event }
            let hotkey = HotkeyManager.makeHotkey(keyCode: event.keyCode, nsModifiers: filtered)
            DispatchQueue.main.async { self.appState.hotkey = hotkey; self.stopRecording() }
            return nil
        }
    }

    private func stopRecording() {
        isRecordingHotkey = false
        if let m = localMonitor { NSEvent.removeMonitor(m); localMonitor = nil }
        HotkeyManager.shared.register(hotkey: appState.hotkey) {
            Task { @MainActor in AppState.shared.triggerStemSeparation() }
        }
    }
}
