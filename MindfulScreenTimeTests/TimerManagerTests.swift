import XCTest
@testable import MindfulScreenTime

final class TimerManagerTests: XCTestCase {
    var timerManager: TimerManager!

    override func setUp() {
        super.setUp()
        timerManager = TimerManager()
    }

    override func tearDown() {
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
        // Spec requirements verbatim:
        // Title: "Dừng Lại Một Chút"
        // Body: "Bạn đã lướt được 15 phút rồi. Hãy dừng lại hít thở."
        let content = timerManager.makeNotificationContent(appName: "TikTok", inMinutes: 15)
        XCTAssertEqual(content.title, "Dừng Lại Một Chút")
        XCTAssertEqual(content.body, "Bạn đã lướt được 15 phút rồi. Hãy dừng lại hít thở.")
    }
}
