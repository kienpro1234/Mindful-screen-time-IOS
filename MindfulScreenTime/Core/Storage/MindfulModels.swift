import Foundation

public enum SessionOutcome: String, Codable, CaseIterable {
    case exitedToWork = "exitedToWork"
    case openedApp = "openedApp"
    case extendedSession = "extendedSession"

    public var isWin: Bool {
        return self == .exitedToWork
    }

    public var displayName: String {
        switch self {
        case .exitedToWork:
            return "Thoát để làm việc"
        case .openedApp:
            return "Đã mở ứng dụng"
        case .extendedSession:
            return "Gia hạn thêm giờ"
        }
    }
}

public struct SessionRecord: Codable, Identifiable, Equatable {
    public let id: UUID
    public let appName: String
    public let timestamp: Date
    public let outcome: SessionOutcome
    public let durationMinutes: Double

    public init(
        id: UUID = UUID(),
        appName: String,
        timestamp: Date = Date(),
        outcome: SessionOutcome,
        durationMinutes: Double = 0.0
    ) {
        self.id = id
        self.appName = appName
        self.timestamp = timestamp
        self.outcome = outcome
        self.durationMinutes = durationMinutes
    }
}
