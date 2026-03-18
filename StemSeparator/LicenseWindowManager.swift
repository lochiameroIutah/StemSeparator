import AppKit
import SwiftUI

final class LicenseWindowManager {
    static let shared = LicenseWindowManager()
    private var window: NSWindow?

    private init() {}

    func showIfNeeded() {
        if LicenseManager.isActivated {
            OnboardingWindowManager.shared.showIfNeeded()
        } else {
            show()
        }
    }

    func show() {
        if let existing = window {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 520),
            styleMask: NSWindow.StyleMask([.titled, .fullSizeContentView]),
            backing: .buffered,
            defer: false
        )
        win.titlebarAppearsTransparent = true
        win.titleVisibility = .hidden
        win.isMovableByWindowBackground = true
        win.isReleasedWhenClosed = false
        win.backgroundColor = NSColor(red: 0.07, green: 0.03, blue: 0.02, alpha: 1)
        win.hasShadow = true

        let view = LicenseFlowView(onActivated: { [weak self] in
            self?.close()
            OnboardingWindowManager.shared.show()
        })
        .environmentObject(AppState.shared)

        win.contentView = NSHostingView(rootView: view)
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
}

// MARK: - Flow container (welcome → activate)

struct LicenseFlowView: View {
    let onActivated: () -> Void
    @State private var showActivation = false

    var body: some View {
        ZStack {
            if showActivation {
                LicenseActivationView(onActivated: onActivated)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                WelcomeView(onGetStarted: {
                    withAnimation(.spring(duration: 0.45)) { showActivation = true }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .environmentObject(AppState.shared)
    }
}

// MARK: - Welcome screen

struct WelcomeView: View {
    let onGetStarted: () -> Void

    @State private var pulse   = false
    @State private var appear  = false

    private let it = L.isItalian

    var body: some View {
        ZStack {
            Color.brandBg.ignoresSafeArea()

            // Fire glow
            Ellipse()
                .fill(RadialGradient(
                    colors: [Color.fireOrange.opacity(pulse ? 0.22 : 0.10), .clear],
                    center: .center, startRadius: 0, endRadius: 280))
                .frame(width: 560, height: 380)
                .offset(y: -140)
                .blur(radius: 48)
                .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: pulse)

            VStack(spacing: 0) {
                Spacer()

                // App icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.fireOrange.opacity(0.30), Color.fireCrimson.opacity(0.18)],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 90, height: 90)
                        .overlay(Circle().stroke(
                            LinearGradient(colors: [Color.fireAmber.opacity(0.55), Color.fireCrimson.opacity(0.35)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5))
                        .shadow(color: Color.fireOrange.opacity(pulse ? 0.55 : 0.28), radius: pulse ? 28 : 16)

                    Image(systemName: "waveform.badge.plus")
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(LinearGradient(
                            colors: [.white, Color.fireAmber.opacity(0.85)],
                            startPoint: .top, endPoint: .bottom))
                        .symbolRenderingMode(.hierarchical)
                }
                .scaleEffect(appear ? 1 : 0.7)
                .opacity(appear ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.05), value: appear)

                Spacer().frame(height: 28)

                // Title
                Text(L.welcomeTitle)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 12)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.12), value: appear)

                Spacer().frame(height: 16)

                // Description
                Text(L.welcomeDesc)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.48))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .frame(width: 280)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 10)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.20), value: appear)

                Spacer().frame(height: 40)

                // Feature pills
                VStack(spacing: 10) {
                    FeaturePill(icon: "keyboard",               text: it ? "Shortcut personalizzabile" : "Custom shortcut")
                    FeaturePill(icon: "filemenu.and.selection", text: it ? "Automatizza Ableton Live" : "Automates Ableton Live")
                    FeaturePill(icon: "menubar.rectangle",      text: it ? "Sempre nella menu bar" : "Lives in the menu bar")
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 8)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.28), value: appear)

                Spacer().frame(height: 36)

                // CTA
                FireButton(label: L.welcomeCTA, action: onGetStarted)
                    .frame(width: 260)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 8)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35), value: appear)

                Spacer().frame(height: 14)

                // Already have license
                Button(action: onGetStarted) {
                    Text(L.welcomeActivate)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.fireOrange.opacity(0.7))
                }
                .buttonStyle(.plain)
                .opacity(appear ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(0.42), value: appear)

                Spacer()
            }
            .frame(width: 420)
        }
        .frame(width: 420, height: 520)
        .onAppear {
            pulse  = true
            withAnimation { appear = true }
        }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(Color.fireOrange)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.75))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.09), lineWidth: 1))
        )
    }
}

