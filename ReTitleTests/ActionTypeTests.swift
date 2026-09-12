import XCTest
@testable import ReTitle

final class ActionTypeTests: XCTestCase {

    // MARK: - Raw Value Tests

    func testActionTypeRawValues() {
        XCTAssertEqual(ActionType.searchReplace.rawValue, "Replace")
        XCTAssertEqual(ActionType.insert.rawValue, "Insert")
        XCTAssertEqual(ActionType.remove.rawValue, "Remove")
        XCTAssertEqual(ActionType.caseChange.rawValue, "Case")
        XCTAssertEqual(ActionType.numbering.rawValue, "Number")
        XCTAssertEqual(ActionType.dateTime.rawValue, "Date/Time")
        XCTAssertEqual(ActionType.exif.rawValue, "Metadata")
    }

    // MARK: - Identifiable Tests

    func testActionTypeIdentifiable() {
        XCTAssertEqual(ActionType.searchReplace.id, "Replace")
        XCTAssertEqual(ActionType.insert.id, "Insert")
        XCTAssertEqual(ActionType.remove.id, "Remove")
        XCTAssertEqual(ActionType.caseChange.id, "Case")
        XCTAssertEqual(ActionType.numbering.id, "Number")
        XCTAssertEqual(ActionType.dateTime.id, "Date/Time")
        XCTAssertEqual(ActionType.exif.id, "Metadata")
    }

    // MARK: - CaseIterable Tests

    func testActionTypeAllCases() {
        XCTAssertEqual(ActionType.allCases.count, 7)
        XCTAssertTrue(ActionType.allCases.contains(.searchReplace))
        XCTAssertTrue(ActionType.allCases.contains(.insert))
        XCTAssertTrue(ActionType.allCases.contains(.remove))
        XCTAssertTrue(ActionType.allCases.contains(.caseChange))
        XCTAssertTrue(ActionType.allCases.contains(.numbering))
        XCTAssertTrue(ActionType.allCases.contains(.dateTime))
        XCTAssertTrue(ActionType.allCases.contains(.exif))
    }

    // MARK: - Equatable Tests

    func testActionTypeEquatable() {
        XCTAssertEqual(ActionType.searchReplace, ActionType.searchReplace)
        XCTAssertNotEqual(ActionType.searchReplace, ActionType.insert)
        XCTAssertNotEqual(ActionType.caseChange, ActionType.remove)
    }

    // MARK: - Hashable Tests

    func testActionTypeHashable() {
        var set = Set<ActionType>()
        set.insert(.searchReplace)
        set.insert(.insert)
        set.insert(.searchReplace) // Duplicate

        XCTAssertEqual(set.count, 2)
        XCTAssertTrue(set.contains(.searchReplace))
        XCTAssertTrue(set.contains(.insert))
    }

    // MARK: - ID Uniqueness

    func testAllActionTypesHaveUniqueIds() {
        let ids = ActionType.allCases.map { $0.id }
        let uniqueIds = Set(ids)

        XCTAssertEqual(ids.count, uniqueIds.count, "All ActionType IDs should be unique")
    }
}
