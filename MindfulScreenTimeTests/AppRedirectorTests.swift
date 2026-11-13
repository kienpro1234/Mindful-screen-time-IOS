import XCTest
@testable import MindfulScreenTime

final class AppRedirectorTests: XCTestCase {

    func testResolveKnownAppTargets() {
        let fb = AppRedirector.resolveTarget(for: "Facebook")
        XCTAssertEqual(fb?.customSchemeURL, URL(string: "fb://"))
        XCTAssertNil(fb?.universalLinkURL)

        let tiktok = AppRedirector.resolveTarget(for: "tiktok")
        XCTAssertEqual(tiktok?.customSchemeURL, URL(string: "snssdk1233://"))
        XCTAssertEqual(tiktok?.universalLinkURL, URL(string: "https://www.tiktok.com"))

        let youtube = AppRedirector.resolveTarget(for: "YouTube")
        XCTAssertEqual(youtube?.customSchemeURL, URL(string: "youtube://"))
        XCTAssertEqual(youtube?.universalLinkURL, URL(string: "https://www.youtube.com"))

        let instagram = AppRedirector.resolveTarget(for: "Instagram")
        XCTAssertEqual(instagram?.customSchemeURL, URL(string: "instagram://"))
        XCTAssertEqual(instagram?.universalLinkURL, URL(string: "https://www.instagram.com"))

        let zalo = AppRedirector.resolveTarget(for: "Zalo")
        XCTAssertEqual(zalo?.customSchemeURL, URL(string: "zalo://"))
    }

    func testResolveGenericOrUnknownAppReturnsNil() {
        XCTAssertNil(AppRedirector.resolveTarget(for: "Ứng dụng giải trí"))
        XCTAssertNil(AppRedirector.resolveTarget(for: "Giải Trí"))
        XCTAssertNil(AppRedirector.resolveTarget(for: "   "))
    }

    func testCanRedirectDirectlyMatchesKnownApps() {
        XCTAssertTrue(AppRedirector.canRedirectDirectly(appName: "Facebook"))
        XCTAssertTrue(AppRedirector.canRedirectDirectly(appName: "  tiktok "))
        XCTAssertFalse(AppRedirector.canRedirectDirectly(appName: "Ứng dụng giải trí"))
    }
}
