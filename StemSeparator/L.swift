import Foundation

/// Inline localization helper. Checks the system language at launch; no .strings files required.
enum L {
    static let isItalian: Bool = {
        let preferred = Locale.preferredLanguages.first ?? ""
        return preferred.hasPrefix("it")
    }()

    private static func s(_ it: String, _ en: String) -> String {
        isItalian ? it : en
    }

    // MARK: - App
    static let appSubtitle           = s("Un solo shortcut per separare gli stem in Ableton Live.",
                                         "One shortcut to separate stems in Ableton Live.")

    // MARK: - Welcome screen
    static let welcomeTitle          = s("Benvenuto in\nStems Shortcut", "Welcome to\nStems Shortcut")
    static let welcomeDesc           = s(
        "Premi un tasto. Ableton separa gli stem.\nNessun menu, nessun click — solo musica.",
        "Press a key. Ableton separates your stems.\nNo menus, no clicks — just music."
    )
    static let welcomeCTA            = s("Inizia", "Get Started")
    static let welcomeActivate       = s("Hai già una licenza? Attiva →", "Already have a license? Activate →")

    // MARK: - Welcome step features
    static let feature1Title         = s("Shortcut personalizzabile", "Custom Shortcut")
    static let feature1Sub           = s("Qualsiasi combinazione di tasti.", "Any key combination.")
    static let feature2Title         = s("Automazione menu", "Menu Automation")
    static let feature2Sub           = s("Naviga il menu Crea di Ableton per te.", "Navigates Ableton's Create menu for you.")
    static let feature3Title         = s("Solo nella menu bar", "Lives in the Menu Bar")
    static let feature3Sub           = s("Sempre disponibile, mai d'intralcio.", "Always available, never in the way.")
    static let ctaGetStarted         = s("Inizia", "Get Started")

    // MARK: - Shortcut step
    static let shortcutStepDesc     = s("Imposta la combinazione di tasti per separare gli stem in Ableton.",
                                        "Set the key combination to separate stems in Ableton.")
    static let shortcutRecording    = s("Premi una combinazione di tasti…", "Press a key combination…")
    static let shortcutChangeBtn    = s("Cambia", "Change")
    static let cancelBtn            = s("Annulla", "Cancel")

    // MARK: - Accessibility step
    static let permissionTitle       = s("Accessibilità", "Accessibility")
    static let permissionSubNotYet   = s("Necessario per controllare i menu di Ableton.",
                                         "Required to control Ableton's menus.")
    static let permissionSubGranted  = s("Permesso concesso.", "Permission granted.")
    static let openSettings          = s("Apri Impostazioni di Sistema", "Open System Settings")
    static let skip                  = s("Salta per ora", "Skip for now")
    static let continueBtn           = s("Continua", "Continue")
    static let permissionInstructions = s(
        "Apri Impostazioni di Sistema → Privacy e Sicurezza → Accessibilità e abilita Stems Shortcut.",
        "Open System Settings → Privacy & Security → Accessibility and enable Stems Shortcut."
    )

    // MARK: - Login item step
    static let loginItemTitle       = s("Avvia al login", "Launch at Login")
    static let loginItemSub         = s("Stems Shortcut parte automaticamente all'avvio del Mac.",
                                        "Stems Shortcut starts automatically when you log in.")
    static let loginItemEnable      = s("Abilita avvio automatico", "Enable Launch at Login")
    static let loginItemEnabled     = s("Avvio automatico attivo", "Launch at Login enabled")
    static let loginItemToggle      = s("Avvia al login", "Launch at Login")

    // MARK: - Done step
    static let doneTitle             = s("Tutto pronto.", "You're all set.")
    static let doneSubtitle          = s("Usa l'icona nella menu bar per cambiare lo shortcut.",
                                         "Use the menu bar icon to change your shortcut anytime.")
    static let doneCTA               = s("Inizia a usare Stems Shortcut", "Start Using Stems Shortcut")

    // MARK: - Footer / branding
    static let onboardingFooter      = s("Realizzata da Weero · @doitweero", "Made by Weero · @doitweero")

    // MARK: - Menu bar
    static let discoverWeero         = s("Scopri Weero", "Discover Weero")
}
