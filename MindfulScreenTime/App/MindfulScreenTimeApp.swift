import SwiftUI

@main
struct MindfulScreenTimeApp: App {
    @State private var interceptedAppName: String? = nil
    @StateObject private var timerManager = TimerManager.shared

    init() {
        // Request notifications for in-session Layer 2 reminder
        TimerManager.shared.requestNotificationPermission { _ in }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(interceptedAppName: $interceptedAppName)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("MindfulTriggerIntervention"))) { notification in
                    if let appName = notification.userInfo?["appName"] as? String {
                        self.interceptedAppName = appName
                    }
                }
        }
    }

    private func handleIncomingURL(_ url: URL) {
        let action = DeepLinkHandler.parse(url: url)
        switch action {
        case .intercept(let appName):
            // Check if active session is already running (Review Focus 2 & Fix I3)
            if let remaining = timerManager.remainingSeconds(for: appName), remaining > 0 {
                // Session is currently active and within allowed threshold: bypass repeated interception
                return
            }
            self.interceptedAppName = appName
        case .breathing(let appName):
            self.interceptedAppName = appName
        case .dashboard:
            self.interceptedAppName = nil
        case .unknown:
            break
        }
    }
}
