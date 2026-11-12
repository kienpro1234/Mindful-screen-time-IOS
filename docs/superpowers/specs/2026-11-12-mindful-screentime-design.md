# Design Document: Mindful Screen Time & Habit Optimizer (iOS)

- **Date:** 2026-11-12
- **Status:** Approved / Ready for Planning
- **Author:** Antigravity & User
- **Target Platform:** iOS 16.0+ (iPhone)
- **Account & Signing Model:** Free Personal Apple ID (Sideloadable via AltStore / Sideloadly)
- **Host Development Environment:** Windows (Source code & repo) + GitHub Actions (Cloud macOS build runner for `.ipa` creation)

---

## 1. Intent & Problem Statement
Modern smartphone users frequently suffer from involuntary, impulsive app usage (doomscrolling) on entertainment and social media apps. Traditional app blockers use hard cutoffs (complete lockouts) which often create frustration, leading users to disable or delete the blocker.

The goal of this application is **mindful friction and habit awareness**, rather than authoritarian blocking. It inserts gentle, conscious pauses at critical psychological moments (when launching an app and after prolonged usage), empowering the user to make a deliberate decision to disengage, while providing insightful habit analytics to optimize their digital wellbeing.

---

## 2. Goals, Non-Goals & Anti-Goals

### 2.1 Goals
- **Two-Layer Mindful Intervention:**
  - *Layer 1 (Pre-Open Friction):* Intercepts targeted entertainment apps upon opening with a reflective prompt: *"Bạn có chắc sẽ dùng ứng dụng này, nó có thể lấy đi sự tập trung và lãng phí thời gian"*. User can immediately exit to focus or proceed consciously.
  - *Layer 2 (Mid-Session Mindful Pause):* If an app is used continuously beyond a configured threshold (default: 15 minutes), a gentle shield/notification appears with a 5-second breathing countdown, offering a choice: *"Rời app và quay lại việc"* (primary action) or *"Cho tôi thêm 5 phút nữa"*.
- **Escalating Friction:** For consecutive extensions (+5 mins), friction progressively increases:
  - Extension 1: Quick button tap.
  - Extension 2: 10-second mindful pause.
  - Extension 3+: Must type a conscious statement: *"Tôi chấp nhận trì hoãn công việc để tiếp tục lướt"*.
- **Habit & Usage Analytics:**
  - *Peak Distraction Hours:* Visual breakdown of which hours in the day trigger the most entertainment usage.
  - *Mindful Win Rate:* Ratio and total count of times the user chose to exit/focus when challenged by a mindful nudge.
  - *Session Duration & Trend:* Tracking average session length over time using Swift Charts.
- **Free Apple ID Compatibility:** Must compile into a single unified Bundle ID that respects Apple's 3-app limit on free developer accounts and installs seamlessly without paid Enterprise/FamilyControls provisioning barriers.
- **Windows-Compatible Development Pipeline:** Complete Xcode project structure authored on Windows, built and packaged into installable test artifacts via automated GitHub Actions on cloud macOS runners.

### 2.2 Non-Goals
- **No Hard Permanent Lockouts:** The app will never permanently lock the user out of their device or emergency services.
- **No Cloud Backend or User Accounts:** Strictly local-first and on-device. No registration, no external servers, no privacy leaks.
- **No Non-Target App Interference:** Work, utility, education, or communication apps are excluded from friction.

### 2.3 Anti-Goals
- **No Annoying Spams:** Nudges must feel supportive, calm, and dignified, not shaming or harassing.
- **No Battery Drain:** Event-driven timers and background notifications consuming virtually 0% idle battery.

---

## 3. Architecture & Technical Strategy

### 3.1 Architectural Pivot for Free Apple ID Compatibility
*Context:* Apple strictly restricts the native `FamilyControls` entitlement (`com.apple.developer.family-controls`) and requires 4–5 separate App IDs (for extensions) which **cannot be provisioned by a free personal Apple ID**.

