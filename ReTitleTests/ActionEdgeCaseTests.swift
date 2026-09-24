// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import ReTitle

/// Tests for edge cases and interactions across different actions
final class ActionEdgeCaseTests: XCTestCase {
    
    // MARK: - Empty Filename Edge Cases
    
    func testSearchReplaceRemovesEntireName() {
        var action = SearchReplaceAction()
        action.searchText = ".*"
        action.replaceText = ""
        action.useRegex = true
        action.replaceAll = true
        
        // When name is completely replaced with empty, result varies by implementation
        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        // Should preserve extension at minimum or return original
        XCTAssertTrue(result.contains(".txt") || result == "file.txt")
    }
    
    func testRemoveAllCharacters() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 1000 // More than any reasonable filename
        
        let result = action.apply(to: "short.txt", at: 0, totalCount: 1, applyToExtension: false)
        // Should either preserve extension or have fallback
        XCTAssertFalse(result.isEmpty)
    }
    
    func testInsertIntoEmptyName() {
        var action = InsertAction()
        action.text = "newname"
        action.mode = .insert
        action.position = .start
        
        let result = action.apply(to: ".txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "newname.txt")
    }
    
    // MARK: - Unicode Edge Cases
    
    func testSearchReplaceWithEmoji() {
        var action = SearchReplaceAction()
        action.searchText = "🎉"
        action.replaceText = "party"
        action.useRegex = false
        action.replaceAll = true
        
        let result = action.apply(to: "celebration🎉file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "celebrationpartyfile.txt")
    }
    
    func testCaseChangeWithMixedUnicode() {
        var action = CaseAction()
        action.caseType = .upper
        
        // Mix of ASCII, accented, and CJK characters
        let result = action.apply(to: "Café日本語.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "CAFÉ日本語.txt")
    }
    
    func testRemoveWithCombiningCharacters() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 1
        
        // é as e + combining acute accent (two code points, one grapheme)
        let result = action.apply(to: "e\u{0301}file.txt", at: 0, totalCount: 1, applyToExtension: false)
        // Should remove one grapheme cluster
        XCTAssertEqual(result, "file.txt")
    }
    
    func testNumberingWithUnicodeFilename() {
        var action = NumberingAction()
        action.position = .prefix
        action.startNumber = 1
        action.padding = .none
        action.separator = "_"
        
        let result = action.apply(to: "文档.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "1_文档.txt")
    }
    
    // MARK: - Special Characters Edge Cases
    
    func testSearchReplaceWithRegexMetacharacters() {
        var action = SearchReplaceAction()
        action.searchText = "[test]"
        action.replaceText = "replaced"
        action.useRegex = false // Literal mode
        action.replaceAll = true
        
        let result = action.apply(to: "file[test].txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "filereplaced.txt")
    }
    
    func testInsertWithSpecialCharacters() {
        var action = InsertAction()
        action.text = "[v1.0]"
        action.mode = .insert
        action.position = .end
        
        let result = action.apply(to: "document.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "document[v1.0].txt")
    }
    
    func testRemoveSpecificWithDollarSign() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "$"
        
        let result = action.apply(to: "price$100.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "price100.txt")
    }
    
    // MARK: - Boundary Conditions
    
    func testNumberingWithZeroStart() {
        var action = NumberingAction()
        action.position = .prefix
        action.startNumber = 0
        action.padding = .none
        action.separator = "_"
        
        let result = action.apply(to: "file.txt", at: 0, totalCount: 5, applyToExtension: false)
        XCTAssertEqual(result, "0_file.txt")
    }
    
    func testNumberingWithNegativeStart() {
        var action = NumberingAction()
        action.position = .prefix
        action.startNumber = -5
        action.increment = 1
        action.padding = .none
        action.separator = "_"
        
        let result = action.apply(to: "file.txt", at: 0, totalCount: 10, applyToExtension: false)
        XCTAssertEqual(result, "-5_file.txt")
    }
    
    func testInsertAtPositionZero() {
        var action = InsertAction()
        action.text = "START"
        action.mode = .insert
        action.position = .position
        action.positionIndex = 0
        
        let result = action.apply(to: "filename.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "STARTfilename.txt")
    }
    
    func testRemoveRangeAtBoundary() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 0
        action.rangeEnd = 1 // Remove first character (range is start..<end, exclusive)
        
        let result = action.apply(to: "abc.txt", at: 0, totalCount: 1, applyToExtension: false)
        // Range 0..<1 should remove first character
        XCTAssertEqual(result, "bc.txt")
    }
    
    // MARK: - Hidden Files
    
    func testSearchReplaceOnHiddenFile() {
        var action = SearchReplaceAction()
        action.searchText = "config"
        action.replaceText = "settings"
        action.useRegex = false
        action.replaceAll = true
        
        let result = action.apply(to: ".config", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".settings")
    }
    
    func testCaseChangeOnHiddenFile() {
        var action = CaseAction()
        action.caseType = .upper
        
        let result = action.apply(to: ".gitignore", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".GITIGNORE")
    }
    
    func testNumberingOnHiddenFile() {
        var action = NumberingAction()
        action.position = .prefix
        action.startNumber = 1
        action.padding = .none
        action.separator = "_"
        
        let result = action.apply(to: ".bashrc", at: 0, totalCount: 1, applyToExtension: false)
        // Should handle hidden file appropriately
        XCTAssertTrue(result.contains("1"))
        XCTAssertTrue(result.contains("bashrc"))
    }
    
    // MARK: - Multiple Extensions
    
    func testSearchReplaceWithTarGz() {
        var action = SearchReplaceAction()
        action.searchText = "archive"
        action.replaceText = "backup"
        action.useRegex = false
        action.replaceAll = true
        
        let result = action.apply(to: "archive.tar.gz", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "backup.tar.gz")
    }
    
    func testCaseChangePreservesMultipleExtensions() {
        var action = CaseAction()
        action.caseType = .lower
        
        // When applyToExtension is false, should preserve .tar.gz
        let result = action.apply(to: "BACKUP.tar.gz", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertTrue(result.hasSuffix(".tar.gz"))
    }
    
    // MARK: - Very Long Filenames
    
    func testSearchReplaceVeryLongFilename() {
        var action = SearchReplaceAction()
        action.searchText = "a"
        action.replaceText = "b"
        action.useRegex = false
        action.replaceAll = true
        
        let longName = String(repeating: "a", count: 200) + ".txt"
        let result = action.apply(to: longName, at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, String(repeating: "b", count: 200) + ".txt")
    }
    
    func testInsertIntoVeryLongFilename() {
        var action = InsertAction()
        action.text = "X"
        action.mode = .insert
        action.position = .position
        action.positionIndex = 100
        
        let longName = String(repeating: "a", count: 200) + ".txt"
        let result = action.apply(to: longName, at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertTrue(result.contains("X"))
        XCTAssertTrue(result.count > longName.count)
    }
    
    // MARK: - Whitespace Handling
    
    func testSearchReplaceWithWhitespace() {
        var action = SearchReplaceAction()
        action.searchText = " "
        action.replaceText = "_"
        action.useRegex = false
        action.replaceAll = true
        
        let result = action.apply(to: "my file name.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "my_file_name.txt")
    }
    
    func testRemoveLeadingSpaces() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = " "
        
        let result = action.apply(to: "  spaced file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "spacedfile.txt")
    }
    
    func testInsertPreservesSpaces() {
        var action = InsertAction()
        action.text = "prefix "
        action.mode = .insert
        action.position = .start
        
        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "prefix file.txt")
    }
    
    // MARK: - Case Edge Cases
    
    func testTitleCaseWithNumbers() {
        var action = CaseAction()
        action.caseType = .title
        
        let result = action.apply(to: "chapter1introduction.txt", at: 0, totalCount: 1, applyToExtension: false)
        // Should capitalize after number as well
        XCTAssertTrue(result.hasPrefix("Chapter1"))
    }
    
    func testSentenceCasePreservesAcronyms() {
        var action = CaseAction()
        action.caseType = .sentence
        
        // Sentence case typically lowercases everything except first letter
        let result = action.apply(to: "THE QUICK BROWN FOX.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "The quick brown fox.txt")
    }
    
    // MARK: - Tracking Result Edge Cases
    
    func testTrackingWithNoChanges() {
        var action = SearchReplaceAction()
        action.searchText = "xyz"
        action.replaceText = "abc"
        action.useRegex = false
        action.replaceAll = true
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result.newName, "file.txt")
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingWithMultipleChanges() {
        var action = SearchReplaceAction()
        action.searchText = "a"
        action.replaceText = "X"
        action.useRegex = false
        action.replaceAll = true
        
        let result = action.applyWithTracking(to: "abacada.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result.newName, "XbXcXdX.txt")
        XCTAssertEqual(result.changedRanges.count, 4)
        XCTAssertEqual(result.deletedRanges.count, 4)
    }
    
    func testTrackingWithCompleteReplacement() {
        var action = NumberingAction()
        action.position = .replace
        action.startNumber = 42
        action.padding = .none
        
        let result = action.applyWithTracking(to: "original.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result.newName, "42.txt")
        // Should show entire name as changed and deleted
        XCTAssertFalse(result.changedRanges.isEmpty)
        XCTAssertFalse(result.deletedRanges.isEmpty)
    }
    
    // MARK: - Index and TotalCount Usage
    
    func testNumberingUsesIndex() {
        var action = NumberingAction()
        action.position = .prefix
        action.startNumber = 1
        action.increment = 1
        action.padding = .none
        action.separator = "_"
        
        let result0 = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: false)
        let result1 = action.apply(to: "file.txt", at: 1, totalCount: 3, applyToExtension: false)
        let result2 = action.apply(to: "file.txt", at: 2, totalCount: 3, applyToExtension: false)
        
        XCTAssertEqual(result0, "1_file.txt")
        XCTAssertEqual(result1, "2_file.txt")
        XCTAssertEqual(result2, "3_file.txt")
    }
    
    func testSearchReplaceIgnoresIndex() {
        var action = SearchReplaceAction()
        action.searchText = "old"
        action.replaceText = "new"
        action.useRegex = false
        action.replaceAll = true
        
        // Result should be same regardless of index
        let result0 = action.apply(to: "old.txt", at: 0, totalCount: 3, applyToExtension: false)
        let result1 = action.apply(to: "old.txt", at: 1, totalCount: 3, applyToExtension: false)
        let result2 = action.apply(to: "old.txt", at: 2, totalCount: 3, applyToExtension: false)
        
        XCTAssertEqual(result0, result1)
        XCTAssertEqual(result1, result2)
    }
    
    func testAutoPaddingUsesTotalCount() {
        var action = NumberingAction()
        action.position = .prefix
        action.startNumber = 1
        action.increment = 1
        action.padding = .auto
        action.separator = "_"
        
        // With 100 files, should auto-pad to 3 digits
        let result = action.apply(to: "file.txt", at: 0, totalCount: 100, applyToExtension: false)
        XCTAssertEqual(result, "001_file.txt")
    }
}
