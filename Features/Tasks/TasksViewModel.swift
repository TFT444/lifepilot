import Foundation
import LifePilotCore
import Observation

/// Task list screen state: Inbox / Today / Upcoming / Completed.
@Observable
@MainActor
public final class TasksViewModel {
    public private(set) var tasks: [TaskItem] = []
    public private(set) var filter: TaskFilter = .today
    public private(set) var isLoading = false
    public var draftTitle = ""

    private let taskStore: any TaskStore
    private let clock: any ClockProviding

    public init(taskStore: any TaskStore, clock: any ClockProviding = SystemClock()) {
        self.taskStore = taskStore
        self.clock = clock
    }

    public enum TaskFilter: String, CaseIterable, Sendable {
        case inbox
        case today
        case upcoming
        case completed
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        let all = await taskStore.allTasks()
        let now = clock.now()
        let calendar = Calendar.current
        switch filter {
        case .inbox:
            tasks = all.filter { task in
                !task.isCompleted && (task.listID == nil || task.listID == TaskList.inbox.id)
            }
        case .today:
            tasks = all.filter { task in
                guard !task.isCompleted, let due = task.dueDate else { return false }
                return calendar.isDateInToday(due) || due < now
            }
        case .upcoming:
            tasks = all.filter { task in
                guard !task.isCompleted, let due = task.dueDate else { return false }
                return due > now && !calendar.isDateInToday(due)
            }
        case .completed:
            tasks = all.filter(\.isCompleted)
        }
    }

    public func setFilter(_ filter: TaskFilter) async {
        self.filter = filter
        await load()
    }

    public func quickCapture() async throws {
        let title = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let task = TaskItem(title: title, dueDate: clock.now().addingTimeInterval(3600))
        try await taskStore.save(task)
        draftTitle = ""
        await load()
    }

    public func toggleCompletion(_ task: TaskItem) async throws {
        var updated = task
        updated.isCompleted.toggle()
        updated.completedAt = updated.isCompleted ? clock.now() : nil
        updated.updatedAt = clock.now()
        try await taskStore.save(updated)
        await load()
    }
}
