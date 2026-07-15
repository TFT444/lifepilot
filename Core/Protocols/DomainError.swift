/// Shared domain errors. Feature-specific errors may graduate to dedicated
/// enums once they need richer payloads (docs/ENGINEERING_GUIDE.md).
public enum DomainError: Error, Sendable, Equatable {
    case notFound
    case notFoundNamed(String)
    case unavailable
    case unavailableNamed(String)
    case unauthorized
    case conflict
    case validationFailed(field: String)
    case invalidState(String)
}
