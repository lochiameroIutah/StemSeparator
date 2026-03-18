import SwiftUI

// MARK: - Brand colours (fire palette)
extension Color {
    static let brandBg       = Color(red: 0.07, green: 0.03, blue: 0.02)   // #120805 near-black warm
    static let fireOrange    = Color(red: 1.00, green: 0.42, blue: 0.08)   // #FF6B14
    static let fireCrimson   = Color(red: 1.00, green: 0.18, blue: 0.00)   // #FF2D00
    static let fireAmber     = Color(red: 1.00, green: 0.69, blue: 0.10)   // #FFB01A
}

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var step: Step = .welcome
    @State private var permissionGranted = false
    @State private var checkTimer: Timer?
    @State private var pulse = false
    @State private var isRecordingHotkey = false
    @State private var localMonitor: Any?
    @State private var flagsMonitor: Any?
    @State private var liveModifiers: String = ""

    enum Step: Int { case welcome, shortcut, accessibility, loginItem, done }

    var body: some View {
        ZStack {
            Color.brandBg.ignoresSafeArea()

            // Fire glow blob
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color.fireOrange.opacity(pulse ? 0.22 : 0.12), .clear],
                        center: .center, startRadius: 0, endRadius: 280
                    )
                )
                .frame(width: 560, height: 400)
                .offset(y: -120)
                .blur(radius: 40)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: pulse)

            VStack(spacing: 0) {
                Spacer().frame(height: 28)

                // Icon + title
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.fireOrange.opacity(0.35), Color.fireCrimson.opacity(0.25)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 76, height: 76)
                            .overlay(
                                Circle().stroke(
                                    LinearGradient(
                                        colors: [Color.fireAmber.opacity(0.6), Color.fireCrimson.opacity(0.4)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ), lineWidth: 1.5
                                )
                            )
                            .shadow(color: Color.fireOrange.opacity(pulse ? 0.5 : 0.3), radius: pulse ? 22 : 14)

                        Image(systemName: "waveform.badge.plus")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color.fireAmber.opacity(0.85)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .symbolRenderingMode(.hierarchical)
                    }

                    Text("Stems Shortcut")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(.white)

                    Text(L.appSubtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.top, 4)
                .padding(.bottom, 20)

                // Step indicator (5 steps)
                HStack(spacing: 6) {
                    ForEach(0..<5) { i in
                        Capsule()
                            .fill(step.rawValue >= i ? Color.fireOrange : Color.white.opacity(0.15))
                            .frame(width: step.rawValue == i ? 20 : 6, height: 6)
                            .animation(.spring(duration: 0.3), value: step)
                    }
                }
                .padding(.bottom, 20)

                // Step content
                Group {
                    switch step {
                    case .welcome:       welcomeStep
                    case .shortcut:      shortcutStep
                    case .accessibility: accessibilityStep
                    case .loginItem:     loginItemStep
                    case .done:          doneStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.spring(duration: 0.4), value: step)

                Spacer(minLength: 12)

                // Weero branding
                weeroCard
                    .padding(.horizontal, 28)
                    .padding(.bottom, 20)
            }
            .frame(width: 420)
        }
        .frame(width: 420, height: 600)
        .onAppear  { pulse = true }
        .onDisappear {
            checkTimer?.invalidate()
            stopRecording()
        }
    }

    // MARK: - Weero card

    private var weeroCard: some View {
        Button(action: {
            NSWorkspace.shared.open(URL(string: "https://www.instagram.com/doitweero")!)
        }) {
            HStack(spacing: 12) {
                Image("WeeroAvatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(L.isItalian ? "Realizzata da" : "Made by")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.45))
                    Text("Weero  ·  @doitweero")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Text(L.isItalian ? "Scopri →" : "Discover →")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.fireOrange)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.fireAmber.opacity(0.5), Color.fireCrimson.opacity(0.3)],
                                    startPoint: .leading, endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Steps

    private var welcomeStep: some View {
        VStack(spacing: 14) {
            VStack(spacing: 10) {
                ModernFeatureRow(icon: "keyboard",               title: L.feature1Title, subtitle: L.feature1Sub)
                ModernFeatureRow(icon: "filemenu.and.selection", title: L.feature2Title, subtitle: L.feature2Sub)
                ModernFeatureRow(icon: "menubar.rectangle",      title: L.feature3Title, subtitle: L.feature3Sub)
            }
            FireButton(label: L.ctaGetStarted) {
                withAnimation { step = .shortcut }
            }
            if UserDefaults.standard.bool(forKey: "onboardingComplete") {
                GhostButton(label: L.isItalian ? "Salta" : "Skip") {
                    appState.completeOnboarding()
                }
            }
        }
        .padding(.horizontal, 28)
    }

    private var shortcutStep: some View {
        VStack(spacing: 20) {
            // Description
            Text(L.shortcutStepDesc)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            // Shortcut display / recording area
            VStack(spacing: 14) {
                if isRecordingHotkey {
                    VStack(spacing: 12) {
                        // Live modifier badges
                        if liveModifiers.isEmpty {
                            Text(L.shortcutRecording)
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.4))
                        } else {
                            ShortcutBadgesView(displayString: liveModifiers + "?")
                        }

                        Button(L.cancelBtn) { stopRecording() }
                            .buttonStyle(.plain)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.fireOrange.opacity(0.07))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.fireOrange.opacity(0.35), lineWidth: 1)
                            )
                    )
                } else {
                    VStack(spacing: 12) {
                        ShortcutBadgesView(displayString: appState.hotkey.displayString)

                        Button(L.shortcutChangeBtn) { startRecording() }
                            .buttonStyle(.plain)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.fireOrange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
            }

            FireButton(label: L.continueBtn) {
                stopRecording()
                withAnimation { step = .accessibility }
            }
        }
        .padding(.horizontal, 28)
    }

    private var accessibilityStep: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(permissionGranted ? Color.green.opacity(0.15) : Color.fireOrange.opacity(0.12))
                        .frame(width: 48, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(permissionGranted ? Color.green.opacity(0.3) : Color.fireOrange.opacity(0.3), lineWidth: 1)
                        )
                    Image(systemName: permissionGranted ? "checkmark.shield.fill" : "accessibility")
                        .font(.system(size: 20))
                        .foregroundStyle(permissionGranted ? Color.green : Color.fireOrange)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(L.permissionTitle).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                    Text(permissionGranted ? L.permissionSubGranted : L.permissionSubNotYet)
                        .font(.system(size: 11)).foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                if permissionGranted {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.system(size: 18))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(0.05))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.08), lineWidth: 1))
            )

            if !permissionGranted {
                Text(L.permissionInstructions)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                if !permissionGranted {
                    FireButton(label: L.openSettings, icon: "gear") {
                        PermissionsManager.requestAccessibility()
                        PermissionsManager.openAccessibilitySettings()
                        startPolling()
                    }
                }
                if permissionGranted {
                    FireButton(label: L.continueBtn) { withAnimation { step = .loginItem } }
                } else {
                    GhostButton(label: L.skip) { withAnimation { step = .loginItem } }
                }
            }
        }
        .padding(.horizontal, 28)
        .onAppear {
            permissionGranted = PermissionsManager.isAccessibilityGranted()
            startPolling()
        }
    }

    private var loginItemStep: some View {
        VStack(spacing: 20) {
            // Icon + description
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.fireOrange.opacity(0.2), Color.fireCrimson.opacity(0.1)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.fireOrange.opacity(0.3), lineWidth: 1)
                        )
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.fireOrange)
                }

                VStack(spacing: 5) {
                    Text(L.loginItemTitle)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    Text(L.loginItemSub)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
            }

            // Enable / status
            LoginItemToggleRow()

            VStack(spacing: 10) {
                FireButton(label: L.continueBtn) { withAnimation { step = .done } }
                GhostButton(label: L.skip)       { withAnimation { step = .done } }
            }
        }
        .padding(.horizontal, 28)
    }

    private var doneStep: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.green.opacity(0.15)).frame(width: 60, height: 60)
                    .overlay(Circle().stroke(Color.green.opacity(0.3), lineWidth: 1))
                Image(systemName: "checkmark").font(.system(size: 24, weight: .semibold)).foregroundStyle(.green)
            }
            VStack(spacing: 5) {
                Text(L.doneTitle).font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                Text(L.doneSubtitle)
                    .font(.system(size: 12)).foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center).lineSpacing(3)
            }
            FireButton(label: L.doneCTA) { appState.completeOnboarding() }
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Hotkey recording

    private func startRecording() {
        HotkeyManager.shared.unregister()
        isRecordingHotkey = true
        liveModifiers = ""

        flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
            let flags = event.modifierFlags.intersection([.command, .shift, .option, .control])
            DispatchQueue.main.async {
                self.liveModifiers = HotkeyManager.modifierString(flags)
            }
            return event
        }

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
        liveModifiers = ""
        if let m = localMonitor { NSEvent.removeMonitor(m); localMonitor = nil }
        if let m = flagsMonitor  { NSEvent.removeMonitor(m); flagsMonitor = nil }
        HotkeyManager.shared.register(hotkey: appState.hotkey) {
            Task { @MainActor in AppState.shared.triggerStemSeparation() }
        }
    }

    // MARK: - Permission polling

    private func startPolling() {
        checkTimer?.invalidate()
        checkTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            let granted = PermissionsManager.isAccessibilityGranted()
            if granted != permissionGranted {
                withAnimation(.spring(duration: 0.3)) { permissionGranted = granted }
            }
        }
    }
}

