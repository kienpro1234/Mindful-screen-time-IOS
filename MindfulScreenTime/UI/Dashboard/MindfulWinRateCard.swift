import SwiftUI

public struct MindfulWinRateCard: View {
    public let winRate: Double
    public let totalWins: Int
    public let totalSessions: Int

    public init(winRate: Double, totalWins: Int, totalSessions: Int) {
        self.winRate = winRate
        self.totalWins = totalWins
        self.totalSessions = totalSessions
    }

    private var encouragementText: String {
        if totalSessions == 0 {
            return "Hãy kích hoạt tính năng nhắc nhở để bắt đầu rèn luyện sự tự chủ."
        }
        if winRate >= 70 {
            return "Xuất sắc! Bạn đang kiểm soát sự tập trung rất tốt."
        } else if winRate >= 40 {
            return "Khá tốt! Bạn đã nhiều lần chiến thắng cám dỗ lướt app."
        } else {
            return "Hãy kiên trì, từng khoảng dừng nhỏ sẽ giúp bạn lấy lại thời gian."
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Chiến Thắng Tỉnh Thức")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
            }

            HStack(spacing: 20) {
                // Circular Win Rate Gauge
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 10)
                        .frame(width: 84, height: 84)

                    Circle()
                        .trim(from: 0, to: CGFloat(min(max(winRate / 100.0, 0.0), 1.0)))
                        .stroke(
                            LinearGradient(colors: [.teal, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 84, height: 84)

                    Text("\(Int(winRate))%")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(totalWins) lần tự giác thoát app")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.cyan)

                    Text("trên tổng số \(totalSessions) lần chạm mở")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.65))

                    Text(encouragementText)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
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
}
