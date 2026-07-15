import XCTest
@testable import LifePilotCore

/// Guarantees finance/commerce/health agent kinds stay out of the Core surface.
final class FinanceScopeRemovalTests: XCTestCase {
    func testAgentKindExcludesBannedDomains() {
        let raw = Set(AgentKind.allCases.map(\.rawValue))
        for banned in ["finance", "shopping", "health", "email", "bank"] {
            XCTAssertFalse(raw.contains(banned), "Unexpected AgentKind.\(banned)")
        }
    }

    func testDaySignalKindsExcludeFinanceAndHealth() {
        let raw = Set(DaySignal.Kind.allCases.map(\.rawValue))
        XCTAssertFalse(raw.contains("finance"))
        XCTAssertFalse(raw.contains("health"))
    }

    func testActionTypesIncludeExplicitDenials() {
        XCTAssertEqual(ActionProposal.ActionType.forbiddenExternalFinancial.rawValue, "forbiddenExternalFinancial")
        XCTAssertEqual(ActionProposal.ActionType.forbiddenSendEmail.rawValue, "forbiddenSendEmail")
        XCTAssertFalse(SecurityPolicy().isAllowed(.forbiddenExternalFinancial))
        XCTAssertFalse(SecurityPolicy().isAllowed(.forbiddenSendEmail))
    }
}
