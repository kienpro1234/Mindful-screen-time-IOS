import SwiftUI

public struct ShortcutGuideView: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Cài Đặt Tự Động Hóa")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                    Text("Kết nối trực tiếp với iOS Shortcuts — không qua Safari, tự động quay lại app khi bạn đồng ý mở.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                guideStepCard(
                    stepNumber: 1,
                    icon: "app.badge.checkmark",
                    title: "Tạo Tự Động Hóa Cho Từng App",
                    description: "Mở app **Phím tắt (Shortcuts)** -> Tab **Tự động hóa** -> Dấu **(+)** -> Chọn **Ứng dụng** -> Chọn **1 app** (vd: Facebook) -> Tích **Được mở** -> Chọn **Chạy ngay lập tức** -> Bấm **Tiếp**."
                )

                guideStepCard(
                    stepNumber: 2,
                    icon: "checkmark.shield",
                    title: "Bước 1 trong tác vụ: Kiểm tra tỉnh thức",
                    description: "Chọn **Tự động hóa trống mới** -> Thanh tìm kiếm gõ **Mindful** -> Chọn tác vụ **Kiểm tra tỉnh thức** -> Chạm vào tên app để chọn đúng app tương ứng (vd: **Facebook**)."
                )

                guideStepCard(
                    stepNumber: 3,
                    icon: "arrow.triangle.branch",
                    title: "Bước 2 trong tác vụ: Nếu Cần -> Mở Mindful",
                    description: "Tìm và thêm tác vụ **Nếu (If)** (sẽ tự hiện: *Nếu Kiểm tra tỉnh thức là Có*). Sau đó tìm tác vụ **Mở ứng dụng (Open App)** -> Chọn **Mindful** và kéo khối **Mở ứng dụng** đặt vào giữa **Nếu** và **Ngược lại**."
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("Cấu trúc chuẩn trong Phím tắt:")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.cyan)

                    Text("""
                    1. Kiểm tra Facebook
                    2. Nếu [Kiểm tra Facebook] là Có
                           Mở ứng dụng [Mindful]
                       Ngược lại
                       Kết thúc Nếu
                    """)
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                }
                .padding(.top, 4)
            }
            .padding(20)
            .padding(.bottom, 32)
        }
        .background(Color(red: 0.05, green: 0.06, blue: 0.09).ignoresSafeArea())
    }

    private func guideStepCard(stepNumber: Int, icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.cyan.opacity(0.18))
                    .frame(width: 44, height: 44)
                Text("\(stepNumber)")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.cyan)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(.init(description))
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.75))
                    .lineSpacing(3)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