// MARK: - Subcomponents

struct LoginItemToggleRow: View {
    @State private var enabled: Bool = LoginItemManager.isEnabled

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: enabled ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20))
                .foregroundStyle(enabled ? Color.green : Color.white.opacity(0.3))

            Text(L.loginItemToggle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Toggle("", isOn: $enabled)
                .toggleStyle(.switch)
                .tint(Color.fireOrange)
                .labelsHidden()
                .onChange(of: enabled) { newValue in
                    if newValue { try? LoginItemManager.enable() }
                    else        { try? LoginItemManager.disable() }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(enabled ? Color.fireOrange.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .onAppear { enabled = LoginItemManager.isEnabled }
    }
}

/// Compact toggle for use in menu bar rows
struct LoginItemToggle: View {
    @State private var enabled: Bool = LoginItemManager.isEnabled
    var body: some View {
        Toggle("", isOn: $enabled)
            .toggleStyle(.switch)
            .tint(Color.fireOrange)
            .labelsHidden()
            .onChange(of: enabled) { newValue in
                if newValue { try? LoginItemManager.enable() }
                else        { try? LoginItemManager.disable() }
            }
            .onAppear { enabled = LoginItemManager.isEnabled }
    }
}

struct ModernFeatureRow: View {
    let icon: String; let title: String; let subtitle: String
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(Color.fireOrange.opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.fireOrange.opacity(0.2), lineWidth: 1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 15)).foregroundStyle(Color.fireOrange.opacity(0.9))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                Text(subtitle).font(.system(size: 11)).foregroundStyle(.white.opacity(0.4))
            }
            Spacer()
        }
    }
}

/// Primary fire-gradient button
struct FireButton: View {
    let label: String
    var icon: String? = nil
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon { Image(systemName: icon).font(.system(size: 13)) }
                Text(label).font(.system(size: 13, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.fireAmber, Color.fireOrange, Color.fireCrimson],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
            )
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
}

/// Shows a hotkey as individual key badges separated by "+"
struct ShortcutBadgesView: View {
    let displayString: String

    private var parts: [String] {
        let modChars: [Character] = ["⌃", "⌥", "⇧", "⌘"]
        var result: [String] = []
        var key = ""
        for ch in displayString {
            if modChars.contains(ch) {
                result.append(String(ch))
            } else {
                key.append(ch)
            }
        }
        if !key.isEmpty { result.append(key) }
        return result
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(parts.enumerated()), id: \.offset) { idx, part in
                if idx > 0 {
                    Text("+")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.3))
                }
                Text(part)
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.white.opacity(0.18), lineWidth: 1)
                            )
                    )
            }
        }
    }
}

/// Ghost secondary button
struct GhostButton: View {
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label).font(.system(size: 13, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.06))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.1), lineWidth: 1))
                )
                .foregroundStyle(.white.opacity(0.6))
        }
        .buttonStyle(.plain)
    }
}
