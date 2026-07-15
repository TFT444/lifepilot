import Foundation
import LifePilotCore

/// Sample notifications for previews and tests — daily-life only.
public enum MockNotifications {
    public static func items(relativeTo now: Date = Date()) -> [NotificationItem] {
        [
            NotificationItem(
                title: "Travel update",
                body: "Leave 15 minutes earlier for your afternoon event.",
                receivedAt: now.addingTimeInterval(-30 * 60),
                sourceAgent: .travel,
                isRead: false
            ),
            NotificationItem(
                title: "Task due soon",
                body: "Send updated deck is due within three hours.",
                receivedAt: now.addingTimeInterval(-2 * 3600),
                sourceAgent: .task,
                isRead: false
            ),
            NotificationItem(
                title: "Morning briefing ready",
                body: "Your day is prepared — 3 recommendations waiting.",
                receivedAt: now.addingTimeInterval(-6 * 3600),
                sourceAgent: .planning,
                isRead: true
            ),
        ]
    }
}
