import SwiftUI
import Carbon

final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var hotkey: StoredHotkey {
        didSet {
            saveHotkey()
            HotkeyManager.shared.register(hotkey: hotkey) {
                Task { @MainActor in AppState.shared.triggerStemSeparation() }
            }
        }
    }

    @Published var accessibilityGranted: Bool = false
    @Published var isTriggering: Bool = false
    @Published var lastResult: TriggerResult? = nil
    @Published var hasCompletedOnboarding: Bool

    private var permissionTimer: Timer?

    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "onboardingComplete")
        let savedHotkey = AppState.loadHotkey()
        self.hotkey = savedHotkey
        self.accessibilityGranted = PermissionsManager.isAccessibilityGranted()

        HotkeyManager.shared.register(hotkey: savedHotkey) {
            Task { @MainActor in AppState.shared.triggerStemSeparation() }
        }

        startPermissionPolling()
    }

    private func startPermissionPolling() {
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            let granted = PermissionsManager.isAccessibilityGranted()
            DispatchQueue.main.async {
                if self?.accessibilityGranted != granted {
                    self?.accessibilityGranted = granted
                }
            }
        }
    }

    func refreshPermissions() {
        accessibilityGranted = PermissionsManager.isAccessibilityGranted()
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        hasCompletedOnboarding = true
        OnboardingWindowManager.shared.close()
    }

    @MainActor
    func triggerStemSeparation() {
        guard accessibilityGranted else {
            lastResult = .failure("Accessibility permission required.")
            return
        }
        isTriggering = true
        Task {
            let result = await AbletonController.triggerStemSeparation()
            await MainActor.run {
                self.lastResult = result
                self.isTriggering = false
            }
        }
    }

    private func saveHotkey() {
        if let data = try? JSONEncoder().encode(hotkey) {
            UserDefaults.standard.set(data, forKey: "storedHotkey")
        }
    }

    static func loadHotkey() -> StoredHotkey {
        if let data = UserDefaults.standard.data(forKey: "storedHotkey"),
           let hotkey = try? JSONDecoder().decode(StoredHotkey.self, from: data) {
            return hotkey
        }
        return StoredHotkey(keyCode: 5, carbonModifiers: UInt32(cmdKey | optionKey), displayString: "⌥⌘G")
    }
}

struct StoredHotkey: Codable, Equatable {
    var keyCode: UInt32
    var carbonModifiers: UInt32
    var displayString: String
}

enum TriggerResult: Equatable {
    case success
    case failure(String)

    var message: String {
        switch self {
        case .success: return "Stems separated successfully."
        case .failure(let msg): return msg
        }
    }

    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}
