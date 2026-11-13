import Foundation
import Combine

/// Represents an app that can be selected by the user inside Mindful for mindful interception.
public struct ManagedAppItem: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public var name: String
    public var customScheme: String?
    public var universalLink: String?
    public var systemIconName: String
    public var isCustom: Bool
    public var isInstalled: Bool

    public init(
        name: String,
        customScheme: String? = nil,
        universalLink: String? = nil,
        systemIconName: String = "app.badge.checkmark",
        isCustom: Bool = false,
        isInstalled: Bool = false
    ) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.name = trimmed
        self.id = "\(isCustom ? "custom" : "builtin"):\(trimmed.lowercased())"
        self.customScheme = customScheme
        self.universalLink = universalLink
        self.systemIconName = systemIconName
        self.isCustom = isCustom
        self.isInstalled = isInstalled
    }
}

/// Manages the user's selected distracting apps, installed-app scanning, and custom app launch schemes.
public final class ManagedAppsStore: ObservableObject {
    public static let shared = ManagedAppsStore()

    @Published public private(set) var items: [ManagedAppItem] = []
    @Published public private(set) var selectedAppNames: [String] = []

    private let userDefaults: UserDefaults
    private let knownTargets: [AppLaunchTarget]
    private let selectedNamesKey = "mindful_managed_app_names_v1"
    private let customAppsKey = "mindful_custom_managed_apps_v1"

    public init(
        userDefaults: UserDefaults = .standard,
        knownTargets: [AppLaunchTarget] = AppRedirector.knownTargets
    ) {
        self.userDefaults = userDefaults
        self.knownTargets = knownTargets
        reload()
    }

    public var installedItems: [ManagedAppItem] {
        items.filter { $0.isInstalled || $0.isCustom }
    }

    public var otherItems: [ManagedAppItem] {
        items.filter { !$0.isInstalled && !$0.isCustom }
    }

    public func reload() {
        let customItems = loadCustomApps()
        let builtInItems = knownTargets.map { target in
            ManagedAppItem(
                name: target.displayName,
                customScheme: target.customSchemeURL.absoluteString,
                universalLink: target.universalLinkURL?.absoluteString,
                systemIconName: target.systemIconName,
                isCustom: false,
                isInstalled: false
            )
        }
        items = builtInItems + customItems
        selectedAppNames = userDefaults.stringArray(forKey: selectedNamesKey) ?? []
    }

    /// Scans built-in known app schemes to highlight which distracting apps are installed on this device.
    public func detectInstalledApps(canOpenURL: (URL) -> Bool) {
        items = items.map { item in
            var updated = item
            if let schemeString = item.customScheme, let url = URL(string: schemeString) {
                updated.isInstalled = canOpenURL(url)
            } else {
                updated.isInstalled = false
            }
            return updated
        }
    }

    public func isSelected(_ appName: String) -> Bool {
        let normalized = normalize(appName)
        return selectedAppNames.contains { normalize($0) == normalized }
    }

    public func toggleSelection(for appName: String) {
        setSelected(!isSelected(appName), for: appName)
    }

    public func setSelected(_ selected: Bool, for appName: String) {
        let cleaned = appName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        let normalized = normalize(cleaned)

        var updated = selectedAppNames.filter { normalize($0) != normalized }
        if selected {
            let canonicalName = items.first { normalize($0.name) == normalized }?.name ?? cleaned
            updated.append(canonicalName)
        }
        selectedAppNames = updated
        userDefaults.set(updated, forKey: selectedNamesKey)
    }

    public func selectRecommendedSocialPreset() {
        let defaults = ["Facebook", "TikTok", "YouTube", "Instagram"]
        for name in defaults where items.contains(where: { normalize($0.name) == normalize(name) }) {
            setSelected(true, for: name)
        }
    }

    public func clearSelection() {
        selectedAppNames = []
        userDefaults.set([], forKey: selectedNamesKey)
    }

    public func addCustomApp(name: String, customScheme: String? = nil) {
        let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        let normalizedScheme = Self.normalizeScheme(customScheme)
        let normalized = normalize(cleaned)

        // Update existing custom item or ignore duplicate built-in item name cleanly
        if items.contains(where: { !$0.isCustom && normalize($0.name) == normalized }) {
            setSelected(true, for: cleaned)
            return
        }

        var customApps = loadCustomApps().filter { normalize($0.name) != normalized }
        let newItem = ManagedAppItem(
            name: cleaned,
            customScheme: normalizedScheme,
            universalLink: nil,
            systemIconName: "app.badge.checkmark",
            isCustom: true,
            isInstalled: true
        )
        customApps.append(newItem)
        saveCustomApps(customApps)
        reload()
        setSelected(true, for: cleaned)
    }

    public func removeCustomApp(name: String) {
        let normalized = normalize(name)
        let filtered = loadCustomApps().filter { normalize($0.name) != normalized }
        saveCustomApps(filtered)
        setSelected(false, for: name)
        reload()
    }

    public func selectedTargets() -> [ManagedAppItem] {
        selectedAppNames.map { name in
            if let existing = items.first(where: { normalize($0.name) == normalize(name) }) {
                return existing
            }
            return ManagedAppItem(name: name)
        }
    }

    public func launchTarget(for appName: String) -> AppLaunchTarget? {
        if let builtIn = AppRedirector.resolveTarget(for: appName) {
            return builtIn
        }
        let normalized = normalize(appName)
        guard let custom = items.first(where: { $0.isCustom && normalize($0.name) == normalized }),
              let scheme = custom.customScheme,
              URL(string: scheme) != nil else {
            return nil
        }
        return AppLaunchTarget(
            displayName: custom.name,
            customScheme: scheme,
            universalLink: custom.universalLink,
            systemIconName: custom.systemIconName
        )
    }

    public func singleSelectedAppNameIfUnique() -> String? {
        selectedAppNames.count == 1 ? selectedAppNames.first : nil
    }

    public func formattedSelectionChecklist() -> String {
        selectedAppNames.joined(separator: ", ")
    }

    public static func normalizeScheme(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains(where: { $0.isWhitespace }) else { return nil }
        let withSeparator = trimmed.contains("://") ? trimmed : "\(trimmed)://"
        return URL(string: withSeparator) != nil ? withSeparator : nil
    }

    private func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func loadCustomApps() -> [ManagedAppItem] {
        guard let data = userDefaults.data(forKey: customAppsKey) else { return [] }
        return (try? JSONDecoder().decode([ManagedAppItem].self, from: data)) ?? []
    }

    private func saveCustomApps(_ apps: [ManagedAppItem]) {
        if let encoded = try? JSONEncoder().encode(apps) {
            userDefaults.set(encoded, forKey: customAppsKey)
        }
    }
}
