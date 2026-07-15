import LifePilotCore
import XCTest
@testable import LifePilotFeatures

@MainActor
final class TimelineViewModelTests: XCTestCase {
    func testLoadPopulatesEntriesSortedByDate() async {
        let later = Date().addingTimeInterval(3600)
        let earlier = Date()
        let provider = StubTimelineProvider(entries: [
            TimelineEntry(date: later, title: "Later", subtitle: nil, kind: .event),
            TimelineEntry(date: earlier, title: "Earlier", subtitle: nil, kind: .task),
        ])
        let viewModel = TimelineViewModel(timelineProvider: provider)

        await viewModel.load()

        XCTAssertEqual(viewModel.entries.count, 2)
        XCTAssertEqual(viewModel.entries.map(\.date), [earlier, later])
    }

    func testLoadIncludesEventAndTaskKinds() async {
        let provider = StubTimelineProvider(entries: [
            TimelineEntry(date: Date(), title: "Event", subtitle: nil, kind: .event),
            TimelineEntry(date: Date(), title: "Task", subtitle: nil, kind: .task),
        ])
        let viewModel = TimelineViewModel(timelineProvider: provider)

        await viewModel.load()

        let kinds = Set(viewModel.entries.map(\.kind))
        XCTAssertTrue(kinds.contains(.event))
        XCTAssertTrue(kinds.contains(.task))
    }
}

private struct StubTimelineProvider: TimelineProviding {
    let entries: [TimelineEntry]

    func loadEntries(relativeTo _: Date) async -> [TimelineEntry] {
        entries
    }
}
