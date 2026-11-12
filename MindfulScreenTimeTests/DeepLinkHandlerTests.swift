import XCTest
@testable import MindfulScreenTime

final class DeepLinkHandlerTests: XCTestCase {

    func testParseStandardAppInterception() {
        guard let url = URL(string: "mindful://intercept?app=TikTok") else {
            XCTFail("Invalid test URL")
            return
        }
        let action = DeepLinkHandler.parse(url: url)
        XCTAssertEqual(action, .intercept(appName: "TikTok"))
    }

    func testParseEncodedAppName() {
        guard let url = URL(string: "mindful://intercept?app=Facebook%20Reels") else {
            XCTFail("Invalid test URL")
            return
        }
        let action = DeepLinkHandler.parse(url: url)
        XCTAssertEqual(action, .intercept(appName: "Facebook Reels"))
    }

    func testParseMissingAppParameterDefaultsGracefully() {
        // Review Focus 1: missing param defaults to "Ứng dụng giải trí"
        guard let url = URL(string: "mindful://intercept") else {
            XCTFail("Invalid test URL")
            return
        }
        let action = DeepLinkHandler.parse(url: url)
        XCTAssertEqual(action, .intercept(appName: "Ứng dụng giải trí"))
    }

    func testParseEmptyAppParameterDefaultsGracefully() {
        guard let url = URL(string: "mindful://intercept?app=") else {
            XCTFail("Invalid test URL")
            return
        }
        let action = DeepLinkHandler.parse(url: url)
        XCTAssertEqual(action, .intercept(appName: "Ứng dụng giải trí"))
    }

    func testParseDashboardAction() {
        guard let url = URL(string: "mindful://dashboard") else {
            XCTFail("Invalid test URL")
            return
        }
        let action = DeepLinkHandler.parse(url: url)
        XCTAssertEqual(action, .dashboard)
    }

    func testParseInvalidSchemeReturnsUnknown() {
        guard let url = URL(string: "https://google.com") else {
            XCTFail("Invalid test URL")
            return
        }
        let action = DeepLinkHandler.parse(url: url)
        XCTAssertEqual(action, .unknown)
    }
}
