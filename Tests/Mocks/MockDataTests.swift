import XCTest
@testable import LifePilotMocks

final class MockDataTests: XCTestCase {
    func testMockCalendarProducesNonEmptyEvents() {
        XCTAssertFalse(MockCalendar.events().isEmpty)
    }

    func testMockEmailProducesNonEmptyMessages() {
        XCTAssertFalse(MockEmail.messages().isEmpty)
    }

    func testMockTasksProducesNonEmptyItems() {
        XCTAssertFalse(MockTasks.items().isEmpty)
    }

    func testMockTravelProducesNonEmptyItineraries() {
        XCTAssertFalse(MockTravel.itineraries().isEmpty)
    }

    func testMockNotificationsProducesNonEmptyItems() {
        XCTAssertFalse(MockNotifications.items().isEmpty)
    }

    func testMockNotificationsContainNoFinanceSources() {
        let agents = MockNotifications.items().compactMap(\.sourceAgent)
        XCTAssertFalse(agents.contains { $0.displayName == "Finance" })
    }

    func testMockWeatherProducesAValidPrecipitationChance() {
        let snapshot = MockWeather.snapshot()
        XCTAssertGreaterThanOrEqual(snapshot.precipitationChance, 0)
        XCTAssertLessThanOrEqual(snapshot.precipitationChance, 1)
    }
}
