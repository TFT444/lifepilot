import Foundation

/// User-owned preference, routine, place, or correction. Never silently promote
/// a one-off action into permanent memory.
public struct MemoryItem: Identifiable, Hashable, Sendable, Codable {
    public let id: UUID
    public var kind: Kind
    public var title: String
    public var detail: String?
    public var tags: [String]
    public var isPinned: Bool
    public var provenance: String
    public var lastUsedAt: Date?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        kind: Kind,
        title: String,
        detail: String? = nil,
        tags: [String] = [],
        isPinned: Bool = false,
        provenance: String,
        lastUsedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.detail = detail
        self.tags = tags
        self.isPinned = isPinned
        self.provenance = provenance
        self.lastUsedAt = lastUsedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public enum Kind: String, CaseIterable, Sendable, Codable {
        case preference
        case routine
        case place
        case person
        case workPattern
        case travelBuffer
        case quietHours
        case correction
    }
}

/// App-level settings persisted locally.
public struct UserPreferences: Hashable, Sendable, Codable {
    public var onboardingCompleted: Bool
    public var briefingHour: Int
    public var briefingMinute: Int
    public var quietHoursStart: Int?
    public var quietHoursEnd: Int?
    public var defaultTravelBufferMinutes: Int
    public var defaultPreparationMinutes: Int
    public var workDayStartHour: Int
    public var workDayEndHour: Int
    public var workDays: [Int]
    public var sensitiveNotificationPreviews: Bool
    public var appearance: AppearancePreference

    public init(
        onboardingCompleted: Bool = false,
        briefingHour: Int = 7,
        briefingMinute: Int = 0,
        quietHoursStart: Int? = 22,
        quietHoursEnd: Int? = 7,
        defaultTravelBufferMinutes: Int = 15,
        defaultPreparationMinutes: Int = 10,
        workDayStartHour: Int = 9,
        workDayEndHour: Int = 17,
        workDays: [Int] = [2, 3, 4, 5, 6],
        sensitiveNotificationPreviews: Bool = false,
        appearance: AppearancePreference = .system
    ) {
        self.onboardingCompleted = onboardingCompleted
        self.briefingHour = briefingHour
        self.briefingMinute = briefingMinute
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
        self.defaultTravelBufferMinutes = defaultTravelBufferMinutes
        self.defaultPreparationMinutes = defaultPreparationMinutes
        self.workDayStartHour = workDayStartHour
        self.workDayEndHour = workDayEndHour
        self.workDays = workDays
        self.sensitiveNotificationPreviews = sensitiveNotificationPreviews
        self.appearance = appearance
    }

    public enum AppearancePreference: String, CaseIterable, Sendable, Codable {
        case system
        case light
        case dark
    }
}

/// Connection / permission capability for graceful degradation UIs.
public struct ConnectionCapability: Identifiable, Hashable, Sendable, Codable {
    public let id: String
    public var displayName: String
    public var state: PermissionState
    public var lastCheckedAt: Date?

    public init(
        id: String,
        displayName: String,
        state: PermissionState,
        lastCheckedAt: Date? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.state = state
        self.lastCheckedAt = lastCheckedAt
    }
}

public enum PermissionState: String, CaseIterable, Sendable, Codable {
    case notRequested
    case denied
    case limited
    case authorized
    case unavailable
}
