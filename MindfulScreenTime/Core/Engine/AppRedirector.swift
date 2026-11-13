import Foundation
import UIKit

public struct AppLaunchTarget: Equatable, Identifiable {
    public var id: String { displayName }
    public let displayName: String
    public let customSchemeURL: URL
    public let universalLinkURL: URL?
    public let systemIconName: String

    public init(
        displayName: String,
        customScheme: String,
        universalLink: String? = nil,
        systemIconName: String = "arrow.up.right.square"
    ) {
        self.displayName = displayName
        self.customSchemeURL = URL(string: customScheme)!
        self.universalLinkURL = universalLink.flatMap { URL(string: $0) }
        self.systemIconName = systemIconName
    }
}

public final class AppRedirector {
    public static let knownTargets: [AppLaunchTarget] = [
        AppLaunchTarget(displayName: "Facebook", customScheme: "fb://", universalLink: nil, systemIconName: "person.2.fill"),
        AppLaunchTarget(displayName: "TikTok", customScheme: "snssdk1233://", universalLink: "https://www.tiktok.com", systemIconName: "music.note"),
        AppLaunchTarget(displayName: "YouTube", customScheme: "youtube://", universalLink: "https://www.youtube.com", systemIconName: "play.rectangle.fill"),
        AppLaunchTarget(displayName: "Instagram", customScheme: "instagram://", universalLink: "https://www.instagram.com", systemIconName: "camera.fill"),
        AppLaunchTarget(displayName: "Zalo", customScheme: "zalo://", universalLink: nil, systemIconName: "message.fill"),
        AppLaunchTarget(displayName: "Messenger", customScheme: "fb-messenger://", universalLink: nil, systemIconName: "bubble.left.and.bubble.right.fill"),
        AppLaunchTarget(displayName: "Threads", customScheme: "barcelona://", universalLink: "https://www.threads.net", systemIconName: "at"),
        AppLaunchTarget(displayName: "Telegram", customScheme: "tg://", universalLink: nil, systemIconName: "paperplane.fill"),
        AppLaunchTarget(displayName: "Reddit", customScheme: "reddit://", universalLink: "https://www.reddit.com", systemIconName: "text.bubble.fill"),
        AppLaunchTarget(displayName: "X (Twitter)", customScheme: "twitter://", universalLink: nil, systemIconName: "bird.fill"),
        AppLaunchTarget(displayName: "CapCut", customScheme: "capcut://", universalLink: nil, systemIconName: "scissors"),
        AppLaunchTarget(displayName: "Shopee", customScheme: "shopeevn://", universalLink: nil, systemIconName: "bag.fill"),
        AppLaunchTarget(displayName: "Netflix", customScheme: "nflx://", universalLink: nil, systemIconName: "film.fill")
    ]

    public static func resolveTarget(for appName: String) -> AppLaunchTarget? {
        let normalized = appName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return nil }

        return knownTargets.first { target in
            let targetLower = target.displayName.lowercased()
            if targetLower == normalized { return true }
            if normalized == "twitter" || normalized == "x" {
                return targetLower.contains("twitter")
            }
            return false
        }
    }

    public static func canRedirectDirectly(appName: String) -> Bool {
        return resolveTarget(for: appName) != nil
    }

    public static func openApp(named appName: String, completion: ((Bool) -> Void)? = nil) {
        guard let target = resolveTarget(for: appName) else {
            completion?(false)
            return
        }
        openTarget(target, completion: completion)
    }

    public static func openTarget(_ target: AppLaunchTarget, completion: ((Bool) -> Void)? = nil) {
        DispatchQueue.main.async {
            if let universalURL = target.universalLinkURL {
                UIApplication.shared.open(universalURL, options: [.universalLinksOnly: true]) { success in
                    if success {
                        completion?(true)
                    } else {
                        UIApplication.shared.open(target.customSchemeURL, options: [:]) { fallbackSuccess in
                            completion?(fallbackSuccess)
                        }
                    }
                }
            } else {
                UIApplication.shared.open(target.customSchemeURL, options: [:]) { success in
                    completion?(success)
                }
            }
        }
    }
}
