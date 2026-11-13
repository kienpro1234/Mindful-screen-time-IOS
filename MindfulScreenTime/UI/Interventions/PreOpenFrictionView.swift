import SwiftUI

public struct PreOpenFrictionView: View {
    public let appName: String
    public let onExitToWork: () -> Void
    public let onProceedToApp: () -> Void

    @State private var activeSheet: ActiveInterventionSheet? = nil
    @State private var isShowingFallbackLauncher: Bool = false
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
            if isShowingFallbackLauncher {
                fallbackLauncherBody
            } else {
                mainInterventionBody
            }
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        unlockAndProceed()
                    }
                }
            case .typedPledge(let pledge):
                TypedPledgeView(
                    targetPledge: pledge,
                    onSuccess: {
                        activeSheet = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            unlockAndProceed()
                        }
                    },
                    onCancel: {
                        activeSheet = nil
                        handleExitToWork()
                    }
                )
            }
        }
    }

    private var mainInterventionBody: some View {
        VStack(spacing: 28) {
            Spacer()

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

            VStack(spacing: 16) {
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
    }

    private var fallbackLauncherBody: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 48))
                .foregroundColor(.teal)

            Text("Đã mở khóa 15 phút")
                .font(.title2.weight(.bold))
                .foregroundColor(.white)

            Text("Chọn ứng dụng bạn muốn tiếp tục sử dụng:")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.75))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(AppRedirector.knownTargets.prefix(6)) { target in
                    Button(action: {
                        onProceedToApp()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            AppRedirector.openTarget(target)
                        }
                    }) {
                        HStack {
                            Image(systemName: target.systemIconName)
                            Text(target.displayName)
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: onProceedToApp) {
                Text("Đóng")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.65))
                    .padding(.bottom, 32)
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

        if AppRedirector.canRedirectDirectly(appName: appName) {
            onProceedToApp()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                AppRedirector.openApp(named: appName)
            }
        } else {
            isShowingFallbackLauncher = true
        }
    }
}
