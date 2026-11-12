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
                    Text("Kích hoạt tính năng can thiệp tự động khi mở ứng dụng giải trí chỉ trong 3 bước")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                // Step 1
                guideStepCard(
                    stepNumber: 1,
                    icon: "app.badge.checkmark",
                    title: "Mở ứng dụng Phím tắt (Shortcuts)",
                    description: "Trên iPhone, mở app **Phím tắt** có sẵn của Apple -> Chọn tab **Tự động hóa (Automation)** ở thanh dưới cùng -> Bấm dấu **(+)** để tạo mới."
                )

                // Step 2
                guideStepCard(
                    stepNumber: 2,
                    icon: "slider.horizontal.3",
                    title: "Chọn điều kiện: Khi Mở Ứng Dụng",
                    description: "Chọn mục **Ứng dụng (App)** -> Đánh dấu **Được mở (Is Opened)** -> Chọn các app bạn muốn quản lý (vd: TikTok, Facebook, YouTube) -> Chọn **Chạy ngay lập tức (Run Immediately)**."
                )

                // Step 3
                guideStepCard(
                    stepNumber: 3,
                    icon: "link.circle.fill",
                    title: "Thêm tác vụ Mở URL",
                    description: "Bấm **Tự động hóa trống mới** -> Thêm tác vụ **Mở URL** -> Dán đường dẫn sau:\n\n`mindful://intercept?app=TikTok`\n\n(Thay TikTok bằng tên ứng dụng tương ứng)."
                )

                // Test URL helper button
                VStack(alignment: .leading, spacing: 10) {
                    Text("URL mẫu để copy:")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.cyan)

                    HStack {
                        Text("mindful://intercept?app=TikTok")
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            UIPasteboard.general.string = "mindful://intercept?app=TikTok"
                        }) {
                            Image(systemName: "doc.on.doc.fill")
                                .foregroundColor(.cyan)
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(10)
                }
                .padding(.top, 8)
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
