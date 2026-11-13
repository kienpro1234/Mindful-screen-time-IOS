import SwiftUI

public struct DashboardView: View {
    @State private var winRate: Double = 0.0
    @State private var totalWins: Int = 0
    @State private var totalSessions: Int = 0
    @State private var hourlyData: [Int: Int] = [:]
    @State private var recentSessions: [SessionRecord] = []
    @State private var isShowingDemoIntervention: Bool = false

    @ObservedObject private var timerManager = TimerManager.shared
    private let storageService = StorageService.shared

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Warning Banner if Notifications are disabled (Review Focus 5)
                if !timerManager.isNotificationAuthorized {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Thông báo nhắc nhở đang bị tắt")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                            Text("Vui lòng bật thông báo trong Cài đặt iPhone để nhận nhắc nhở tạm dừng hít thở sau 15 phút.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Button("Mở Cài đặt") {
                                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(settingsURL)
                                }
                            }
                            .font(.caption.weight(.bold))
                            .foregroundColor(.orange)
                            .padding(.top, 2)
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(Color.orange.opacity(0.18))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                }

                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tỉnh Thức & Tập Trung")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Làm chủ thói quen sử dụng điện thoại")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.65))
                    }
                    Spacer()

                    // Quick test prompt button
                    Button(action: {
                        isShowingDemoIntervention = true
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.cyan)
                    }
                }
                .padding(.top, 8)

                // Win rate card
                MindfulWinRateCard(
                    winRate: winRate,
                    totalWins: totalWins,
                    totalSessions: totalSessions
                )

                // Peak hours distraction chart
                PeakDistractionChartView(hourlyData: hourlyData)

                // Recent activity section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hoạt động gần đây")
                        .font(.headline)
                        .foregroundColor(.white)

                    if recentSessions.isEmpty {
                        Text("Chưa có phiên can thiệp nào được ghi lại.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 24)
                    } else {
                        ForEach(recentSessions.prefix(5)) { record in
                            HStack {
                                Image(systemName: record.outcome.isWin ? "checkmark.circle.fill" : "arrow.forward.circle.fill")
                                    .foregroundColor(record.outcome.isWin ? .teal : .orange)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(record.appName)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.white)
                                    Text(record.outcome.displayName)
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Spacer()

                                Text(formatTime(record.timestamp))
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.45))
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.06))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color(red: 0.05, green: 0.06, blue: 0.09).ignoresSafeArea())
        .onAppear {
            refreshData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("MindfulSessionLogged"))) { _ in
            refreshData()
        }
        .fullScreenCover(isPresented: $isShowingDemoIntervention) {
            PreOpenFrictionView(
                appName: "TikTok",
                onExitToWork: {
                    isShowingDemoIntervention = false
                    refreshData()
                },
                onProceedToApp: {
                    isShowingDemoIntervention = false
                    refreshData()
                }
            )
        }
    }

    private func refreshData() {
        let sessions = storageService.fetchAllSessions()
        recentSessions = sessions.reversed()
        totalSessions = sessions.count
        totalWins = sessions.filter { $0.outcome.isWin }.count
        winRate = storageService.calculateWinRate()
        hourlyData = storageService.fetchHourlyDistractionCounts()
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
