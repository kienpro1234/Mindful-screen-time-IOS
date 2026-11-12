import XCTest
@testable import MindfulScreenTime

final class FrictionManagerTests: XCTestCase {
    var frictionManager: FrictionManager!

    override func setUp() {
        super.setUp()
        frictionManager = FrictionManager()
    }

    override func tearDown() {
        frictionManager = nil
        super.tearDown()
    }

    func testInitialFrictionTierIsQuickTap() {
        let tier = frictionManager.currentTier(for: "TikTok")
        XCTAssertEqual(tier, .quickTap)
    }

    func testEscalatingFrictionTiers() {
        // First extension -> Tier 1: quick tap
        let first = frictionManager.requestExtension(for: "TikTok")
        XCTAssertEqual(first, .quickTap)

        // Second consecutive extension -> Tier 2: breathing pause 10s
        let second = frictionManager.requestExtension(for: "TikTok")
        XCTAssertEqual(second, .breathingPause(seconds: 10))

        // Third consecutive extension -> Tier 3: typed pledge
        let third = frictionManager.requestExtension(for: "TikTok")
        XCTAssertEqual(third, .typedPledge(text: FrictionManager.defaultPledgeText))

        // Fourth consecutive extension -> remains at Tier 3
        let fourth = frictionManager.requestExtension(for: "TikTok")
        XCTAssertEqual(fourth, .typedPledge(text: FrictionManager.defaultPledgeText))
    }

    func testValidatePledgeMatchesTrimmedString() {
        // Review Focus 4: trimmed match
        let validExact = "Tôi chấp nhận trì hoãn công việc để tiếp tục lướt"
        XCTAssertTrue(frictionManager.validatePledge(input: validExact))

        let validWithWhitespace = "   Tôi chấp nhận trì hoãn công việc để tiếp tục lướt  \n"
        XCTAssertTrue(frictionManager.validatePledge(input: validWithWhitespace))

        let validCaseInsensitive = "tôi chấp nhận trì hoãn công việc để tiếp tục lướt"
        XCTAssertTrue(frictionManager.validatePledge(input: validCaseInsensitive))

        let invalidTypo = "Tôi chấp nhận trì hoãn công việc để xem tiếp"
        XCTAssertFalse(frictionManager.validatePledge(input: invalidTypo))

        let emptyString = ""
        XCTAssertFalse(frictionManager.validatePledge(input: emptyString))
    }

    func testResetFrictionIfExpired() {
        // Review Focus 3: Auto-reset after timeout
        _ = frictionManager.requestExtension(for: "TikTok")
        _ = frictionManager.requestExtension(for: "TikTok")
        XCTAssertEqual(frictionManager.currentTier(for: "TikTok"), .typedPledge(text: FrictionManager.defaultPledgeText))

        // Simulate idle timeout by setting past timestamp
        frictionManager.simulateSetLastActive(for: "TikTok", date: Date().addingTimeInterval(-31 * 60))
        frictionManager.resetFrictionIfExpired(for: "TikTok", idleThresholdMinutes: 30)

        XCTAssertEqual(frictionManager.currentTier(for: "TikTok"), .quickTap)
    }
}
