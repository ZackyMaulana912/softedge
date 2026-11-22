import AppKit
import Carbon.HIToolbox

/// "RCKY", marks hot keys registered by this app.
private let hotKeySignature: OSType = 0x5243_4B59

/// Registers system wide shortcuts through Carbon, which works without the
/// Accessibility permission that a global event monitor would need.
@MainActor
final class GlobalHotKeys {
    private static var onPress: (@MainActor (AppShortcut) -> Void)?

    private var eventHandler: EventHandlerRef?
    private var hotKeys: [EventHotKeyRef] = []

    func register(_ shortcuts: [AppShortcut], onPress: @escaping @MainActor (AppShortcut) -> Void) {
        unregister()
        Self.onPress = onPress

        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, _ in
            var id = EventHotKeyID()
            let status = GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &id
            )
            guard status == noErr, id.signature == hotKeySignature,
                  let shortcut = AppShortcut(rawValue: id.id)
            else { return OSStatus(eventNotHandledErr) }

            Task { @MainActor in GlobalHotKeys.onPress?(shortcut) }
            return noErr
        }, 1, &spec, nil, &eventHandler)

        for shortcut in shortcuts {
            var ref: EventHotKeyRef?
            let status = RegisterEventHotKey(
                shortcut.keyCode,
                AppShortcut.modifiers,
                EventHotKeyID(signature: hotKeySignature, id: shortcut.rawValue),
                GetApplicationEventTarget(),
                0,
                &ref
            )
            if status == noErr, let ref {
                hotKeys.append(ref)
            } else {
                NSLog("RoundedCorners: shortcut %@ is taken by another app (%d)", shortcut.keys, status)
            }
        }
    }

    func unregister() {
        hotKeys.forEach { UnregisterEventHotKey($0) }
        hotKeys.removeAll()
        if let eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
        Self.onPress = nil
    }
}
