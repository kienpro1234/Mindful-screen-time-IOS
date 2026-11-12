import XCTest
@testable import MindfulScreenTime

final class StorageServiceTests: XCTestCase {
    var storageService: StorageService!
    let testDefaultsSuite = "test.mindful.storage"

    override func setUp() {
        super.setUp()
        if let defaults = UserDefaults(suiteName: testDefaultsSuite) {
            defaults.removePersistentDomain(forName: testDefaultsSuite)
        }
        storageService = StorageService(suiteName: testDefaultsSuite)
    }

    override func tearDown() {
        if let defaults = UserDefaults(suiteName: testDefaultsSuite) {
            defaults.removePersistentDomain(forName: testDefaultsSuite)
        }
        storageService = nil
        super.tearDown()
    }

    func testLogSessionAndFetchAll() {
        XCTAssertEqual(storageService.fetchAllSessions().count, 0)

        storageService.logSession(appName: "TikTok", outcome: .exitedToWork, durationMinutes: 0)
        storageService.logSession(appName: "Facebook", outcome: .openedApp, durationMinutes: 15)

        let sessions = storageService.fetchAllSessions()
        XCTAssertEqual(sessions.count, 2)
        XCTAssertEqual(sessions[0].appName, "TikTok")
        XCTAssertEqual(sessions[0].outcome, .exitedToWork)
        XCTAssertEqual(sessions[1].appName, "Facebook")
        XCTAssertEqual(sessions[1].outcome, .openedApp)
    }

    func testCalculateWinRate() {
        // Empty sessions should return 0.0
        XCTAssertEqual(storageService.calculateWinRate(), 0.0)

        // 3 exits (wins) and 1 open (loss) = 75%
        storageService.logSession(appName: "TikTok", outcome: .exitedToWork, durationMinutes: 0)
        storageService.logSession(appName: "Instagram", outcome: .exitedToWork, durationMinutes: 0)
        storageService.logSession(appName: "YouTube", outcome: .exitedToWork, durationMinutes: 0)
        storageService.logSession(appName: "TikTok", outcome: .openedApp, durationMinutes: 15)

        let winRate = storageService.calculateWinRate()
        XCTAssertEqual(winRate, 75.0, accuracy: 0.01)
    }

    func testFetchHourlyDistractionCounts() {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())

        storageService.logSession(appName: "TikTok", outcome: .openedApp, durationMinutes: 10)
        storageService.logSession(appName: "TikTok", outcome: .exitedToWork, durationMinutes: 0)

        let hourlyCounts = storageService.fetchHourlyDistractionCounts()
        XCTAssertEqual(hourlyCounts[currentHour], 2)
    }
}
