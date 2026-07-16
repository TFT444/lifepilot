import Foundation
import LifePilotCore

extension InsightsViewModel {
    func buildInsights(
        tasks: [TaskItem],
        events: [CalendarEvent],
        preferences: UserPreferences
    ) -> [LifeInsight] {
        var built: [LifeInsight] = []
        built.append(contentsOf: taskCompletionInsight(tasks: tasks))
        built.append(contentsOf: meetingLoadInsight(events: events))
        built.append(contentsOf: workBoundaryInsight(events: events, preferences: preferences))
        return built
    }

    private func taskCompletionInsight(tasks: [TaskItem]) -> [LifeInsight] {
        let completed = tasks.filter(\.isCompleted).count
        let open = tasks.filter { !$0.isCompleted }.count
        guard completed + open >= 3, !isDismissed("task-completion") else { return [] }
        return [
            LifeInsight(
                title: "Task completion",
                detail: "\(completed) completed, \(open) still open.",
                evidence: "Counted \(completed + open) local tasks.",
                method: "completed / total open+completed counts"
            ),
        ]
    }

    private func meetingLoadInsight(events: [CalendarEvent]) -> [LifeInsight] {
        let workMeetings = events.filter { $0.context == .work || $0.eventKind == .meeting }
        guard workMeetings.count >= 2, !isDismissed("meeting-load") else { return [] }
        let minutes = workMeetings.reduce(0) {
            $0 + Int($1.endDate.timeIntervalSince($1.startDate) / 60)
        }
        return [
            LifeInsight(
                title: "Meeting load",
                detail: "\(workMeetings.count) work/meeting blocks totaling ~\(minutes) minutes.",
                evidence: "Sum of local work/meeting event durations.",
                method: "count + duration sum of work/meeting events"
            ),
        ]
    }

    private func workBoundaryInsight(
        events: [CalendarEvent],
        preferences: UserPreferences
    ) -> [LifeInsight] {
        let workMeetings = events.filter { $0.context == .work || $0.eventKind == .meeting }
        let outside = workMeetings.filter { event in
            let hour = Calendar.current.component(.hour, from: event.startDate)
            return hour < preferences.workDayStartHour || hour >= preferences.workDayEndHour
        }
        guard !outside.isEmpty, !isDismissed("work-boundary") else { return [] }
        return [
            LifeInsight(
                title: "Work/life boundary",
                detail: "\(outside.count) meetings sit outside configured work hours.",
                evidence: "Compared event start hours to Settings work hours.",
                method: "hour vs workDayStartHour/workDayEndHour"
            ),
        ]
    }
}
