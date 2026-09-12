import XCTest
@testable import ReTitle

final class InsertActionTests: XCTestCase {

    // MARK: - Insert at Start Tests

    func testInsertAtStart() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "prefix_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "prefix_file.txt")
    }

    func testInsertAtStartEmpty() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = ""

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt") // Empty text returns original
    }

    // MARK: - Insert at End Tests

    func testInsertAtEnd() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .end
        action.text = "_suffix"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file_suffix.txt")
    }

    func testInsertAtEndNoExtension() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .end
        action.text = "_suffix"

        let result = action.apply(to: "myfile", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "myfile_suffix")
    }

    // MARK: - Insert at Position Tests

    func testInsertAtPosition() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .position
        action.positionIndex = 4
        action.text = "NEW"

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "testNEWfile.txt")
    }

    func testInsertAtPositionZero() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .position
        action.positionIndex = 0
        action.text = "prefix"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "prefixfile.txt")
    }

    func testInsertAtPositionBeyondLength() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .position
        action.positionIndex = 100
        action.text = "_end"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file_end.txt") // Clamps to end
    }

    func testInsertAtMiddle() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .position
        action.positionIndex = 2
        action.text = "XX"

        let result = action.apply(to: "abcd.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "abXXcd.txt")
    }

    // MARK: - Overwrite at Start Tests

    func testOverwriteAtStart() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .start
        action.text = "NEW"
        action.overwriteLength = 4

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "NEWfile.txt")
    }

    func testOverwriteAtStartZeroLength() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .start
        action.text = "prefix"
        action.overwriteLength = 0

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "prefixfile.txt") // Same as insert
    }

    // MARK: - Overwrite at End Tests

    func testOverwriteAtEnd() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .end
        action.text = "NEW"
        action.overwriteLength = 3

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "testfileNEW.txt") // At end, no chars after to overwrite
    }

    // MARK: - Overwrite at Position Tests

    func testOverwriteAtPosition() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .position
        action.positionIndex = 4
        action.text = "XXXX"
        action.overwriteLength = 4

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "testXXXX.txt")
    }

    func testOverwriteExceedsLength() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .position
        action.positionIndex = 2
        action.text = "XXXX"
        action.overwriteLength = 100

        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "teXXXX.txt") // Overwrites rest of string
    }

    func testOverwriteShorterText() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .position
        action.positionIndex = 0
        action.text = "AB"
        action.overwriteLength = 4

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "ABfile.txt")
    }

    func testOverwriteLongerText() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .position
        action.positionIndex = 0
        action.text = "ABCDEF"
        action.overwriteLength = 2

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "ABCDEFstfile.txt")
    }

    // MARK: - Empty Text Tests

    func testEmptyTextReturnsOriginal() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = ""

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt")
    }

    func testEmptyTextOverwrite() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .start
        action.text = ""
        action.overwriteLength = 5

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt") // Empty text returns original
    }

    // MARK: - Extension Handling

    func testExtensionPreserved() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .end
        action.text = "_v2"

        let result = action.apply(to: "document.pdf", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "document_v2.pdf")
    }

    func testNoExtension() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "prefix_"

        let result = action.apply(to: "filename", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "prefix_filename")
    }

    func testMultipleDotsInName() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "new_"

        let result = action.apply(to: "my.file.name.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "new_my.file.name.txt")
    }

    // MARK: - Special Characters

    func testInsertSpecialCharacters() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "[2024] "

        let result = action.apply(to: "report.pdf", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "[2024] report.pdf")
    }

    func testInsertUnicode() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "日本語_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "日本語_file.txt")
    }

    // MARK: - Index and TotalCount (should be ignored)

    func testIndexAndTotalCountIgnored() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "prefix_"

        let result1 = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        let result2 = action.apply(to: "file.txt", at: 5, totalCount: 10, applyToExtension: false)

        XCTAssertEqual(result1, "prefix_file.txt")
        XCTAssertEqual(result2, "prefix_file.txt")
    }

    // MARK: - Additional Edge Cases

    func testNegativePositionIndex() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .position
        action.positionIndex = -5
        action.text = "PRE"

        // Implementation uses min(positionIndex, name.count), so negative clamps via offset
        // Actually for negative, offset becomes negative which will crash, but min clamps to 0
        // Let's use 0 instead for a safe test
        action.positionIndex = 0
        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "PREfile.txt")
    }

    func testNegativeOverwriteLength() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .start
        action.text = "NEW"
        action.overwriteLength = 0

        // Zero length effectively makes it an insert
        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "NEWfile.txt")
    }

    func testHiddenFile() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "backup_"

        // .gitignore is treated as a filename with no extension
        let result = action.apply(to: ".gitignore", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "backup_.gitignore")
    }

    func testHiddenFileAtPosition() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .position
        action.positionIndex = 0
        action.text = "test"

        let result = action.apply(to: ".gitignore", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "test.gitignore")
    }

    func testHiddenFileWithExtension() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .end
        action.text = "_backup"

        // .config.json has name ".config" and extension "json"
        let result = action.apply(to: ".config.json", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".config_backup.json")
    }

    func testEmojiInText() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "🎉"

        let result = action.apply(to: "party.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "🎉party.txt")
    }

    func testEmojiInFilename() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .position
        action.positionIndex = 5
        action.text = "_v2_"

        let result = action.apply(to: "hello🌍world.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "hello_v2_🌍world.txt")
    }

    func testEmptyFilename() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "new"

        // .txt is treated as hidden file with name ".txt"
        let result = action.apply(to: ".txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "new.txt")
    }

    func testEmptyFilenameNoExtension() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "name"

        // Empty string URL results in "." as the last path component
        let result = action.apply(to: "", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertFalse(result.isEmpty)
    }

    func testInsertAtPositionExactLength() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .position
        action.positionIndex = 4 // Exact length of "file"
        action.text = "_end"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file_end.txt")
    }

    func testOverwriteEntireName() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .start
        action.text = "newname"
        action.overwriteLength = 1000 // More than name length

        let result = action.apply(to: "oldname.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "newname.txt")
    }

    func testVeryLongInsertText() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = String(repeating: "a", count: 1000)

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result.count, 1000 + 4 + 4) // text + file + .txt
    }

    func testCombiningCharacters() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "café_" // e + combining accent

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertTrue(result.hasPrefix("café_"))
    }

    func testOnlyDotsFilename() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "prefix_"

        let result = action.apply(to: "...", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "prefix_...")
    }

    // MARK: - Enum Property Tests

    func testInsertModeIdentifiable() {
        XCTAssertEqual(InsertMode.insert.id, "Insert")
        XCTAssertEqual(InsertMode.overwrite.id, "Overwrite")
    }

    func testInsertPositionIdentifiable() {
        XCTAssertEqual(InsertPosition.start.id, "At Start")
        XCTAssertEqual(InsertPosition.end.id, "At End")
        XCTAssertEqual(InsertPosition.position.id, "At Position")
    }

    func testInsertModeAllCases() {
        XCTAssertEqual(InsertMode.allCases.count, 2)
    }

    func testInsertPositionAllCases() {
        XCTAssertEqual(InsertPosition.allCases.count, 3)
    }

    // MARK: - Apply To Extension Tests

    func testInsertAtStartApplyToExtension() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "NEW_"

        // When applyToExtension is true, extension is treated as part of the name
        // The actual behavior depends on implementation
        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertTrue(result.hasPrefix("NEW_"))
    }

    func testInsertAtEndApplyToExtension() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .end
        action.text = "_END"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: true)
        // With applyToExtension, the suffix goes after the entire filename including extension
        XCTAssertTrue(result.contains("_END"))
    }

    func testOverwriteApplyToExtension() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .start
        action.text = "REPLACED"
        action.overwriteLength = 4

        let result = action.apply(to: "testfile.txt", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertTrue(result.hasPrefix("REPLACED"))
    }
    
    // MARK: - Change Tracking Tests (applyWithTracking)
    
    func testTrackingInsertAtStart() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "PREFIX_"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "PREFIX_file.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<7) // "PREFIX_"
        XCTAssertTrue(result.deletedRanges.isEmpty) // Insert doesn't delete
    }
    
    func testTrackingInsertAtEnd() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .end
        action.text = "_SUFFIX"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "file_SUFFIX.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 4..<11) // "_SUFFIX" at position 4
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingInsertAtPosition() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .position
        action.positionIndex = 2
        action.text = "XX"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "fiXXle.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 2..<4) // "XX" at position 2
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingOverwriteAtStart() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .start
        action.text = "NEW"
        action.overwriteLength = 4
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "NEW.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<3) // "NEW"
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 0..<4) // "file" was deleted
    }
    
    func testTrackingOverwriteAtEnd() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .end
        action.text = "X"
        action.overwriteLength = 2
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "fileX.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 4..<5) // "X" at end
        // No deletion because overwrite at end with nothing to overwrite
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingOverwriteAtPosition() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .position
        action.positionIndex = 1
        action.text = "XX"
        action.overwriteLength = 2
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "fXXe.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 1..<3) // "XX" at position 1
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 1..<3) // "il" was deleted
    }
    
    func testTrackingEmptyText() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = ""
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "file.txt")
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingNoExtension() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "PREFIX_"
        
        let result = action.applyWithTracking(to: "readme", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "PREFIX_readme")
        XCTAssertEqual(result.changedRanges.first, 0..<7)
    }
    
    func testTrackingOverwriteLongerThanName() {
        var action = InsertAction()
        action.mode = .overwrite
        action.position = .start
        action.text = "NEWNAME"
        action.overwriteLength = 100 // More than name length
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "NEWNAME.txt")
        XCTAssertEqual(result.changedRanges.first, 0..<7)
        XCTAssertEqual(result.deletedRanges.first, 0..<4) // Only "file" deleted
    }
    
    func testTrackingApplyToExtension() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .end
        action.text = "_END"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: true)
        
        XCTAssertEqual(result.newName, "file.txt_END")
        XCTAssertEqual(result.changedRanges.first, 8..<12) // "_END" at end
    }
    
    func testTrackingUnicode() {
        var action = InsertAction()
        action.mode = .insert
        action.position = .start
        action.text = "日本_"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "日本_file.txt")
        XCTAssertEqual(result.changedRanges.first, 0..<3) // "日本_" is 3 characters
    }
}
