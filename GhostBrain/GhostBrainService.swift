import LifePilotCore

/// Production planning entry point. Until optional AI enhancement is configured,
/// this always runs deterministic local rules via `DeterministicPlanningEngine`
/// (see App composition). Direct use still throws to prevent accidental
/// networking assumptions in Features.
public struct GhostBrainService: GhostBrainServing {
    public init() {}

    public func currentModel() async throws -> GhostBrainModel {
        throw DomainError.unavailableNamed(
            "Use DeterministicPlanningEngine + store-backed providers. "
                + "Optional AI enhancement is disabled by default."
        )
    }
}
