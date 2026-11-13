import XCTest
@testable import MindfulScreenTime

final class ManagedAppsStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: ManagedAppsStore!
    private var timerManager: TimerManager!

    override func setUp() {
        super.setUp()
        suiteName = "mindful_managed_apps_test_\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        store = ManagedAppsStore(userDefaults: defaults)
        timerManager = TimerManager(suiteName: suiteName)
    }

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testToggleSelectionAndPersistenceAcrossInstances() {
        XCTAssertFalse(store.isSelected("Facebook"))

        store.toggleSelection(for: "Facebook")
        store.toggleSelection(for: "TikTok")
        XCTAssertTrue(store.isSelected("facebook"))
        XCTAssertTrue(store.isSelected("TikTok"))

        let reloaded = ManagedAppsStore(userDefaults: defaults)
        XCTAssertEqual(Set(reloaded.selectedAppNames), Set(["Facebook", "TikTok"]))
        XCTAssertTrue(reloaded.isSelected("FACEBOOK"))
    }

    func testDetectInstalledAppsSeparatesInstalledAndOtherItems() {
        store.detectInstalledApps { url in
            url.scheme == "fb" || url.scheme == "youtube"
        }

        let installedNames = store.installedItems.map(\.name)
        XCTAssertTrue(installedNames.contains("Facebook"))
        XCTAssertTrue(installedNames.contains("YouTube"))
        XCTAssertFalse(installedNames.contains("TikTok"))
        XCTAssertTrue(store.otherItems.contains { $0.name == "TikTok" })
    }

    func testAddAndRemoveCustomAppSanitizesSchemeAndSelectsByDefault() {
        store.addCustomApp(name: "Threads Lite", customScheme: "threadslite")

        XCTAssertTrue(store.isSelected("Threads Lite"))
        let target = store.launchTarget(for: "Threads Lite")
        XCTAssertEqual(target?.customSchemeURL.absoluteString, "threadslite://")

        // Adding empty or whitespace name is ignored
        store.addCustomApp(name: "   ", customScheme: "invalid")
        XCTAssertEqual(store.selectedTargets().count, 1)

        // Removing custom app removes both selection and item
        store.removeCustomApp(name: "Threads Lite")
        XCTAssertFalse(store.isSelected("Threads Lite"))
        XCTAssertNil(store.launchTarget(for: "Threads Lite"))
    }

    func testSingleSelectedAppNameIfUniqueReturnsOnlyWhenExactlyOneSelected() {
        XCTAssertNil(store.singleSelectedAppNameIfUnique())

        store.setSelected(true, for: "TikTok")
        XCTAssertEqual(store.singleSelectedAppNameIfUnique(), "TikTok")

        store.setSelected(true, for: "YouTube")
        XCTAssertNil(store.singleSelectedAppNameIfUnique())
    }

    func testLaunchPassPreventsLoopAndExpires() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        XCTAssertFalse(timerManager.hasActiveLaunchPass(now: now))

        timerManager.grantLaunchPass(duration: 6.0, now: now)
        XCTAssertTrue(timerManager.hasActiveLaunchPass(now: now.addingTimeInterval(2.0)))
        XCTAssertFalse(timerManager.hasActiveLaunchPass(now: now.addingTimeInterval(7.0)))
    }

    func testEvaluateInterceptionRoutesSpecificAndAutoSelectedAppsCorrectly() {
        let now = Date(timeIntervalSince1970: 2_000_000)

        // With 1 selected app and nil param -> auto-resolves to that single app
        store.setSelected(true, for: "YouTube")
        XCTAssertEqual(
            timerManager.evaluateInterception(forAppName: nil, managedApps: store, now: now),
            .intercept(targetDisplayName: "YouTube")
        )

        // With multiple selected apps and nil param -> returns multi-app sentinel
        store.setSelected(true, for: "Facebook")
        XCTAssertEqual(
            timerManager.evaluateInterception(forAppName: nil, managedApps: store, now: now),
            .intercept(targetDisplayName: TimerManager.multiAppSentinel)
        )

        // Active Launch Pass bypasses interception regardless of app
        timerManager.grantLaunchPass(duration: 6.0, now: now)
        XCTAssertEqual(
            timerManager.evaluateInterception(forAppName: nil, managedApps: store, now: now.addingTimeInterval(1.0)),
            .bypass
        )
        XCTAssertEqual(
            timerManager.evaluateInterception(forAppName: "Facebook", managedApps: store, now: now.addingTimeInterval(1.0)),
            .bypass
        )

        // Unlocked specific app bypasses even after Launch Pass expires
        timerManager.scheduleMindfulPause(appName: "Facebook", inMinutes: 15)
        XCTAssertEqual(
            timerManager.evaluateInterception(forAppName: "Facebook", managedApps: store, now: now.addingTimeInterval(10.0)),
            .bypass
        )
        XCTAssertEqual(
            timerManager.evaluateInterception(forAppName: "YouTube", managedApps: store, now: now.addingTimeInterval(10.0)),
            .intercept(targetDisplayName: "YouTube")
        )
    }
}
