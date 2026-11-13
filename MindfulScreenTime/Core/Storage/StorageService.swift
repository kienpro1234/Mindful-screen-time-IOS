import Foundation

public protocol StorageServiceProtocol {
    func logSession(appName: String, outcome: SessionOutcome, durationMinutes: Double)
    func fetchAllSessions() -> [SessionRecord]
    func calculateWinRate() -> Double
    func fetchHourlyDistractionCounts() -> [Int: Int]
}

public final class StorageService: StorageServiceProtocol {
    public static let shared = StorageService()
    
    private let userDefaults: UserDefaults
    private let storageKey = "mindful_session_records"

    public init(suiteName: String? = nil) {
        if let suite = suiteName, let customDefaults = UserDefaults(suiteName: suite) {
            self.userDefaults = customDefaults
        } else {
            self.userDefaults = UserDefaults.standard
        }
    }

    public func logSession(appName: String, outcome: SessionOutcome, durationMinutes: Double = 0.0) {
        var current = fetchAllSessions()
        let newRecord = SessionRecord(
            appName: appName,
            timestamp: Date(),
            outcome: outcome,
            durationMinutes: durationMinutes
        )
        current.append(newRecord)
        saveSessions(current)
        NotificationCenter.default.post(name: NSNotification.Name("MindfulSessionLogged"), object: nil)
    }

    public func fetchAllSessions() -> [SessionRecord] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return []
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([SessionRecord].self, from: data)
        } catch {
            return []
        }
    }

    public func calculateWinRate() -> Double {
        let sessions = fetchAllSessions()
        guard !sessions.isEmpty else { return 0.0 }
        let wins = sessions.filter { $0.outcome.isWin }.count
        return (Double(wins) / Double(sessions.count)) * 100.0
    }

    public func fetchHourlyDistractionCounts() -> [Int: Int] {
        let sessions = fetchAllSessions()
        var counts: [Int: Int] = [:]
        for hour in 0...23 {
            counts[hour] = 0
        }
        let calendar = Calendar.current
        for session in sessions {
            let hour = calendar.component(.hour, from: session.timestamp)
            counts[hour, default: 0] += 1
        }
        return counts
    }

    private func saveSessions(_ sessions: [SessionRecord]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(sessions)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            // Failed to encode sessions
        }
    }
}
