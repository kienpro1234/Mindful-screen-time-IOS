import Foundation

public enum DeepLinkAction: Equatable {
    case intercept(appName: String)
    case dashboard
    case breathing(appName: String)
    case unknown
}

public final class DeepLinkHandler {
    public static let defaultAppName = "Ứng dụng giải trí"

    public static func parse(url: URL) -> DeepLinkAction {
        guard let scheme = url.scheme, scheme.lowercased() == "mindful" else {
            return .unknown
        }

        let host = url.host?.lowercased()

        if host == "dashboard" {
            return .dashboard
        }

        if host == "intercept" {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let appQueryItem = components?.queryItems?.first(where: { $0.name.lowercased() == "app" })
            let rawAppName = appQueryItem?.value?.trimmingCharacters(in: .whitespacesAndNewlines)

            let appName = (rawAppName?.isEmpty ?? true) ? defaultAppName : rawAppName!
            return .intercept(appName: appName)
        }

        if host == "breathing" {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let appQueryItem = components?.queryItems?.first(where: { $0.name.lowercased() == "app" })
            let rawAppName = appQueryItem?.value?.trimmingCharacters(in: .whitespacesAndNewlines)

            let appName = (rawAppName?.isEmpty ?? true) ? defaultAppName : rawAppName!
            return .breathing(appName: appName)
        }

        return .unknown
    }
}
