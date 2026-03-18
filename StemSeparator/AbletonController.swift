import AppKit
import ApplicationServices

enum AbletonController {

    private static let createMenuNames: Set<String> = [
        "Create", "Crea", "Erstellen", "Créer", "Crear", "Criar",
        "作成", "创建", "建立", "만들기", "Создать", "Aanmaken",
    ]

    /// Position of the stem separation item in the Create menu,
    /// counting ALL children including separators. 1-based.
    /// Verified on Ableton Live 12 Italian: items 1-4, sep, 5-7, sep, 8-9, sep, 10, sep, 11-19(stem)
    private static let stemItemIndex = 19

    // MARK: - Public API

    static func triggerStemSeparation() async -> TriggerResult {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: performTrigger())
            }
        }
    }

    // MARK: - Core logic

    private static func performTrigger() -> TriggerResult {
        guard PermissionsManager.isAccessibilityGranted() else {
            return .failure("Accessibility permission is required.")
        }
        guard let ableton = findAbletonProcess() else {
            return .failure("Ableton Live is not running.")
        }

        ableton.activate(options: [.activateAllWindows])
        Thread.sleep(forTimeInterval: 0.2)

        let app = AXUIElementCreateApplication(ableton.processIdentifier)
        guard let menuBar = axMenuBar(of: app) else {
            return .failure("Could not read Ableton's menu bar.")
        }
        guard let createMenu = findCreateMenu(in: menuBar) else {
            return .failure("Could not find the Create menu in Ableton.")
        }

        let items = axChildren(of: createMenu)
        guard items.count >= stemItemIndex else {
            return .failure("Create menu has only \(items.count) items (expected ≥ \(stemItemIndex)).")
        }

        let stemItem = items[stemItemIndex - 1]

        guard axEnabled(of: stemItem) else {
            return .failure("Menu item is disabled. Please select an audio clip in Ableton first.")
        }

        let result = AXUIElementPerformAction(stemItem, kAXPressAction as CFString)
        return result == .success ? .success : .failure("Failed to trigger menu item (AX error \(result.rawValue)).")
    }

    // MARK: - Menu navigation

    private static func findCreateMenu(in menuBar: AXUIElement) -> AXUIElement? {
        for menuBarItem in axChildren(of: menuBar) {
            if let title = axTitle(of: menuBarItem), createMenuNames.contains(title) {
                return axChildren(of: menuBarItem).first
            }
        }
        return nil
    }

    private static func nonSeparatorItems(in menu: AXUIElement) -> [AXUIElement] {
        axChildren(of: menu).filter {
            var v: AnyObject?
            guard AXUIElementCopyAttributeValue($0, kAXRoleAttribute as CFString, &v) == .success,
                  let role = v as? String else { return true }
            return role != "AXMenuItemSeparator"
        }
    }

    // MARK: - Process lookup

    private static func findAbletonProcess() -> NSRunningApplication? {
        NSRunningApplication.runningApplications(withBundleIdentifier: "com.ableton.live").first
        ?? NSWorkspace.shared.runningApplications.first {
            $0.localizedName?.lowercased().contains("ableton") == true ||
            $0.localizedName?.lowercased() == "live"
        }
    }

    // MARK: - AX helpers

    private static func axMenuBar(of app: AXUIElement) -> AXUIElement? {
        var v: AnyObject?
        guard AXUIElementCopyAttributeValue(app, kAXMenuBarAttribute as CFString, &v) == .success else { return nil }
        return v as! AXUIElement?
    }

    private static func axChildren(of el: AXUIElement) -> [AXUIElement] {
        var v: AnyObject?
        guard AXUIElementCopyAttributeValue(el, kAXChildrenAttribute as CFString, &v) == .success,
              let c = v as? [AXUIElement] else { return [] }
        return c
    }

    private static func axTitle(of el: AXUIElement) -> String? {
        var v: AnyObject?
        guard AXUIElementCopyAttributeValue(el, kAXTitleAttribute as CFString, &v) == .success else { return nil }
        return v as? String
    }

    private static func axEnabled(of el: AXUIElement) -> Bool {
        var v: AnyObject?
        guard AXUIElementCopyAttributeValue(el, kAXEnabledAttribute as CFString, &v) == .success else { return true }
        return (v as? Bool) ?? true
    }
}
