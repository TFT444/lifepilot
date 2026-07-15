/// The five root tabs of LifePilot. Memory/Insights deepen later; Tasks is
/// first-class for the daily-life MVP.
public enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case home
    case timeline
    case tasks
    case insights
    case settings

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .home: return "Home"
        case .timeline: return "Timeline"
        case .tasks: return "Tasks"
        case .insights: return "Insights"
        case .settings: return "Settings"
        }
    }

    public var symbolName: String {
        switch self {
        case .home: return "house.fill"
        case .timeline: return "list.bullet.rectangle.fill"
        case .tasks: return "checkmark.circle.fill"
        case .insights: return "chart.line.uptrend.xyaxis"
        case .settings: return "gearshape.fill"
        }
    }
}
