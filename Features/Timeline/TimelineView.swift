import LifePilotCore
import LifePilotDesignSystem
import SwiftUI

/// Unified chronological view of events, tasks, reminders, and planning signals.
public struct TimelineView: View {
    @State private var viewModel: TimelineViewModel

    public init(timelineProvider: TimelineProviding) {
        _viewModel = State(initialValue: TimelineViewModel(timelineProvider: timelineProvider))
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.entries) { entry in
                    TimelineRow(content: .init(
                        time: entry.date.formatted(date: .omitted, time: .shortened),
                        title: entry.title,
                        subtitle: entry.subtitle,
                        accentColor: color(for: entry.kind)
                    ))
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.md)
        }
        .background(Color.LifePilot.backgroundPrimary)
        .navigationTitle("Timeline")
        .task { await viewModel.load() }
    }

    private func color(for kind: TimelineEntry.Kind) -> Color {
        switch kind {
        case .event: return Color.LifePilot.accentStart
        case .task: return Color.LifePilot.signalSuccess
        case .reminder: return Color.LifePilot.accentEnd
        case .recommendation: return Color.LifePilot.signalRisk
        case .signal: return Color.LifePilot.textSecondary
        }
    }
}

#Preview {
    NavigationStack {
        TimelineView(timelineProvider: PreviewTimelineProvider())
    }
}

private struct PreviewTimelineProvider: TimelineProviding {
    func loadEntries(relativeTo now: Date) async -> [TimelineEntry] {
        [TimelineEntry(date: now, title: "Design Review", subtitle: "Studio", kind: .event)]
    }
}
