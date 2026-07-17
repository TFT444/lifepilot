import XCTest
@testable import LifePilotAppShell

final class AppTabTests: XCTestCase {
    func testAllFiveTabsExist() {
        XCTAssertEqual(AppTab.allCases.count, 5)
        XCTAssertTrue(AppTab.allCases.contains(.home))
        XCTAssertTrue(AppTab.allCases.contains(.timeline))
        XCTAssertTrue(AppTab.allCases.contains(.tasks))
        XCTAssertTrue(AppTab.allCases.contains(.insights))
        XCTAssertTrue(AppTab.allCases.contains(.settings))
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("memory"))
    }

    func testEveryTabHasATitleAndSymbol() {
        for tab in AppTab.allCases {
            XCTAssertFalse(tab.title.isEmpty)
            XCTAssertFalse(tab.symbolName.isEmpty)
        }
    }
}
