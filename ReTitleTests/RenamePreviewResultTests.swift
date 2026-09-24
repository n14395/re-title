// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import ReTitle

final class RenamePreviewResultTests: XCTestCase {
    
    // MARK: - Basic Initialization
    
    func testInitWithAllParameters() {
        let result = RenamePreviewResult(
            newName: "test.txt",
            changedRanges: [0..<4],
            deletedRanges: [0..<3]
        )
        
        XCTAssertEqual(result.newName, "test.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<4)
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 0..<3)
    }
    
    func testInitWithSingleRanges() {
        let result = RenamePreviewResult(
            newName: "new.txt",
            changedRange: 0..<3,
            deletedRange: 0..<3
        )
        
        XCTAssertEqual(result.newName, "new.txt")
        XCTAssertEqual(result.changedRanges, [0..<3])
        XCTAssertEqual(result.deletedRanges, [0..<3])
    }
    
    func testInitWithNilRanges() {
        let result = RenamePreviewResult(
            newName: "test.txt",
            changedRange: nil,
            deletedRange: nil
        )
        
        XCTAssertEqual(result.newName, "test.txt")
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testInitWithOnlyChangedRange() {
        let result = RenamePreviewResult(
            newName: "prefix_test.txt",
            changedRange: 0..<7,
            deletedRange: nil
        )
        
        XCTAssertEqual(result.changedRanges, [0..<7])
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testInitWithOnlyDeletedRange() {
        let result = RenamePreviewResult(
            newName: "test.txt",
            changedRange: nil,
            deletedRange: 0..<5
        )
        
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertEqual(result.deletedRanges, [0..<5])
    }
    
    // MARK: - Convenience Initializers
    
    func testUnchangedConvenience() {
        let result = RenamePreviewResult.unchanged("original.txt")
        
        XCTAssertEqual(result.newName, "original.txt")
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testReplacedConvenience() {
        let result = RenamePreviewResult.replaced(newName: "newname.txt", originalLength: 12)
        
        XCTAssertEqual(result.newName, "newname.txt")
        XCTAssertEqual(result.changedRanges, [0..<11]) // "newname.txt" = 11 chars
        XCTAssertEqual(result.deletedRanges, [0..<12])
    }
    
    func testReplacedConvenienceEmptyNewName() {
        let result = RenamePreviewResult.replaced(newName: "", originalLength: 8)
        
        XCTAssertEqual(result.newName, "")
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertEqual(result.deletedRanges, [0..<8])
    }
    
    func testReplacedConvenienceZeroOriginalLength() {
        let result = RenamePreviewResult.replaced(newName: "new.txt", originalLength: 0)
        
        XCTAssertEqual(result.newName, "new.txt")
        XCTAssertEqual(result.changedRanges, [0..<7])
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    // MARK: - Multiple Ranges
    
    func testMultipleChangedRanges() {
        let result = RenamePreviewResult(
            newName: "aXbXcX.txt",
            changedRanges: [1..<2, 3..<4, 5..<6],
            deletedRanges: []
        )
        
        XCTAssertEqual(result.changedRanges.count, 3)
        XCTAssertEqual(result.changedRanges[0], 1..<2)
        XCTAssertEqual(result.changedRanges[1], 3..<4)
        XCTAssertEqual(result.changedRanges[2], 5..<6)
    }
    
    func testMultipleDeletedRanges() {
        let result = RenamePreviewResult(
            newName: "bcdf.txt",
            changedRanges: [],
            deletedRanges: [0..<1, 2..<3, 4..<5]
        )
        
        XCTAssertEqual(result.deletedRanges.count, 3)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyNewName() {
        let result = RenamePreviewResult(
            newName: "",
            changedRanges: [],
            deletedRanges: [0..<10]
        )
        
        XCTAssertEqual(result.newName, "")
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertEqual(result.deletedRanges.count, 1)
    }
    
    func testUnicodeInNewName() {
        let result = RenamePreviewResult(
            newName: "日本語.txt",
            changedRanges: [0..<3],
            deletedRanges: []
        )
        
        XCTAssertEqual(result.newName, "日本語.txt")
        XCTAssertEqual(result.changedRanges, [0..<3])
    }
    
    func testEmojiInNewName() {
        let result = RenamePreviewResult(
            newName: "🎉party.txt",
            changedRanges: [0..<1],
            deletedRanges: []
        )
        
        XCTAssertEqual(result.newName, "🎉party.txt")
        XCTAssertEqual(result.changedRanges, [0..<1])
    }
}