// MARK: - Activation view

struct LicenseActivationView: View {
    @EnvironmentObject var appState: AppState
    let onActivated: () -> Void

    @State private var licenseKey   = ""
    @State private var isLoading    = false
    @State private var errorMessage: String?
    @State private var pulse        = false
    @State private var activated    = false
    @State private var checkScale: CGFloat = 0.4

    private let it = L.isItalian

    var body: some View {
        ZStack {
            Color.brandBg.ignoresSafeArea()

            Ellipse()
                .fill(RadialGradient(
                    colors: [Color.fireOrange.opacity(pulse ? 0.20 : 0.10), .clear],
                    center: .center, startRadius: 0, endRadius: 260))
                .frame(width: 500, height: 360)
                .offset(y: -100)
                .blur(radius: 40)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: pulse)

            if activated {
                successOverlay
            } else {
                VStack(spacing: 0) {
                    Spacer().frame(height: 44)

                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.fireOrange.opacity(0.35), Color.fireCrimson.opacity(0.25)],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 76, height: 76)
                            .overlay(Circle().stroke(
                                LinearGradient(colors: [Color.fireAmber.opacity(0.6), Color.fireCrimson.opacity(0.4)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5))
                            .shadow(color: Color.fireOrange.opacity(pulse ? 0.5 : 0.3), radius: pulse ? 22 : 14)

                        Image(systemName: "key.fill")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(LinearGradient(
                                colors: [.white, Color.fireAmber.opacity(0.85)],
                                startPoint: .top, endPoint: .bottom))
                    }

                    Spacer().frame(height: 20)

                    VStack(spacing: 6) {
                        Text(it ? "Attiva Stems Shortcut" : "Activate Stems Shortcut")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                        Text(it ? "Inserisci la chiave di licenza ricevuta via email." : "Enter the license key you received by email.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.45))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }

                    Spacer().frame(height: 32)

                    VStack(spacing: 12) {
                        TextField(it ? "XXXX-XXXX-XXXX-XXXX" : "XXXX-XXXX-XXXX-XXXX", text: $licenseKey)
                            .frame(width: 260)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.06))
                                    .overlay(RoundedRectangle(cornerRadius: 12)
                                        .stroke(errorMessage != nil ? Color.red.opacity(0.5) : Color.white.opacity(0.12), lineWidth: 1))
                            )

                        if let err = errorMessage {
                            Text(err)
                                .font(.system(size: 11))
                                .foregroundStyle(Color.red.opacity(0.8))
                        }

                        if isLoading {
                            ProgressView().progressViewStyle(.circular).tint(Color.fireOrange)
                        } else {
                            FireButton(label: it ? "Attiva" : "Activate") { Task { await activate() } }
                                .frame(width: 260)
                        }
                    }

                    Spacer().frame(height: 24)

                    Button(action: {
                        NSWorkspace.shared.open(URL(string: "https://abletonaccelerator.gumroad.com/l/brivhf")!)
                    }) {
                        Text(it ? "Non hai ancora una licenza? Acquista →" : "Don't have a license yet? Buy →")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.fireOrange.opacity(0.8))
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .frame(width: 420)
            }
        }
        .frame(width: 420, height: 520)
        .onAppear { pulse = true }
    }

    private var successOverlay: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.green.opacity(0.35), Color.green.opacity(0.15)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 76, height: 76)
                    .overlay(Circle().stroke(Color.green.opacity(0.5), lineWidth: 1.5))
                    .shadow(color: Color.green.opacity(0.5), radius: 20)
                Image(systemName: "checkmark")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(checkScale)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    checkScale = 1.0
                }
            }
            Text(it ? "Licenza attivata!" : "License activated!")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
            Text(it ? "Benvenuto in Stems Shortcut." : "Welcome to Stems Shortcut.")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func activate() async {
        let key = licenseKey.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else {
            errorMessage = it ? "Inserisci una chiave valida." : "Please enter a license key."
            return
        }
        isLoading    = true
        errorMessage = nil
        do {
            let valid = try await LicenseManager.activate(key: key)
            await MainActor.run {
                isLoading = false
                if valid {
                    withAnimation { activated = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        onActivated()
                    }
                } else {
                    errorMessage = it ? "Chiave non valida o già utilizzata." : "Invalid or already used license key."
                }
            }
        } catch {
            await MainActor.run {
                isLoading    = false
                errorMessage = it ? "Errore di rete. Controlla la connessione." : "Network error. Check your connection."
            }
        }
    }
}
