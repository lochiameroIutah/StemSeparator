import Carbon
import AppKit

final class HotkeyManager {
    static let shared = HotkeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var onTriggered: (() -> Void)?

    private init() { installEventHandler() }

    func register(hotkey: StoredHotkey, onTriggered: @escaping () -> Void) {
        unregister()
        self.onTriggered = onTriggered
        guard hotkey.keyCode > 0 else { return }
        let hotKeyID = EventHotKeyID(signature: OSType(0x5354454D), id: 1)
        RegisterEventHotKey(hotkey.keyCode, hotkey.carbonModifiers, hotKeyID,
                            GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    func unregister() {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref); hotKeyRef = nil }
    }

    private func installEventHandler() {
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, _, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
                let m = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async { m.onTriggered?() }
                return noErr
            },
            1, &eventSpec,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )
    }

    static func makeHotkey(keyCode: UInt16, nsModifiers: NSEvent.ModifierFlags) -> StoredHotkey {
        var carbon: UInt32 = 0
        if nsModifiers.contains(.command) { carbon |= UInt32(cmdKey) }
        if nsModifiers.contains(.shift)   { carbon |= UInt32(shiftKey) }
        if nsModifiers.contains(.option)  { carbon |= UInt32(optionKey) }
        if nsModifiers.contains(.control) { carbon |= UInt32(controlKey) }
        let display = modifierString(nsModifiers) + keyCodeToString(keyCode)
        return StoredHotkey(keyCode: UInt32(keyCode), carbonModifiers: carbon, displayString: display)
    }

    static func modifierString(_ flags: NSEvent.ModifierFlags) -> String {
        var s = ""
        if flags.contains(.control) { s += "⌃" }
        if flags.contains(.option)  { s += "⌥" }
        if flags.contains(.shift)   { s += "⇧" }
        if flags.contains(.command) { s += "⌘" }
        return s
    }

    static func keyCodeToString(_ keyCode: UInt16) -> String {
        let map: [UInt16: String] = [
            0:"A",1:"S",2:"D",3:"F",4:"H",5:"G",6:"Z",7:"X",8:"C",9:"V",
            11:"B",12:"Q",13:"W",14:"E",15:"R",16:"Y",17:"T",31:"O",32:"U",
            34:"I",35:"P",37:"L",38:"J",40:"K",45:"N",46:"M",
            18:"1",19:"2",20:"3",21:"4",22:"6",23:"5",24:"=",25:"9",
            26:"7",27:"-",28:"8",29:"0",
            36:"↩",48:"⇥",49:"Space",51:"⌫",53:"Esc",
            123:"←",124:"→",125:"↓",126:"↑",
            96:"F5",97:"F6",98:"F7",99:"F3",100:"F8",101:"F9",
            103:"F11",109:"F10",111:"F12",122:"F1",120:"F2",160:"F4"
        ]
        return map[keyCode] ?? "?"
    }
}
