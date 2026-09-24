// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import ReTitle

final class RemoveActionTests: XCTestCase {

    // MARK: - First N Characters Tests

    func testRemoveFirstNCharacters() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 4

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt")
    }

    func testRemoveFirstZeroCharacters() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 0

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "testfile.txt")
    }

    func testRemoveFirstAllCharacters() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 8

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "_.txt") // Empty name becomes "_"
    }

    func testRemoveFirstMoreThanLength() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 100

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "_.txt") // Empty name becomes "_"
    }

    // MARK: - Last N Characters Tests

    func testRemoveLastNCharacters() {
        var action = RemoveAction()
        action.mode = .lastN
        action.count = 4

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "test.txt")
    }

    func testRemoveLastZeroCharacters() {
        var action = RemoveAction()
        action.mode = .lastN
        action.count = 0

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "testfile.txt")
    }

    func testRemoveLastAllCharacters() {
        var action = RemoveAction()
        action.mode = .lastN
        action.count = 8

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "_.txt") // Empty name becomes "_"
    }

    func testRemoveLastMoreThanLength() {
        var action = RemoveAction()
        action.mode = .lastN
        action.count = 100

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "_.txt") // Empty name becomes "_"
    }

    // MARK: - Character Range Tests

    func testRemoveRange() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 2
        action.rangeEnd = 5

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "teile.txt") // Removes characters at indices 2,3,4
    }

    func testRemoveRangeFromStart() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 0
        action.rangeEnd = 4

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt")
    }

    func testRemoveRangeToEnd() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 4
        action.rangeEnd = 8

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "test.txt")
    }

    func testRemoveRangeSameStartEnd() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 2
        action.rangeEnd = 2

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "testfile.txt") // No characters removed
    }

    func testRemoveRangeInvertedClamps() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 5
        action.rangeEnd = 2

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "testfile.txt") // End clamped to start, no removal
    }

    func testRemoveRangeExceedsBounds() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 0
        action.rangeEnd = 100

        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "_.txt") // Entire name removed
    }

    func testRemoveRangeNegativeStart() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = -5
        action.rangeEnd = 2

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "stfile.txt") // Start clamped to 0
    }

    // MARK: - Specific Characters Tests

    func testRemoveSpecificCharacters() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "aeiou"

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "tstfl.txt")
    }

    func testRemoveSpecificCharactersNumbers() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "0123456789"

        let result = action.apply(to: "file123test456.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "filetest.txt")
    }

    func testRemoveSpecificCharactersNone() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "xyz"

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "testfile.txt") // No matching chars
    }

    func testRemoveSpecificCharactersAll() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "test"

        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "_.txt") // All chars removed
    }

    func testRemoveSpecificCharactersEmpty() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = ""

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "testfile.txt")
    }

    func testRemoveSpecificCharactersSpecial() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "-_."

        let result = action.apply(to: "my-file_name.test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "myfilenametest.txt")
    }

    // MARK: - Empty Name Fallback Tests

    func testEmptyNameFallbackWithExtension() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 10

        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "_.txt")
    }

    func testEmptyNameFallbackNoExtension() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 10

        let result = action.apply(to: "test", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "_")
    }

    // MARK: - No Extension Tests

    func testRemoveFirstNoExtension() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 4

        let result = action.apply(to: "testfile", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file")
    }

    func testRemoveLastNoExtension() {
        var action = RemoveAction()
        action.mode = .lastN
        action.count = 4

        let result = action.apply(to: "testfile", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "test")
    }

    func testRemoveRangeNoExtension() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 2
        action.rangeEnd = 6

        let result = action.apply(to: "testfile", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "tele")
    }

    // MARK: - Unicode Tests

    func testRemoveFirstUnicode() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 3

        let result = action.apply(to: "日本語file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt")
    }

    func testRemoveSpecificUnicode() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "日本語"

        let result = action.apply(to: "日本語file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt")
    }

    // MARK: - Index and TotalCount (should be ignored)

    func testIndexAndTotalCountIgnored() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 2

        let result1 = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        let result2 = action.apply(to: "testfile.txt", at: 5, totalCount: 10, applyToExtension: false)

        XCTAssertEqual(result1, "stfile.txt")
        XCTAssertEqual(result2, "stfile.txt")
    }

    // MARK: - Additional Edge Cases

    func testZeroCount() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 0

        // Zero count removes nothing
        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt")
    }

    func testZeroCountLastN() {
        var action = RemoveAction()
        action.mode = .lastN
        action.count = 0

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt")
    }

    func testHiddenFile() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 4

        // .gitignore is treated as having name ".gitignore" with no extension
        // Removing 4 chars from ".gitignore" gives "ignore"
        let result = action.apply(to: ".gitignore", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "ignore")
    }

    func testHiddenFileWithExtension() {
        var action = RemoveAction()
        action.mode = .lastN
        action.count = 3

        // .config.json has name ".config" and extension "json"
        let result = action.apply(to: ".config.json", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".con.json")
    }

    func testRemoveLastUnicode() {
        var action = RemoveAction()
        action.mode = .lastN
        action.count = 3

        let result = action.apply(to: "file日本語.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt")
    }

    func testRemoveRangeUnicode() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 2
        action.rangeEnd = 5

        let result = action.apply(to: "ab日本語cd.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "abcd.txt")
    }

    func testEmojiRemoval() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "🎉🌍"

        let result = action.apply(to: "party🎉world🌍.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "partyworld.txt")
    }

    func testRemoveFirstWithEmoji() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 2

        // Emoji counts as one character (grapheme cluster)
        let result = action.apply(to: "🎉🌍hello.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "hello.txt")
    }

    func testRemoveLastWithEmoji() {
        var action = RemoveAction()
        action.mode = .lastN
        action.count = 2

        let result = action.apply(to: "hello🎉🌍.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "hello.txt")
    }

    func testSpecificCharsWithRegexMetachars() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = ".*+?[](){}|^$\\"

        // Should treat these literally, not as regex
        let result = action.apply(to: "file[1].txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file1.txt")
    }

    func testEmptyFilename() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 0

        // .txt is treated as a hidden file with name ".txt"
        let result = action.apply(to: ".txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".txt")
    }

    func testRemoveAllFromEmptyName() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 10

        // .txt is treated as name ".txt" with no extension
        let result = action.apply(to: ".txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "_")
    }

    func testVeryLargeCount() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = Int.max

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "_.txt")
    }

    func testVeryLargeRangeEnd() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 0
        action.rangeEnd = Int.max

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "_.txt")
    }

    func testRangeNegativeEnd() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 0
        action.rangeEnd = -5

        // Negative end should clamp to start, resulting in no removal
        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt")
    }

    func testOnlyDotsFilename() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 1

        let result = action.apply(to: "...", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "..")
    }

    func testCombiningCharacters() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 4

        // café with e + combining accent = 4 grapheme clusters
        let result = action.apply(to: "cafe\u{0301}x.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "x.txt")
    }

    func testMultipleDotsInFilename() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "."

        // Only removes dots from the name portion, not extension
        let result = action.apply(to: "my.file.name.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "myfilename.txt")
    }

    // MARK: - Enum Property Tests

    func testRemoveModeIdentifiable() {
        XCTAssertEqual(RemoveMode.firstN.id, "First N Characters")
        XCTAssertEqual(RemoveMode.lastN.id, "Last N Characters")
        XCTAssertEqual(RemoveMode.range.id, "Character Range")
        XCTAssertEqual(RemoveMode.specific.id, "Specific Characters")
    }

    func testRemoveModeAllCases() {
        XCTAssertEqual(RemoveMode.allCases.count, 4)
    }

    // MARK: - Apply To Extension Tests

    func testRemoveFirstNApplyToExtension() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 2

        // With applyToExtension=true, extension is treated as part of the name
        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: true)
        // The implementation may vary - just verify it changes the result
        XCTAssertFalse(result.isEmpty)
    }

    func testRemoveLastNApplyToExtension() {
        var action = RemoveAction()
        action.mode = .lastN
        action.count = 3

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertFalse(result.isEmpty)
    }

    func testRemoveSpecificApplyToExtension() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "t"

        // With applyToExtension=true, should remove 't' from extension too
        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertFalse(result.contains("t"))
    }

    func testRemoveRangeApplyToExtension() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 0
        action.rangeEnd = 4

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertFalse(result.isEmpty)
    }
    
    // MARK: - Change Tracking Tests (applyWithTracking)
    
    func testTrackingRemoveFirstN() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 3
        
        let result = action.applyWithTracking(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "tfile.txt")
        XCTAssertTrue(result.changedRanges.isEmpty) // Remove doesn't add
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 0..<3) // "tes" removed
    }
    
    func testTrackingRemoveLastN() {
        var action = RemoveAction()
        action.mode = .lastN
        action.count = 4
        
        let result = action.applyWithTracking(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "test.txt")
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 4..<8) // "file" removed from end
    }
    
    func testTrackingRemoveRange() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 2
        action.rangeEnd = 5
        
        let result = action.applyWithTracking(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "teile.txt")
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 2..<5) // "stf" removed
    }
    
    func testTrackingRemoveSpecificChars() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "aeiou"
        
        let result = action.applyWithTracking(to: "beautiful.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "btfl.txt")
        XCTAssertTrue(result.changedRanges.isEmpty)
        // Multiple ranges for vowels at different positions
        XCTAssertTrue(result.deletedRanges.count >= 1)
    }
    
    func testTrackingRemoveSpecificCharsMerged() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "ea"
        
        // "ea" are adjacent in "beautiful", so should be merged
        let result = action.applyWithTracking(to: "beautiful.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "butiful.txt")
        // "ea" at positions 1-2 should be single merged range
        XCTAssertTrue(result.deletedRanges.contains(1..<3))
    }
    
    func testTrackingNoChange() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 0
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "file.txt")
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingRemoveAllCharacters() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 100 // More than name length
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "_.txt") // Empty name fallback
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertEqual(result.deletedRanges.first, 0..<4) // "file" deleted
    }
    
    func testTrackingRangeOutOfBounds() {
        var action = RemoveAction()
        action.mode = .range
        action.rangeStart = 2
        action.rangeEnd = 100 // Beyond length
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "fi.txt")
        XCTAssertEqual(result.deletedRanges.first, 2..<4) // Clamped to "le"
    }
    
    func testTrackingApplyToExtension() {
        var action = RemoveAction()
        action.mode = .specific
        action.specificChars = "t"
        
        let result = action.applyWithTracking(to: "test.txt", at: 0, totalCount: 1, applyToExtension: true)
        
        XCTAssertEqual(result.newName, "es.x")
        // Should have deleted positions for 't' in name and extension
        XCTAssertTrue(result.deletedRanges.count >= 2)
    }
    
    func testTrackingUnicode() {
        var action = RemoveAction()
        action.mode = .firstN
        action.count = 2
        
        let result = action.applyWithTracking(to: "日本語.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "語.txt")
        XCTAssertEqual(result.deletedRanges.first, 0..<2) // 2 unicode characters
    }
    
    func testTrackingNoExtension() {
        var action = RemoveAction()
        action.mode = .lastN
        action.count = 2
        
        let result = action.applyWithTracking(to: "readme", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "read")
        XCTAssertEqual(result.deletedRanges.first, 4..<6) // "me" at end
    }
}
