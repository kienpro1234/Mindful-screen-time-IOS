import AppIntents
import SwiftUI

/// Streamlined iOS 26/27 Shortcuts onboarding & fallback troubleshooting guide.
public struct ShortcutGuideView: View {
    @ObservedObject private var store: ManagedAppsStore
    @State private var showFallbackSteps = false

    public init(store: ManagedAppsStore = .shared) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerBanner
                oneActionGuideCard
                if !store.selectedAppNames.isEmpty {
                    selectedChecklistCard
                }
                fallbackDisclosureCard
            }
            .padding()
        }
        .background(Color(red: 0.05, green: 0.06, blue: 0.09).ignoresSafeArea())
    }

    private var headerBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Cài Phím Tắt chỉ với 1 hành động", systemImage: "wand.and.stars")
                .font(.headline)
                .foregroundColor(.cyan)

            Text("Từ bản cập nhật này, bạn không cần ghép khối Nếu hay Mở URL qua Safari nữa. Chỉ cần gán duy nhất 1 hành động \"Bật Khoảng Lặng Mindful\".")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.82))

            Button {
                AppRedirector.openShortcutsAutomationCreator()
            } label: {
                HStack {
                    Image(systemName: "arrow.up.forward.app.fill")
                    Text("Mở Phím Tắt (Tạo Tự Động Hóa)")
                }
                .font(.subheadline.bold())
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(12)
            }

            ShortcutsLink()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.cyan.opacity(0.28), lineWidth: 1)
        )
    }

    private var oneActionGuideCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hướng dẫn nhanh (iOS 26 / iOS 27)")
                .font(.subheadline.bold())
                .foregroundColor(.white)

            guideRow(
                number: "1",
                title: "Chọn trigger Ứng dụng",
                detail: "Trong Phím tắt -> thêm Tự động hóa / Ứng dụng -> tick các app bạn muốn (Facebook, TikTok, YouTube...) -> chọn \"Được mở\" -> bật Tự động hóa (Chạy ngay), tắt Thông báo."
            )
            guideRow(
                number: "2",
                title: "Thêm ĐÚNG 1 hành động",
                detail: "Tìm \"Mindful\" -> chọn \"Bật Khoảng Lặng Mindful\". Không cần thêm Nếu, không cần Mở URL."
            )
            guideRow(
                number: "3",
                title: "Xong & quay lại app mượt mà",
                detail: "Khi bạn chọn \"Tôi vẫn cần mở\", Mindful mở khóa 15 phút và tự chuyển thẳng về app gốc (hoặc hiện đúng các app bạn đã tick ở tab Chọn App)."
            )
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
    }

    private var selectedChecklistCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Danh sách bạn đã tick ở tab Chọn App:")
                .font(.caption.bold())
                .foregroundColor(.teal)
            Text(store.formattedSelectionChecklist())
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.teal.opacity(0.14))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.teal.opacity(0.35), lineWidth: 1)
        )
    }

    private var fallbackDisclosureCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation {
                    showFallbackSteps.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "lifepreserver")
                        .foregroundColor(.orange)
                    Text("Nếu máy hỏi popup \"Tiếp tục trong Mindful?\" hoặc dùng iOS cũ")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: showFallbackSteps ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            if showFallbackSteps {
                Text("Dùng 2 hành động dự phòng (hoàn toàn không hiện popup hỏi):\n1. Mindful -> \"Kiểm tra tỉnh thức (Dự phòng 2 bước)\" -> chọn từng app (VD: Facebook).\n2. Thêm khối \"Nếu\" (Kết quả là Có) -> \"Mở ứng dụng: Mindful\".\nMỗi app tách 1 tự động hóa riêng.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.orange.opacity(0.28), lineWidth: 1)
        )
    }

    private func guideRow(number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.caption.bold())
                .foregroundColor(.black)
                .frame(width: 22, height: 22)
                .background(Color.cyan)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.72))
            }
        }
    }
}
