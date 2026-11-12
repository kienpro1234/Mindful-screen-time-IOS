import Foundation

public enum FrictionTier: Equatable {
    case quickTap
    case breathingPause(seconds: Int)
    case typedPledge(text: String)
}

public final class FrictionManager {
    public static let shared = FrictionManager()
    public static let defaultPledgeText = "Tôi chấp nhận trì hoãn công việc để tiếp tục lướt"

    private var extensionCounts: [String: Int] = [:]
    private var lastActiveTimestamps: [String: Date] = [:]

    public init() {}

    public func currentTier(for appName: String) -> FrictionTier {
        resetFrictionIfExpired(for: appName)
        let count = extensionCounts[appName, default: 0]
        return tierForCount(count)
    }

    public func requestExtension(for appName: String) -> FrictionTier {
        resetFrictionIfExpired(for: appName)
        let count = extensionCounts[appName, default: 0]
        let tierToEnforce = tierForCount(count)
        
        extensionCounts[appName] = count + 1
        lastActiveTimestamps[appName] = Date()
        
        return tierToEnforce
    }

    public func resetFrictionIfExpired(for appName: String, idleThresholdMinutes: Int = 30) {
        guard let lastActive = lastActiveTimestamps[appName] else { return }
        let idleInterval = Date().timeIntervalSince(lastActive)
        if idleInterval > Double(idleThresholdMinutes * 60) {
            extensionCounts[appName] = 0
            lastActiveTimestamps.removeValue(forKey: appName)
        }
    }

    public func validatePledge(input: String) -> Bool {
        let cleanInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTarget = Self.defaultPledgeText.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanInput.caseInsensitiveCompare(cleanTarget) == .orderedSame
    }

    public func resetAll(for appName: String) {
        extensionCounts.removeValue(forKey: appName)
        lastActiveTimestamps.removeValue(forKey: appName)
    }

    // Testing helper to simulate time advancement
    internal func simulateSetLastActive(for appName: String, date: Date) {
        lastActiveTimestamps[appName] = date
    }

    private func tierForCount(_ count: Int) -> FrictionTier {
        switch count {
        case 0:
            return .quickTap
        case 1:
            return .breathingPause(seconds: 10)
        default:
            return .typedPledge(text: Self.defaultPledgeText)
        }
    }
}
