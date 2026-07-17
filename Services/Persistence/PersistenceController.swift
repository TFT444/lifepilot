import Foundation
import SwiftData

/// Owns the SwiftData `ModelContainer` for LifePilot-owned records.
public final class PersistenceController: @unchecked Sendable {
    public let container: ModelContainer
    public let isInMemory: Bool

    public static let shared = PersistenceController.makeShared()

    public init(inMemory: Bool = false) throws {
        let schema = Schema([
            PersistedTaskEntity.self,
            PersistedEventEntity.self,
            PersistedPreferenceEntity.self,
            PersistedMemoryEntity.self,
            PersistedApprovalEntity.self,
            PersistedAuditEntity.self,
        ])
        let configuration = ModelConfiguration(
            "LifePilot",
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        container = try ModelContainer(for: schema, configurations: [configuration])
        isInMemory = inMemory
    }

    private static func makeShared() -> PersistenceController {
        if let disk = try? PersistenceController(inMemory: false) {
            return disk
        }
        if let memory = try? PersistenceController(inMemory: true) {
            return memory
        }
        preconditionFailure("Unable to create LifePilot PersistenceController")
    }
}
