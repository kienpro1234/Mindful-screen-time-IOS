import SwiftUI

public struct ContentView: View {
    @Binding var interceptedAppName: String?

    public init(interceptedAppName: Binding<String?>) {
        self._interceptedAppName = interceptedAppName
    }

    public var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
                    .navigationTitle("Mindful")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Tổng Quan", systemImage: "sparkles")
            }

            NavigationStack {
                ShortcutGuideView()
                    .navigationTitle("Tự Động Hóa")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Cài Đặt", systemImage: "gearshape.fill")
            }
        }
        .accentColor(.cyan)
        .fullScreenCover(item: Binding<IdentifiedString?>(
            get: {
                if let name = interceptedAppName {
                    return IdentifiedString(value: name)
                }
                return nil
            },
            set: { newValue in
                interceptedAppName = newValue?.value
            }
        )) { item in
            PreOpenFrictionView(
                appName: item.value,
                onExitToWork: {
                    interceptedAppName = nil
                },
                onProceedToApp: {
                    interceptedAppName = nil
                }
            )
        }
    }
}

public struct IdentifiedString: Identifiable {
    public var id: String { value }
    public let value: String

    public init(value: String) {
        self.value = value
    }
}