*The Proven Solution (The "One Sec" Mindful Architecture):*
To ensure 100% compatibility with free Apple IDs while delivering a richer, fully interactive experience:
1. **Unified App Architecture (1 Bundle ID):** Single standalone SwiftUI app containing the full Mindful UI, breathing animations, interactive typed pledges, and habit analytics dashboard. Fits comfortably within the 3-app free limit.
2. **Layer 1 (Pre-Open Interception):** Powered by iOS Shortcuts Automation (`When [App] is opened -> Open Mindful App`). Deep-links directly to the mindful intervention screen before the target app can steal attention.
3. **Layer 2 (In-Session Mindful Pause):** Upon conscious unlock, the app schedules a background session timer. At the threshold (15m), it fires a rich, high-priority mindful intervention notification with quick action buttons (`[Rời app để tập trung]` vs `[Gia hạn thêm]`).
4. **Interactive Friction Engine:** Because the UI runs directly in SwiftUI rather than Apple's static Shield template, we can provide:
   - Smooth animated breathing circles (expand on inhale, hold, shrink on exhale) with gentle haptic feedback (`UIImpactFeedbackGenerator`).
   - Live interactive text verification for tier-3 escalating friction.
5. **Local Data Persistence:** Uses SwiftData / CoreData on-device to log every session, win rate, and hourly usage pattern.

---

## 4. Component Structure

```text
MindfulScreenTime/
├── App/
│   ├── MindfulScreenTimeApp.swift       # App lifecycle & URL deep-link routing
│   └── NavigationCoordinator.swift     # Interception flow manager
├── Core/
│   ├── Storage/
│   │   ├── ModelContainer.swift        # SwiftData local storage
│   │   └── Models/                     # SessionLog, MindfulWin, DistractionStat
│   └── Engine/
│       ├── MindfulTimerManager.swift   # In-session tracking & background notifications
│       └── FrictionManager.swift       # Escalating friction logic (0 to 3+ extensions)
├── UI/
│   ├── Interventions/
│   │   ├── PreOpenFrictionView.swift   # "Khoảng lặng tỉnh thức" screen
│   │   ├── BreathingExerciseView.swift # 5-10s animated breathing guide
│   │   └── TypedPledgeView.swift       # Tier 3 commitment input screen
│   ├── Dashboard/
│   │   ├── DashboardView.swift         # Main tab: Win Rate & Daily Overview
│   │   ├── PeakHoursChartView.swift    # Swift Charts: Hourly distraction heatmap
│   │   └── HabitTrendsView.swift       # Weekly progress & session lengths
│   └── Settings/
│       ├── ProtectedAppsSetupView.swift# Guided shortcut configuration helper
│       └── ThresholdConfigView.swift   # Customize minutes (default: 15m)
└── CI_CD/
    └── .github/workflows/build.yml     # Automated cloud build on macOS runner
```

---

## 5. What Was Decided vs What Is Left to the Builder

### 5.1 Decided in Conversation with User
- **Intervention Style:** 2 layers (Pre-open prompt + Mid-session pause).
- **Pre-open Prompt Copy:** *"Bạn có chắc sẽ dùng ứng dụng này, nó có thể lấy đi sự tập trung và lãng phí thời gian"*.
- **Mid-Session Pause:** 5-minute extension allowance with escalating friction (tap -> breathing wait -> typed pledge).
- **Core Analytics:** Peak distraction hours, Mindful Win Rate, and session duration.
- **Account & Signing:** Free Personal Apple ID via AltStore / Sideloadly (1 unified Bundle ID, zero paid developer constraints).
- **Platform & Host OS:** Native iOS (Swift/SwiftUI) developed on Windows, compiled on GitHub Actions cloud macOS runner.

### 5.2 Left to the Builder
- **Color Palette & Visual Theme:** Deep calm minimalism (e.g., slate/indigo/deep charcoal with soft ambient accents for calming focus).
- **Shortcut Setup Onboarding:** A clean, 3-step visual guide in the app showing how to add the automated trigger in iOS Shortcuts.
- **XcodeGen Configuration:** A clean `project.yml` file to generate the complete Xcode project deterministically in CI/CD without needing macOS locally.
