import Foundation
import UserNotifications

public final class TimerManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    public static let shared = TimerManager()

    @Published public var isNotificationAuthorized: Bool = true

    private let notificationCenter: UNUserNotificationCenter
    private let userDefaults: UserDefaults
    private let sessionsKey = "mindful_active_sessions_v1"
    private let pendingInterceptKey = "mindful_pending_intercept_app_v1"

    public init(
        notificationCenter: UNUserNotificationCenter = .current(),
        suiteName: String? = nil
    ) {
        self.notificationCenter = notificationCenter
        if let suite = suiteName, let customDefaults = UserDefaults(suiteName: suite) {
            self.userDefaults = customDefaults
        } else {
            self.userDefaults = UserDefaults.standard
        }
        super.init()
        self.notificationCenter.delegate = self
        registerNotificationCategories()
        checkNotificationAuthorization()
    }

    public func checkNotificationAuthorization() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationAuthorized = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
            }
        }
    }

    public func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.isNotificationAuthorized = granted
                completion(granted)
            }
        }
    }

    public func scheduleMindfulPause(appName: String, inMinutes: Double) {
        let key = normalizedKey(for: appName)
        let durationSeconds = inMinutes * 60.0
        let targetEndTime = Date().addingTimeInterval(durationSeconds)

        var sessions = loadActiveSessions()
        sessions[key] = targetEndTime
        saveActiveSessions(sessions)

        let content = makeNotificationContent(appName: appName, inMinutes: Int(inMinutes))
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: durationSeconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "mindful.pause.\(key)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request, withCompletionHandler: nil)
    }

    public func cancelActiveTimer(for appName: String) {
        let key = normalizedKey(for: appName)
        var sessions = loadActiveSessions()
        sessions.removeValue(forKey: key)
        saveActiveSessions(sessions)

        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["mindful.pause.\(key)"])
    }

    public func remainingSeconds(for appName: String) -> Double? {
        let key = normalizedKey(for: appName)
        var sessions = loadActiveSessions()
        guard let endTime = sessions[key] else { return nil }
        let diff = endTime.timeIntervalSince(Date())
        if diff > 0 {
            return diff
        } else {
            sessions.removeValue(forKey: key)
            saveActiveSessions(sessions)
            return nil
        }
    }

    public func isSessionUnlocked(for appName: String) -> Bool {
        if let remaining = remainingSeconds(for: appName), remaining > 0 {
            return true
        }
        return false
    }

    public func setPendingInterceptApp(_ appName: String) {
        let cleaned = appName.trimmingCharacters(in: .whitespacesAndNewlines)
        userDefaults.set(cleaned.isEmpty ? DeepLinkHandler.defaultAppName : cleaned, forKey: pendingInterceptKey)
    }

    public func consumePendingInterceptApp() -> String? {
        guard let value = userDefaults.string(forKey: pendingInterceptKey), !value.isEmpty else {
            return nil
        }
        userDefaults.removeObject(forKey: pendingInterceptKey)
        return value
    }

    public func makeNotificationContent(appName: String, inMinutes: Int) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Dừng Lại Một Chút"
        content.body = "Bạn đã lướt được \(inMinutes) phút rồi. Hãy dừng lại hít thở."
        content.sound = .default
        content.categoryIdentifier = "MINDFUL_PAUSE_CATEGORY"
        content.userInfo = ["appName": appName]
        return content
    }

    private func normalizedKey(for appName: String) -> String {
        return appName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func loadActiveSessions() -> [String: Date] {
        guard let data = userDefaults.data(forKey: sessionsKey) else { return [:] }
        return (try? JSONDecoder().decode([String: Date].self, from: data)) ?? [:]
    }

    private func saveActiveSessions(_ sessions: [String: Date]) {
        if let data = try? JSONEncoder().encode(sessions) {
            userDefaults.set(data, forKey: sessionsKey)
        }
    }

    private func registerNotificationCategories() {
        let exitAction = UNNotificationAction(
            identifier: "MINDFUL_ACTION_EXIT",
            title: "Rời app và quay lại việc",
            options: [.foreground]
        )
        let extendAction = UNNotificationAction(
            identifier: "MINDFUL_ACTION_EXTEND",
            title: "Cho tôi thêm 5 phút nữa",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: "MINDFUL_PAUSE_CATEGORY",
            actions: [exitAction, extendAction],
            intentIdentifiers: [],
            options: []
        )
        notificationCenter.setNotificationCategories([category])
    }

    // UNUserNotificationCenterDelegate
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let appName = userInfo["appName"] as? String ?? DeepLinkHandler.defaultAppName

        if response.actionIdentifier == "MINDFUL_ACTION_EXIT" {
            StorageService.shared.logSession(appName: appName, outcome: .exitedToWork, durationMinutes: 15)
            cancelActiveTimer(for: appName)
        } else if response.actionIdentifier == "MINDFUL_ACTION_EXTEND" {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("MindfulTriggerIntervention"),
                    object: nil,
                    userInfo: ["appName": appName]
                )
            }
        }
        completionHandler()
    }
}
