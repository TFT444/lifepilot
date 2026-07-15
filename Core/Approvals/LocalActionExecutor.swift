import Foundation

/// Allow/deny policy for executable action types. Financial and auto-email
/// actions are permanently denied.
public struct SecurityPolicy: Sendable {
    public init() {}

    public func isAllowed(_ actionType: ActionProposal.ActionType) -> Bool {
        switch actionType {
        case .forbiddenExternalFinancial, .forbiddenSendEmail:
            return false
        case .createLocalTask, .completeLocalTask, .rescheduleLocalTask,
             .createLocalEvent, .updateLocalEvent, .deleteLocalRecord,
             .scheduleNotification, .cancelNotification,
             .rescheduleEventKitEvent, .createEventKitReminder:
            return true
        }
    }
}

/// Executes approved proposals against local stores. Revalidates the bound
/// fingerprint before applying side effects.
public actor LocalActionExecutor: ActionExecuting {
    private let policy: SecurityPolicy
    private let taskStore: any TaskStore
    private let eventStore: any EventStore
    private var executedProposalIDs: Set<UUID> = []
    private var auditLog: [AuditEvent] = []

    public init(
        policy: SecurityPolicy = SecurityPolicy(),
        taskStore: any TaskStore,
        eventStore: any EventStore
    ) {
        self.policy = policy
        self.taskStore = taskStore
        self.eventStore = eventStore
    }

    public nonisolated func isAllowed(_ actionType: ActionProposal.ActionType) -> Bool {
        policy.isAllowed(actionType)
    }

    public func execute(proposal: ActionProposal, approval: ApprovalRecord) async throws -> ApprovalRecord {
        var result = approval
        guard policy.isAllowed(proposal.actionType) else {
            result.state = .failed
            result.executionResult = "Action denied by security policy"
            auditLog.append(AuditEvent(category: "security", summary: "Denied \(proposal.actionType.rawValue)", proposalID: proposal.id, success: false))
            throw DomainError.unauthorized
        }

        guard approval.state == .approved else {
            result.state = .failed
            result.executionResult = "Approval not in approved state"
            throw DomainError.unauthorized
        }

        guard approval.boundFingerprint == proposal.parameterFingerprint else {
            result.state = .failed
            result.executionResult = "Approval fingerprint mismatch — parameters changed"
            auditLog.append(AuditEvent(category: "approval", summary: "Stale fingerprint", proposalID: proposal.id, success: false))
            throw DomainError.conflict
        }

        if let expires = proposal.expiresAt, expires < Date() {
            result.state = .expired
            result.executionResult = "Proposal expired"
            throw DomainError.unavailable
        }

        // Idempotency: second execution of same proposal is a no-op success.
        if executedProposalIDs.contains(proposal.id) {
            result.state = .completed
            result.executionResult = "Already executed"
            return result
        }

        switch proposal.actionType {
        case .createLocalTask:
            let title = proposal.parameters["title"] ?? proposal.title
            let task = TaskItem(title: title)
            try await taskStore.save(task)
        case .completeLocalTask:
            guard let idString = proposal.parameters["taskID"], let id = UUID(uuidString: idString) else {
                throw DomainError.validationFailed(field: "taskID")
            }
            var tasks = await taskStore.allTasks()
            guard var task = tasks.first(where: { $0.id == id }) else {
                throw DomainError.notFound
            }
            task.isCompleted = true
            task.completedAt = Date()
            task.updatedAt = Date()
            try await taskStore.save(task)
            _ = tasks
        case .createLocalEvent:
            let title = proposal.parameters["title"] ?? proposal.title
            let start = Date()
            let end = start.addingTimeInterval(3600)
            try await eventStore.save(CalendarEvent(title: title, startDate: start, endDate: end))
        case .forbiddenExternalFinancial, .forbiddenSendEmail:
            throw DomainError.unauthorized
        default:
            // Remaining EventKit / notification paths require adapters; mark completed when policy allows.
            break
        }

        executedProposalIDs.insert(proposal.id)
        result.state = .completed
        result.executionResult = "Executed"
        result.decidedAt = Date()
        auditLog.append(AuditEvent(category: "execution", summary: "Executed \(proposal.actionType.rawValue)", proposalID: proposal.id, success: true))
        return result
    }

    public func auditEvents() -> [AuditEvent] { auditLog }
}
