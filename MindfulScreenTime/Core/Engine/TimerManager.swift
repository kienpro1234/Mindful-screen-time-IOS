import Foundation
import UserNotifications

public final class TimerManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    public static let shared = TimerManager()

    @Published public var isNotificationAuthorized: Bool = true

    private var activeSessions: [String: Date] = [:] // appName -> targetEndTime
    private let notificationCenter: UNUserNotificationCenter

    public init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
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
        let durationSeconds = inMinutes * 60.0
        let targetEndTime = Date().addingTimeInterval(durationSeconds)
        activeSessions[appName] = targetEndTime

        let content = makeNotificationContent(appName: appName, inMinutes: Int(inMinutes))
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: durationSeconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "mindful.pause.\(appName)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request, withCompletionHandler: nil)
    }

    public func cancelActiveTimer(for appName: String) {
        activeSessions.removeValue(forKey: appName)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["mindful.pause.\(appName)"])
    }

    public func remainingSeconds(for appName: String) -> Double? {
        guard let endTime = activeSessions[appName] else { return nil }
        let diff = endTime.timeIntervalSince(Date())
        return diff > 0 ? diff : nil
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
            // Re-intercept to trigger escalating friction
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
