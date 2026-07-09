/// Identifies which agent produced a given signal, prediction, or
/// recommendation. See the AI Agent System in README.md for what each
/// agent is responsible for at the product level.
public enum AgentKind: String, CaseIterable, Hashable, Sendable {
    case calendar
    case email
    case travel
    case finance
    case memory
    case reminder
    case shopping
    case health
    case security

    /// A short, display-ready name for the agent, used wherever the UI
    /// attributes a recommendation to its source per docs/MASTER_ROADMAP.md's
    /// Phase 6 UX requirement that agent output be attributable.
    public var displayName: String {
        switch self {
        case .calendar: return "Calendar"
        case .email: return "Email"
        case .travel: return "Travel"
        case .finance: return "Finance"
        case .memory: return "Memory"
        case .reminder: return "Reminder"
        case .shopping: return "Shopping"
        case .health: return "Health"
        case .security: return "Security"
        }
    }

    /// The SF Symbol used to represent this agent throughout the UI.
    public var symbolName: String {
        switch self {
        case .calendar: return "calendar"
        case .email: return "envelope.fill"
        case .travel: return "airplane"
        case .finance: return "dollarsign.circle.fill"
        case .memory: return "brain.head.profile"
        case .reminder: return "bell.fill"
        case .shopping: return "cart.fill"
        case .health: return "heart.fill"
        case .security: return "shield.fill"
        }
    }
}
