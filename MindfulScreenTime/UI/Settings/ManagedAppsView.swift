import AppIntents
import SwiftUI
import UIKit

/// Main in-app app selector matching the streamlined One Sec onboarding workflow:
/// pick distracting apps via checkboxes, then jump straight into iOS Shortcuts to attach the 1-action Mindful block.
public struct ManagedAppsView: View {
    @ObservedObject private var store: ManagedAppsStore
    @State private var showingAddCustomSheet = false
    @State private var customAppName = ""
    @State private var customAppScheme = ""
    @State private var copiedChecklist = false
    @State private var showAllUninstalled = false

    public init(store: ManagedAppsStore = .shared) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryHeaderCard
                installedSectionCard
                if !store.otherItems.isEmpty {
                    otherAppsSectionCard
                }
                shortcutsActionCard
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(red: 0.05, green: 0.06, blue: 0.09).ignoresSafeArea())
        .onAppear {
            scanInstalledApps()
        }
        .sheet(isPresented: $showingAddCustomSheet) {
            addCustomAppSheet
        }
    }

    private var summaryHeaderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Chọn app muốn quản lý")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Text(
                        store.selectedAppNames.isEmpty
                            ? "Tick chọn các app hay gây xao nhãng để Mindful kiểm soát."
                            : "Đang chọn \(store.selectedAppNames.count) app: \(store.formattedSelectionChecklist())"
                    )
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
                }
                Spacer()
                Image(systemName: "checklist.checked")
                    .font(.title2)
                    .foregroundColor(.cyan)
            }

            HStack(spacing: 10) {
                Button {
                    withAnimation(.spring(response: 0.25)) {
                        store.selectRecommendedSocialPreset()
                    }
                } label: {
                    Label("Chọn nhanh MXH", systemImage: "sparkles")
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.cyan)
                        .cornerRadius(10)
                }

                Button {
                    scanInstalledApps()
                } label: {
                    Label("Quét lại máy", systemImage: "arrow.clockwise")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(10)
                }

                if !store.selectedAppNames.isEmpty {
                    Button {
                        withAnimation {
                            store.clearSelection()
                        }
                    } label: {
                        Text("Bỏ chọn")
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                    }
                }

                Spacer()
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.cyan.opacity(0.25), lineWidth: 1)
        )
    }

    private var installedSectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ứng dụng phát hiện trên iPhone")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Spacer()
                Button {
                    showingAddCustomSheet = true
                } label: {
                    Label("Thêm app", systemImage: "plus.circle.fill")
                        .font(.caption.bold())
                        .foregroundColor(.cyan)
                }
            }

            if store.installedItems.isEmpty {
                Text("Không tự quét thấy app nào trong danh sách cài sẵn — hãy mở \"Ứng dụng phổ biến khác\" bên dưới hoặc bấm \"+ Thêm app\".")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 8) {
                    ForEach(store.installedItems) { item in
                        appSelectionRow(item: item)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
    }

    private var otherAppsSectionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation {
                    showAllUninstalled.toggle()
                }
            } label: {
                HStack {
                    Text("Ứng dụng phổ biến khác (\(store.otherItems.count))")
                        .font(.subheadline.bold())
                        .foregroundColor(.white.opacity(0.85))
                    Spacer()
                    Image(systemName: showAllUninstalled ? "chevron.up" : "chevron.down")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            if showAllUninstalled || store.installedItems.isEmpty {
                VStack(spacing: 8) {
                    ForEach(store.otherItems) { item in
                        appSelectionRow(item: item)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
    }

    private func appSelectionRow(item: ManagedAppItem) -> some View {
        let isChecked = store.isSelected(item.name)
        return HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.22)) {
                    store.toggleSelection(for: item.name)
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: item.systemIconName)
                        .font(.body)
                        .foregroundColor(isChecked ? .cyan : .white.opacity(0.7))
                        .frame(width: 34, height: 34)
                        .background(isChecked ? Color.cyan.opacity(0.18) : Color.white.opacity(0.08))
                        .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                        Text(item.isCustom ? "App tùy chỉnh" : (item.isInstalled ? "Đã cài trên máy" : "Chưa phát hiện trên máy"))
                            .font(.caption2)
                            .foregroundColor(item.isInstalled ? .teal : .white.opacity(0.5))
                    }

                    Spacer()

                    Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isChecked ? .cyan : .white.opacity(0.35))
                }
            }

            if item.isCustom {
                Button {
                    withAnimation {
                        store.removeCustomApp(name: item.name)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                        .padding(6)
                }
            }
        }
        .padding(10)
        .background(isChecked ? Color.cyan.opacity(0.1) : Color.white.opacity(0.03))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isChecked ? Color.cyan.opacity(0.45) : Color.clear, lineWidth: 1)
        )
    }

    private var shortcutsActionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.shield.fill")
                    .foregroundColor(.teal)
                Text("Bước cuối: Gắn 1 hành động vào Phím Tắt")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }

            Text("Do Apple khóa quyền tự tạo Automation trên Apple ID miễn phí, bạn chỉ cần làm 3 chạm duy nhất 1 lần (không còn khối Nếu / Mở URL rắc rối):")
                .font(.caption)
                .foregroundColor(.white.opacity(0.75))

            VStack(alignment: .leading, spacing: 6) {
                stepBadge(number: "1", text: "Bấm nút xanh bên dưới → chọn Ứng dụng → tick đúng: \(store.selectedAppNames.isEmpty ? "Facebook, TikTok..." : store.formattedSelectionChecklist()) → bật Tự động hóa.")
                stepBadge(number: "2", text: "Tìm Mindful → chọn ĐÚNG 1 hành động: \"Bật Khoảng Lặng Mindful\".")
                stepBadge(number: "3", text: "Bấm Xong! Khi quay lại từ Mindful app sẽ tự mở lại app gốc không qua Safari.")
            }

            HStack(spacing: 10) {
                Button {
                    AppRedirector.openShortcutsAutomationCreator()
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.forward.app.fill")
                        Text("Mở Phím Tắt & Tạo Ngay")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(12)
                }

                if !store.selectedAppNames.isEmpty {
                    Button {
                        UIPasteboard.general.string = store.formattedSelectionChecklist()
                        copiedChecklist = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedChecklist = false
                        }
                    } label: {
                        Image(systemName: copiedChecklist ? "checkmark" : "doc.on.doc")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(13)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(12)
                    }
                }
            }

            ShortcutsLink()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 2)
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.teal.opacity(0.35), lineWidth: 1)
        )
    }

    private func stepBadge(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.caption2.bold())
                .foregroundColor(.black)
                .frame(width: 18, height: 18)
                .background(Color.cyan)
                .clipShape(Circle())
            Text(text)
                .font(.caption)
                .foregroundColor(.white.opacity(0.88))
        }
    }

    private var addCustomAppSheet: some View {
        NavigationStack {
            Form {
                Section("Thông tin ứng dụng") {
                    TextField("Tên ứng dụng (VD: Threads, Game...)", text: $customAppName)
                    TextField("URL Scheme mở lại (Tuỳ chọn, VD: threads)", text: $customAppScheme)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Thêm ứng dụng khác")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        showingAddCustomSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Thêm") {
                        store.addCustomApp(name: customAppName, customScheme: customAppScheme)
                        customAppName = ""
                        customAppScheme = ""
                        showingAddCustomSheet = false
                    }
                    .disabled(customAppName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func scanInstalledApps() {
        store.detectInstalledApps { url in
            UIApplication.shared.canOpenURL(url)
        }
    }
}
