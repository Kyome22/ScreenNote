import Foundation
import SpiceKey

public struct SpiceKeyClient: DependencyClient {
    public var toggles: @Sendable () -> AsyncStream<Void>
    public var setShortcut: @Sendable (ToggleMethod, ModifierFlag, Double) -> Void
    public var unregister: @Sendable () -> Void

    public static let liveValue: Self = {
        let box = SpiceKeyBox()
        return Self(
            toggles: { box.stream },
            setShortcut: { toggleMethod, modifierFlag, longPressSeconds in
                DispatchQueue.main.async {
                    MainActor.assumeIsolated {
                        box.setShortcut(toggleMethod, modifierFlag, longPressSeconds)
                    }
                }
            },
            unregister: {
                DispatchQueue.main.async {
                    MainActor.assumeIsolated { box.unregister() }
                }
            }
        )
    }()

    public static let testValue = Self(
        toggles: { AsyncStream { _ in } },
        setShortcut: { _, _, _ in },
        unregister: {}
    )
}

final class SpiceKeyBox: @unchecked Sendable {
    let stream: AsyncStream<Void>
    private let continuation: AsyncStream<Void>.Continuation
    private var spiceKey: SpiceKey?

    init() {
        (stream, continuation) = AsyncStream.makeStream(of: Void.self)
    }

    @MainActor
    func setShortcut(_ toggleMethod: ToggleMethod, _ modifierFlag: ModifierFlag, _ longPressSeconds: Double) {
        spiceKey?.unregister()
        switch toggleMethod {
        case .longPressKey:
            spiceKey = SpiceKey(modifierFlag.flags, longPressSeconds, modifierKeysLongPressHandler: { [continuation] in
                continuation.yield(())
            })
            spiceKey?.register()
        case .pressBothSideKeys:
            spiceKey = SpiceKey(modifierFlag, bothModifierKeysPressHandler: { [continuation] in
                continuation.yield(())
            })
            spiceKey?.register()
        }
    }

    @MainActor
    func unregister() {
        spiceKey?.unregister()
        spiceKey = nil
    }
}
