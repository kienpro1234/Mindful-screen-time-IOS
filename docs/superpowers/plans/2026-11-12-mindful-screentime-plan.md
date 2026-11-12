# Mindful Screen Time & Habit Optimizer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a native iOS Mindful Screen Time application in Swift/SwiftUI that intercepts app launches with a reflective prompt ("Khoảng lặng tỉnh thức"), enforces escalating mindful friction on repeat extensions, tracks habit analytics (peak distraction hours, mindful win rate), and builds via GitHub Actions for free Apple ID sideloading.

**Architecture:** Single unified iOS app bundle using a deep-link interception engine (triggered via iOS Shortcuts Automation), local SwiftData/UserDefaults persistence, an escalating friction state engine, an in-session background countdown reminder manager, and Swift Charts for wellbeing visualization. Automated compilation and `.ipa` artifact generation is handled via XcodeGen and GitHub Actions running on macOS.

**Tech Stack:** Swift 5.9+, SwiftUI, Swift Charts, SwiftData / Local Storage, UserNotifications, XcodeGen, GitHub Actions CI/CD.

**Spec:** [docs/superpowers/specs/2026-11-12-mindful-screentime-design.md](file:///d:/App/App%20qu%E1%BA%A3n%20l%C3%BD%20d%C3%B9ng%20%E1%BB%A9ng%20d%E1%BB%A5ng/docs/superpowers/specs/2026-11-12-mindful-screentime-design.md)

## Global Constraints

- **Platform Target:** iOS 16.0+ (iPhone)
- **Deployment & Provisioning:** Single unified Bundle ID (`com.mindful.screentime`) compatible with Free Personal Apple ID sideloading (AltStore / Sideloadly)
- **Language & Frameworks:** Swift 5.9+, SwiftUI, Swift Charts, strictly zero third-party package dependencies for the core app
- **Copy Consistency (Verbatim from Spec):**
  - Pre-open Prompt Title: *"Khoảng Lặng Tỉnh Thức"*
  - Pre-open Prompt Body: *"Bạn có chắc sẽ dùng ứng dụng này, nó có thể lấy đi sự tập trung và lãng phí thời gian"*
  - Primary Action (Exit): *"Quay lại làm việc"*
  - Secondary Action (Proceed): *"Tôi vẫn cần mở"*
  - Mid-session Pause Title: *"Dừng Lại Một Chút"*
  - Mid-session Pause Body: *"Bạn đã lướt được 15 phút rồi. Hãy dừng lại hít thở."*
  - Mid-session Exit: *"Rời app và quay lại việc"*
  - Mid-session Extension: *"Cho tôi thêm 5 phút nữa"*
  - Tier 3 Typed Pledge: *"Tôi chấp nhận trì hoãn công việc để tiếp tục lướt"*

## Review Focus

1. **Unregistered or Empty App Parameter in Deep Link:** Opening `mindful://intercept` without `?app=...` or with an empty string must default gracefully to "Ứng dụng giải trí" instead of crashing or showing blank text.
2. **Rapid Repeated Launch Glitches:** Opening the app multiple times in quick succession must preserve existing extension counts rather than resetting the user's friction tier back to 0.
3. **Escalating Friction State Invalidation:** If the user hasn't opened the target app for over 30 minutes, the extension counter should reset to tier 0 so they aren't stuck on the typed pledge forever.
4. **Exact Match on Typed Pledge:** Leading/trailing spaces or lowercase/uppercase differences shouldn't block the user unfairly if trimmed, but typos in the pledge text must prevent unlocking.
5. **Notification Permission Denied:** If iOS notifications are denied, in-session Layer 2 reminders must fail gracefully with an in-app banner warning without terminating background session tracking.

---

### Task 1: Project Scaffolding & XcodeGen Specification

**Files:**
- Create: `project.yml`
- Create: `.gitignore`
- Create: `.github/workflows/build-ios.yml`

**Interfaces:**
- Produces: Xcode project generation spec targeting iOS 16.0, bundle ID `com.mindful.screentime`, and GitHub Actions workflow file that runs `xcodegen` and `xcodebuild` on `macos-14`.

- [ ] **Step 1: Write the XcodeGen specification `project.yml`**
  Define iOS 16.0 deployment target, single app target `MindfulScreenTime`, sources directory `MindfulScreenTime`, test target `MindfulScreenTimeTests`, and URL scheme `mindful`.

- [ ] **Step 2: Create `.gitignore` for iOS development**
  Include `.build/`, `DerivedData/`, `*.xcuserstate`, `*.xcworkspace`, and `.DS_Store`.

- [ ] **Step 3: Create GitHub Actions workflow `.github/workflows/build-ios.yml`**
  Set runner to `macos-14`, install `xcodegen`, generate project, run `xcodebuild build` and package unsigned `.ipa` artifact into build outputs.

- [ ] **Step 4: Verify syntax and file integrity**
  Ensure YAML syntax in `project.yml` and `build-ios.yml` is valid.

- [ ] **Step 5: Commit**
  `git add project.yml .gitignore .github/workflows/build-ios.yml && git commit -m "chore: add XcodeGen spec and GitHub Actions CI workflow"`

---

### Task 2: Core Data Models & Persistence Service

**Files:**
- Create: `MindfulScreenTime/Core/Storage/MindfulModels.swift`
- Create: `MindfulScreenTime/Core/Storage/StorageService.swift`
- Test: `MindfulScreenTimeTests/StorageServiceTests.swift`

**Interfaces:**
- Produces:
  - `struct SessionRecord: Codable, Identifiable` (`id: UUID`, `appName: String`, `timestamp: Date`, `outcome: SessionOutcome`, `durationMinutes: Double`)
  - `enum SessionOutcome: String, Codable` (`exitedToWork`, `openedApp`, `extendedSession`)
  - `protocol StorageServiceProtocol`: `func logSession(appName: String, outcome: SessionOutcome, durationMinutes: Double)`
  - `func fetchAllSessions() -> [SessionRecord]`
  - `func calculateWinRate() -> Double` (percentage of `exitedToWork` outcomes)
  - `func fetchHourlyDistractionCounts() -> [Int: Int]` (hour 0-23 to count of distraction attempts)

- [ ] **Step 1: Write the failing unit tests in `MindfulScreenTimeTests/StorageServiceTests.swift`**
  Write tests for `logSession`, `calculateWinRate` (e.g., 3 exits and 1 open = 75.0%), and `fetchHourlyDistractionCounts`.

- [ ] **Step 2: Verify test fails**
  Ensure tests fail due to missing `MindfulModels` and `StorageService`.

- [ ] **Step 3: Implement `MindfulModels.swift` and `StorageService.swift`**
  Implement `SessionRecord`, `SessionOutcome`, and `StorageService` using `UserDefaults` with JSON encoder/decoder for fast, zero-dependency, crash-resilient local persistence.

- [ ] **Step 4: Verify test passes**
  All calculations for win rate and hourly distributions match expectations.

- [ ] **Step 5: Commit**
  `git add MindfulScreenTime/Core/Storage/ MindfulScreenTimeTests/StorageServiceTests.swift && git commit -m "feat: add session data models and local storage service"`

---

### Task 3: Deep Link & Navigation Interception Engine

**Files:**
- Create: `MindfulScreenTime/Core/Engine/DeepLinkHandler.swift`
- Test: `MindfulScreenTimeTests/DeepLinkHandlerTests.swift`

**Interfaces:**
- Consumes: URL strings passed to the app on launch
- Produces:
  - `enum DeepLinkAction: Equatable` (`intercept(appName: String)`, `dashboard`, `breathing(appName: String)`, `unknown`)
  - `class DeepLinkHandler`: `static func parse(url: URL) -> DeepLinkAction`
  - URL format: `mindful://intercept?app=TikTok` or `mindful://dashboard`

- [ ] **Step 1: Write the failing unit tests in `MindfulScreenTimeTests/DeepLinkHandlerTests.swift`**
  Tests:
  - Parsing `mindful://intercept?app=TikTok` -> `.intercept(appName: "TikTok")`
  - Parsing `mindful://intercept?app=Facebook%20Reels` -> `.intercept(appName: "Facebook Reels")`
  - Parsing `mindful://intercept` (missing param) -> `.intercept(appName: "Ứng dụng giải trí")` (Review Focus 1)
  - Parsing `mindful://dashboard` -> `.dashboard`
  - Parsing invalid scheme `https://google.com` -> `.unknown`

- [ ] **Step 2: Verify test fails**
  Fails because `DeepLinkHandler` does not exist.

- [ ] **Step 3: Implement `DeepLinkHandler.swift`**
  Use `URLComponents` to parse scheme, host, and query items safely.

- [ ] **Step 4: Verify test passes**
  All URL parsing tests pass cleanly.

- [ ] **Step 5: Commit**
  `git add MindfulScreenTime/Core/Engine/DeepLinkHandler.swift MindfulScreenTimeTests/DeepLinkHandlerTests.swift && git commit -m "feat: add deep link interception handler"`

---

### Task 4: Escalating Friction State Engine

**Files:**
- Create: `MindfulScreenTime/Core/Engine/FrictionManager.swift`
- Test: `MindfulScreenTimeTests/FrictionManagerTests.swift`

**Interfaces:**
- Consumes: Target app name, extension requests
- Produces:
  - `enum FrictionTier: Equatable` (`quickTap`, `breathingPause(seconds: Int)`, `typedPledge(text: String)`)
  - `class FrictionManager`:
    - `func currentTier(for appName: String) -> FrictionTier`
    - `func requestExtension(for appName: String) -> FrictionTier`
    - `func resetFrictionIfExpired(for appName: String, idleThresholdMinutes: Int)`
    - `func validatePledge(input: String) -> Bool`

- [ ] **Step 1: Write failing unit tests in `MindfulScreenTimeTests/FrictionManagerTests.swift`**
  Tests:
  - Initial extension = `.quickTap` (Tier 1)
  - Consecutive 2nd extension = `.breathingPause(seconds: 10)` (Tier 2)
  - Consecutive 3rd extension = `.typedPledge(text: "Tôi chấp nhận trì hoãn công việc để tiếp tục lướt")` (Tier 3)
  - `validatePledge("  Tôi chấp nhận trì hoãn công việc để tiếp tục lướt  ")` -> `true` (Review Focus 4)
  - `validatePledge("Tôi muon xem tiep")` -> `false`
  - Auto-reset after 30 minutes of inactivity -> returns to `.quickTap` (Review Focus 3)

- [ ] **Step 2: Verify test fails**
  Fails due to missing `FrictionManager`.

- [ ] **Step 3: Implement `FrictionManager.swift`**
  Implement tier progression (0 -> 1 -> 2+), pledge string trimming and matching, and timestamp-based timeout reset.

- [ ] **Step 4: Verify test passes**
  All state transitions and pledge verification assertions pass.

- [ ] **Step 5: Commit**
  `git add MindfulScreenTime/Core/Engine/FrictionManager.swift MindfulScreenTimeTests/FrictionManagerTests.swift && git commit -m "feat: implement escalating friction state engine"`

---

### Task 5: In-Session Timer & Notification Manager (Layer 2)

**Files:**
- Create: `MindfulScreenTime/Core/Engine/TimerManager.swift`
- Test: `MindfulScreenTimeTests/TimerManagerTests.swift`

**Interfaces:**
- Consumes: App name, threshold duration (e.g. 15 minutes, or 5-minute extension)
- Produces:
  - `class TimerManager`:
    - `func scheduleMindfulPause(appName: String, inMinutes: Double)`
    - `func cancelActiveTimer(for appName: String)`
    - `func remainingSeconds(for appName: String) -> Double?`

- [ ] **Step 1: Write failing unit tests in `MindfulScreenTimeTests/TimerManagerTests.swift`**
  Tests scheduling, time calculation, remaining time queries, and cancellation.

- [ ] **Step 2: Verify test fails**
  Fails due to missing `TimerManager`.

- [ ] **Step 3: Implement `TimerManager.swift`**
  Integrate `UNUserNotificationCenter` for high-priority local notification scheduling with interactive actions (`Rời app` and `Gia hạn`), combined with an internal active session timer.

- [ ] **Step 4: Verify test passes**
  Timer math and mock notification triggers pass.

- [ ] **Step 5: Commit**
  `git add MindfulScreenTime/Core/Engine/TimerManager.swift MindfulScreenTimeTests/TimerManagerTests.swift && git commit -m "feat: implement in-session timer and notification scheduler"`

---

### Task 6: Mindful Intervention Views (Pre-Open & Interactive Pause)

**Files:**
- Create: `MindfulScreenTime/UI/Interventions/PreOpenFrictionView.swift`
- Create: `MindfulScreenTime/UI/Interventions/BreathingExerciseView.swift`
- Create: `MindfulScreenTime/UI/Interventions/TypedPledgeView.swift`

**Interfaces:**
- Consumes: `FrictionManager`, `StorageService`, `TimerManager`
- Produces:
  - `PreOpenFrictionView(appName: String, onExit: () -> Void, onProceed: () -> Void)`
  - `BreathingExerciseView(seconds: Int, onComplete: () -> Void)` (with animated circular pulse and haptics)
  - `TypedPledgeView(targetPledge: String, onSuccess: () -> Void)`

- [ ] **Step 1: Implement `BreathingExerciseView.swift`**
  Build animated circular breathing guide with smooth ease-in-out scale transitions (4s inhale, 4s exhale), countdown timer, and `UIImpactFeedbackGenerator` pulses.

- [ ] **Step 2: Implement `TypedPledgeView.swift`**
  Build a dedicated screen showing the pledge: *"Tôi chấp nhận trì hoãn công việc để tiếp tục lướt"*, a text input box, live validation status, and an unlock button enabled only on valid input.

- [ ] **Step 3: Implement `PreOpenFrictionView.swift`**
  Render the Layer 1 screen:
  - Title: *"Khoảng Lặng Tỉnh Thức"*
  - Body: *"Bạn có chắc sẽ dùng \(appName), nó có thể lấy đi sự tập trung và lãng phí thời gian"*
  - Primary button: *"Quay lại làm việc"* (calls `onExit`, logs `exitedToWork`)
  - Secondary button: *"Tôi vẫn cần mở"* (routes through friction check / `onProceed`, logs `openedApp`, schedules 15m timer)

- [ ] **Step 4: Verify SwiftUI View builds cleanly**
  Check that state bindings and previews are error-free.

- [ ] **Step 5: Commit**
  `git add MindfulScreenTime/UI/Interventions/ && git commit -m "feat: add mindful intervention views with breathing guide and typed pledge"`

---

### Task 7: Wellbeing Dashboard & Swift Charts Habit Analytics

**Files:**
- Create: `MindfulScreenTime/UI/Dashboard/DashboardView.swift`
- Create: `MindfulScreenTime/UI/Dashboard/PeakDistractionChartView.swift`
- Create: `MindfulScreenTime/UI/Dashboard/MindfulWinRateCard.swift`

**Interfaces:**
- Consumes: `StorageService`
- Produces:
  - `DashboardView`: Comprehensive overview displaying:
    - Daily Mindful Win Rate percentage & progress ring.
    - Total distraction interventions countered today.
    - `PeakDistractionChartView`: 24-hour bar chart using Swift Charts highlighting the peak hours (e.g. 14:00 - 15:00 or 22:00+).
    - Quick test launcher (allows testing mindful prompts directly).

- [ ] **Step 1: Implement `MindfulWinRateCard.swift`**
  Design a card showing circular win rate gauge, total interventions avoided vs total sessions opened, and encouraging feedback copy based on score.

- [ ] **Step 2: Implement `PeakDistractionChartView.swift`**
  Use `import Charts` to render hourly bar mark series with gradient styling, highlighting hours with highest intervention counts.

- [ ] **Step 3: Implement `DashboardView.swift`**
  Combine win rate card, peak distraction chart, and recent activity logs into a clean, modern, dark/light adaptive dashboard.

- [ ] **Step 4: Verify UI composition**
  Verify all chart data feeds from `StorageService` without crashes when session count is zero.

- [ ] **Step 5: Commit**
  `git add MindfulScreenTime/UI/Dashboard/ && git commit -m "feat: implement mindful dashboard with Swift Charts habit analytics"`

---

### Task 8: Shortcuts Automation Guide & Root App Wiring

**Files:**
- Create: `MindfulScreenTime/UI/Settings/ShortcutGuideView.swift`
- Create: `MindfulScreenTime/App/MindfulScreenTimeApp.swift`
- Create: `MindfulScreenTime/App/ContentView.swift`
- Create: `README.md`

**Interfaces:**
- Consumes: All UI components, `DeepLinkHandler`, `StorageService`
- Produces:
  - `MindfulScreenTimeApp`: Root SwiftUI app lifecycle handling `.onOpenURL` to switch between Dashboard and Intervention modal.
  - `ShortcutGuideView`: 3-step illustrated instructions for setting up iOS Shortcuts automation ("Khi mở TikTok -> Mở Mindful").
  - `README.md`: Clear, step-by-step instructions for compiling via GitHub Actions and installing on iPhone via AltStore/Sideloadly with a free Apple ID.

- [ ] **Step 1: Implement `ShortcutGuideView.swift`**
  Create an onboarding/settings view showing how to add an iOS Automation in Apple's built-in Shortcuts app in under 60 seconds.

- [ ] **Step 2: Implement `MindfulScreenTimeApp.swift` & `ContentView.swift`**
  Wire root view with `.onOpenURL` listener to trigger `PreOpenFrictionView` as a full-screen cover whenever a deep link is received.

- [ ] **Step 3: Write comprehensive `README.md`**
  Provide clear instructions for:
  1. Pushing repository to GitHub.
  2. Downloading the generated `.ipa` artifact from GitHub Actions.
  3. Sideloading onto iPhone using AltStore or Sideloadly with a free personal Apple ID.
  4. Setting up the Shortcuts automation.

- [ ] **Step 4: Verify end-to-end integration**
  Inspect file structure and dependencies to ensure complete self-containment.

- [ ] **Step 5: Commit**
  `git add MindfulScreenTime/App/ MindfulScreenTime/UI/Settings/ README.md && git commit -m "feat: complete root app wiring, shortcut guide, and documentation"`
