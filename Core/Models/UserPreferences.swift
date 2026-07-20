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
    public var skippedPermissionIDs: Set<String>

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
        appearance: AppearancePreference = .system,
        skippedPermissionIDs: Set<String> = []
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
        self.skippedPermissionIDs = skippedPermissionIDs
    }

    private enum CodingKeys: String, CodingKey {
        case onboardingCompleted
        case briefingHour
        case briefingMinute
        case quietHoursStart
        case quietHoursEnd
        case defaultTravelBufferMinutes
        case defaultPreparationMinutes
        case workDayStartHour
        case workDayEndHour
        case workDays
        case sensitiveNotificationPreviews
        case appearance
        case skippedPermissionIDs
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = UserPreferences()
        self.init(
            onboardingCompleted: try container.decodeIfPresent(
                Bool.self,
                forKey: .onboardingCompleted
            ) ?? defaults.onboardingCompleted,
            briefingHour: try container.decodeIfPresent(
                Int.self,
                forKey: .briefingHour
            ) ?? defaults.briefingHour,
            briefingMinute: try container.decodeIfPresent(
                Int.self,
                forKey: .briefingMinute
            ) ?? defaults.briefingMinute,
            quietHoursStart: try Self.decodeOptionalHour(
                .quietHoursStart,
                from: container,
                defaultValue: defaults.quietHoursStart
            ),
            quietHoursEnd: try Self.decodeOptionalHour(
                .quietHoursEnd,
                from: container,
                defaultValue: defaults.quietHoursEnd
            ),
            defaultTravelBufferMinutes: try container.decodeIfPresent(
                Int.self,
                forKey: .defaultTravelBufferMinutes
            ) ?? defaults.defaultTravelBufferMinutes,
            defaultPreparationMinutes: try container.decodeIfPresent(
                Int.self,
                forKey: .defaultPreparationMinutes
            ) ?? defaults.defaultPreparationMinutes,
            workDayStartHour: try container.decodeIfPresent(
                Int.self,
                forKey: .workDayStartHour
            ) ?? defaults.workDayStartHour,
            workDayEndHour: try container.decodeIfPresent(
                Int.self,
                forKey: .workDayEndHour
            ) ?? defaults.workDayEndHour,
            workDays: try container.decodeIfPresent(
                [Int].self,
                forKey: .workDays
            ) ?? defaults.workDays,
            sensitiveNotificationPreviews: try container.decodeIfPresent(
                Bool.self,
                forKey: .sensitiveNotificationPreviews
            ) ?? defaults.sensitiveNotificationPreviews,
            appearance: try container.decodeIfPresent(
                AppearancePreference.self,
                forKey: .appearance
            ) ?? defaults.appearance,
            skippedPermissionIDs: try container.decodeIfPresent(
                Set<String>.self,
                forKey: .skippedPermissionIDs
            ) ?? []
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(onboardingCompleted, forKey: .onboardingCompleted)
        try container.encode(briefingHour, forKey: .briefingHour)
        try container.encode(briefingMinute, forKey: .briefingMinute)
        try container.encodeIfPresent(quietHoursStart, forKey: .quietHoursStart)
        try container.encodeIfPresent(quietHoursEnd, forKey: .quietHoursEnd)
        try container.encode(defaultTravelBufferMinutes, forKey: .defaultTravelBufferMinutes)
        try container.encode(defaultPreparationMinutes, forKey: .defaultPreparationMinutes)
        try container.encode(workDayStartHour, forKey: .workDayStartHour)
        try container.encode(workDayEndHour, forKey: .workDayEndHour)
        try container.encode(workDays, forKey: .workDays)
        try container.encode(
            sensitiveNotificationPreviews,
            forKey: .sensitiveNotificationPreviews
        )
        try container.encode(appearance, forKey: .appearance)
        try container.encode(skippedPermissionIDs, forKey: .skippedPermissionIDs)
    }

    private static func decodeOptionalHour(
        _ key: CodingKeys,
        from container: KeyedDecodingContainer<CodingKeys>,
        defaultValue: Int?
    ) throws -> Int? {
        guard container.contains(key) else { return defaultValue }
        return try container.decodeIfPresent(Int.self, forKey: key)
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
    case restricted
    case limited
    case authorized
    case unavailable
}
