import SwiftUI

public struct PreOpenFrictionView: View {
    public let appName: String
    public let onExitToWork: () -> Void
    public let onProceedToApp: () -> Void

    @State private var activeSheet: ActiveInterventionSheet? = nil
    private let storageService = StorageService.shared
    private let frictionManager = FrictionManager.shared
    private let timerManager = TimerManager.shared

    private enum ActiveInterventionSheet: Identifiable {
        case breathing(seconds: Int)
        case typedPledge(pledge: String)

        var id: String {
            switch self {
            case .breathing(let s): return "breathing_\(s)"
            case .typedPledge(let p): return "pledge_\(p)"
            }
        }
    }

    public init(
        appName: String,
        onExitToWork: @escaping () -> Void,
        onProceedToApp: @escaping () -> Void
    ) {
        self.appName = appName
        self.onExitToWork = onExitToWork
        self.onProceedToApp = onProceedToApp
    }

    public var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Mindful Icon
            ZStack {
                Circle()
                    .fill(Color.teal.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(.cyan)
            }

            VStack(spacing: 12) {
                Text("Khoảng Lặng Tỉnh Thức")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Bạn có chắc sẽ dùng \(appName), nó có thể lấy đi sự tập trung và lãng phí thời gian.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.85))
                    .lineSpacing(4)
                    .padding(.horizontal, 28)
            }

            Spacer()

            // Action Buttons
            VStack(spacing: 16) {
                // Primary Action: Exit to focus (The Win)
                Button(action: handleExitToWork) {
                    HStack {
                        Image(systemName: "arrow.backward.circle.fill")
                        Text("Quay lại làm việc")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.cyan)
                    .cornerRadius(16)
                    .shadow(color: Color.cyan.opacity(0.35), radius: 10, y: 4)
                }

                // Secondary Action: Proceed with conscious awareness
                Button(action: handleRequestOpen) {
                    Text("Tôi vẫn cần mở")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.65))
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.1, blue: 0.15), Color(red: 0.04, green: 0.05, blue: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .fullScreenCover(item: $activeSheet) { sheet in
            switch sheet {
            case .breathing(let seconds):
                BreathingExerciseView(seconds: seconds) {
                    activeSheet = nil
                    unlockAndProceed()
                }
            case .typedPledge(let pledge):
                TypedPledgeView(
                    targetPledge: pledge,
                    onSuccess: {
                        activeSheet = nil
                        unlockAndProceed()
                    },
                    onCancel: {
                        activeSheet = nil
                        handleExitToWork()
                    }
                )
            }
        }
    }

    private func handleExitToWork() {
        storageService.logSession(appName: appName, outcome: .exitedToWork, durationMinutes: 0)
        onExitToWork()
    }

    private func handleRequestOpen() {
        let tier = frictionManager.currentTier(for: appName)
        switch tier {
        case .quickTap:
            unlockAndProceed()
        case .breathingPause(let seconds):
            activeSheet = .breathing(seconds: seconds)
        case .typedPledge(let text):
            activeSheet = .typedPledge(pledge: text)
        }
    }

    private func unlockAndProceed() {
        _ = frictionManager.requestExtension(for: appName)
        storageService.logSession(appName: appName, outcome: .openedApp, durationMinutes: 15)
        timerManager.scheduleMindfulPause(appName: appName, inMinutes: 15)
        onProceedToApp()
    }
}
