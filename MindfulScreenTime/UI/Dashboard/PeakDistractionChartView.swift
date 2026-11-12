import SwiftUI
import Charts

public struct HourlyDistractionPoint: Identifiable {
    public var id: Int { hour }
    public let hour: Int
    public let count: Int
}

public struct PeakDistractionChartView: View {
    public let hourlyData: [Int: Int]

    public init(hourlyData: [Int: Int]) {
        self.hourlyData = hourlyData
    }

    private var chartPoints: [HourlyDistractionPoint] {
        (0...23).map { hour in
            HourlyDistractionPoint(hour: hour, count: hourlyData[hour, default: 0])
        }
    }

    private var peakHourInfo: (hour: Int, count: Int)? {
        let sorted = chartPoints.sorted { $0.count > $1.count }
        guard let first = sorted.first, first.count > 0 else { return nil }
        return (first.hour, first.count)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Giờ Vàng Xao Nhãng")
                        .font(.headline)
                        .foregroundColor(.white)

                    if let peak = peakHourInfo {
                        Text("Đỉnh điểm lúc \(peak.hour):00 – \(peak.hour + 1):00 (\(peak.count) lần)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("Chưa ghi nhận khung giờ xao nhãng nào hôm nay")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                Spacer()
                Image(systemName: "chart.bar.xaxis")
                    .foregroundColor(.cyan)
            }

            Chart(chartPoints) { point in
                BarMark(
                    x: .value("Khung giờ", "\(point.hour)h"),
                    y: .value("Số lần", point.count)
                )
                .foregroundStyle(
                    point.count == (peakHourInfo?.count ?? -1) && point.count > 0
                    ? LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                    : LinearGradient(colors: [.teal, .cyan.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: [0, 6, 12, 18, 23].map { "\($0)h" }) {
                    AxisValueLabel()
                        .foregroundStyle(Color.white.opacity(0.6))
                }
            }
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel()
                        .foregroundStyle(Color.white.opacity(0.6))
                }
            }
            .frame(height: 160)
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
