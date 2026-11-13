import AppIntents
import Foundation

public enum TargetAppOption: String, AppEnum, CaseIterable {
    case facebook
    case tiktok
    case youtube
    case instagram
    case zalo
    case messenger
    case threads
    case telegram
    case reddit
    case twitter
    case capcut
    case shopee
    case netflix
    case entertainment

    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Ứng dụng"

    public static var caseDisplayRepresentations: [TargetAppOption: DisplayRepresentation] = [
        .facebook: "Facebook",
        .tiktok: "TikTok",
        .youtube: "YouTube",
        .instagram: "Instagram",
        .zalo: "Zalo",
        .messenger: "Messenger",
        .threads: "Threads",
        .telegram: "Telegram",
        .reddit: "Reddit",
        .twitter: "X (Twitter)",
        .capcut: "CapCut",
        .shopee: "Shopee",
        .netflix: "Netflix",
        .entertainment: "Ứng dụng giải trí"
    ]

    public var displayName: String {
        switch self {
        case .facebook: return "Facebook"
        case .tiktok: return "TikTok"
        case .youtube: return "YouTube"
        case .instagram: return "Instagram"
        case .zalo: return "Zalo"
        case .messenger: return "Messenger"
        case .threads: return "Threads"
        case .telegram: return "Telegram"
        case .reddit: return "Reddit"
        case .twitter: return "X (Twitter)"
        case .capcut: return "CapCut"
        case .shopee: return "Shopee"
        case .netflix: return "Netflix"
        case .entertainment: return "Ứng dụng giải trí"
        }
    }
}

public struct CheckMindfulIntent: AppIntent {
    public static var title: LocalizedStringResource = "Kiểm tra tỉnh thức (Dự phòng 2 bước)"
    public static var description = IntentDescription("Trả về Có/Không để dùng với khối Nếu + Mở ứng dụng trên iOS cũ hoặc khi muốn dùng luồng dự phòng.")
    public static var openAppWhenRun: Bool = false

    @Parameter(title: "Ứng dụng", default: .facebook)
    public var targetApp: TargetAppOption

    public static var parameterSummary: some ParameterSummary {
        Summary("Kiểm tra \(\.$targetApp)")
    }

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let decision = TimerManager.shared.evaluateInterception(forAppName: targetApp.displayName)
        switch decision {
        case .bypass:
            return .result(value: false)
        case .intercept(let targetDisplayName):
            TimerManager.shared.setPendingInterceptApp(targetDisplayName)
            return .result(value: true)
        }
    }
}
