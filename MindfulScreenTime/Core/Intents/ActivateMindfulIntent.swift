import AppIntents
import Foundation

/// Single-action App Intent for iOS 26/27+: evaluates bypass state silently in background
/// and dynamically brings Mindful to the foreground only when an interception is needed.
@available(iOS 26.0, *)
public struct ActivateMindfulIntent: AppIntent {
    public static var title: LocalizedStringResource = "Bật Khoảng Lặng Mindful"
    public static var description = IntentDescription(
        "Hành động duy nhất trong Phím Tắt: tự kiểm tra và bật Khoảng Lặng Tỉnh Thức khi cần (không cần ghép thêm khối Nếu hay Mở ứng dụng)."
    )

    public static var supportedModes: IntentModes {
        [.background, .foreground(.dynamic)]
    }

    @Parameter(title: "Ứng dụng cụ thể (để trống nếu gộp nhiều app)")
    public var targetApp: TargetAppOption?

    public static var parameterSummary: some ParameterSummary {
        Summary("Bật Khoảng Lặng Mindful") {
            \.$targetApp
        }
    }

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult {
        let decision = TimerManager.shared.evaluateInterception(forAppName: targetApp?.displayName)
        switch decision {
        case .bypass:
            return .result()
        case .intercept(let targetDisplayName):
            TimerManager.shared.setPendingInterceptApp(targetDisplayName)
            if systemContext.currentMode.canContinueInForeground {
                try await continueInForeground(alwaysConfirm: false)
            }
            NotificationCenter.default.post(
                name: Notification.Name("MindfulTriggerIntervention"),
                object: targetDisplayName
            )
            return .result()
        }
    }
}

/// Registers Mindful's ready-made single-action shortcut in the system Shortcuts app.
@available(iOS 26.0, *)
public struct MindfulAppShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ActivateMindfulIntent(),
            phrases: [
                "Bật Khoảng Lặng trong \(.applicationName)",
                "Kiểm tra tỉnh thức \(.applicationName)"
            ],
            shortTitle: "Bật Khoảng Lặng Mindful",
            systemImageName: "sparkles"
        )
    }
}
