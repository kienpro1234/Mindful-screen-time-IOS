import XCTest
@testable import MindfulScreenTime

final class TimerManagerTests: XCTestCase {
    var timerManager: TimerManager!
    let testSuite = "test.mindful.timer"

    override func setUp() {
        super.setUp()
        if let defaults = UserDefaults(suiteName: testSuite) {
            defaults.removePersistentDomain(forName: testSuite)
        }
        timerManager = TimerManager(suiteName: testSuite)
    }

    override func tearDown() {
        if let defaults = UserDefaults(suiteName: testSuite) {
            defaults.removePersistentDomain(forName: testSuite)
        }
        timerManager = nil
        super.tearDown()
    }

    func testScheduleMindfulPause() {
        XCTAssertNil(timerManager.remainingSeconds(for: "TikTok"))

        timerManager.scheduleMindfulPause(appName: "TikTok", inMinutes: 15.0)

        guard let remaining = timerManager.remainingSeconds(for: "TikTok") else {
            XCTFail("Timer should be active")
            return
        }

        XCTAssertGreaterThan(remaining, 14 * 60)
        XCTAssertLessThanOrEqual(remaining, 15 * 60)
    }

    func testCancelActiveTimer() {
        timerManager.scheduleMindfulPause(appName: "TikTok", inMinutes: 15.0)
        XCTAssertNotNil(timerManager.remainingSeconds(for: "TikTok"))

        timerManager.cancelActiveTimer(for: "TikTok")
        XCTAssertNil(timerManager.remainingSeconds(for: "TikTok"))
    }

    func testNotificationContentCopy() {
        let content = timerManager.makeNotificationContent(appName: "TikTok", inMinutes: 15)
        XCTAssertEqual(content.title, "Dừng Lại Một Chút")
        XCTAssertEqual(content.body, "Bạn đã lướt được 15 phút rồi. Hãy dừng lại hít thở.")
    }

    func testActiveSessionPersistsAcrossInstances() {
        timerManager.scheduleMindfulPause(appName: "Facebook", inMinutes: 15.0)

        let secondInstance = TimerManager(suiteName: testSuite)
        XCTAssertTrue(secondInstance.isSessionUnlocked(for: "Facebook"))
        XCTAssertNotNil(secondInstance.remainingSeconds(for: "Facebook"))
    }

    func testIsSessionUnlockedCaseInsensitive() {
        timerManager.scheduleMindfulPause(appName: "Facebook", inMinutes: 15.0)

        XCTAssertTrue(timerManager.isSessionUnlocked(for: "facebook"))
        XCTAssertTrue(timerManager.isSessionUnlocked(for: "  FACEBOOK  "))
        XCTAssertFalse(timerManager.isSessionUnlocked(for: "TikTok"))
    }

    func testPendingInterceptAppSetAndConsume() {
        XCTAssertNil(timerManager.consumePendingInterceptApp())

        timerManager.setPendingInterceptApp("Facebook")
        let secondInstance = TimerManager(suiteName: testSuite)

        XCTAssertEqual(secondInstance.consumePendingInterceptApp(), "Facebook")
        XCTAssertNil(secondInstance.consumePendingInterceptApp())
    }
}
