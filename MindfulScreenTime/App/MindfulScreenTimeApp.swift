import SwiftUI

@main
struct MindfulScreenTimeApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var interceptedAppName: String? = nil
    @StateObject private var timerManager = TimerManager.shared

    init() {
        TimerManager.shared.requestNotificationPermission { _ in }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(interceptedAppName: $interceptedAppName)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        timerManager.checkNotificationAuthorization()
                        checkPendingAppIntentInterception()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("MindfulTriggerIntervention"))) { notification in
                    if let appName = notification.userInfo?["appName"] as? String {
                        self.interceptedAppName = appName
                    }
                }
        }
    }

    private func checkPendingAppIntentInterception() {
        if let pendingApp = timerManager.consumePendingInterceptApp() {
            if !timerManager.isSessionUnlocked(for: pendingApp) {
                self.interceptedAppName = pendingApp
            }
        }
    }

    private func handleIncomingURL(_ url: URL) {
        let action = DeepLinkHandler.parse(url: url)
        switch action {
        case .intercept(let appName):
            if timerManager.isSessionUnlocked(for: appName) {
                if AppRedirector.canRedirectDirectly(appName: appName) {
                    AppRedirector.openApp(named: appName)
                }
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
