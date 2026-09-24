// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import ReTitle

final class DateTimeActionTests: XCTestCase {

    // MARK: - Custom Text Prefix Tests

    func testCustomTextPrefix() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = "2024-01-15"
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2024-01-15_file.txt")
    }

    func testCustomTextPrefixEmptySeparator() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = "2024"
        action.separator = ""

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2024file.txt")
    }

    // MARK: - Custom Text Suffix Tests

    func testCustomTextSuffix() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .suffix
        action.customText = "v2"
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file_v2.txt")
    }

    func testCustomTextSuffixDashSeparator() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .suffix
        action.customText = "final"
        action.separator = "-"

        let result = action.apply(to: "document.pdf", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "document-final.pdf")
    }

    // MARK: - Current Date Tests

    func testCurrentDatePrefix() {
        var action = DateTimeAction()
        action.source = .currentDate
        action.position = .prefix
        action.format = "yyyy-MM-dd"
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)

        // Verify the format matches expected pattern
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let expectedDate = formatter.string(from: Date())

        XCTAssertEqual(result, "\(expectedDate)_file.txt")
    }

    func testCurrentDateSuffix() {
        var action = DateTimeAction()
        action.source = .currentDate
        action.position = .suffix
        action.format = "yyyyMMdd"
        action.separator = "_"

        let result = action.apply(to: "report.pdf", at: 0, totalCount: 1, applyToExtension: false)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let expectedDate = formatter.string(from: Date())

        XCTAssertEqual(result, "report_\(expectedDate).pdf")
    }

    func testCurrentDateCustomFormat() {
        var action = DateTimeAction()
        action.source = .currentDate
        action.position = .prefix
        action.format = "dd.MM.yyyy"
        action.separator = " - "

        let result = action.apply(to: "notes.txt", at: 0, totalCount: 1, applyToExtension: false)

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let expectedDate = formatter.string(from: Date())

        XCTAssertEqual(result, "\(expectedDate) - notes.txt")
    }

    func testCurrentDateTimeFormat() {
        var action = DateTimeAction()
        action.source = .currentDate
        action.position = .prefix
        action.format = "yyyy-MM-dd_HH-mm-ss"
        action.separator = "_"

        let result = action.apply(to: "backup.zip", at: 0, totalCount: 1, applyToExtension: false)

        // Just verify the result starts with expected year
        let year = Calendar.current.component(.year, from: Date())
        XCTAssertTrue(result.hasPrefix("\(year)"))
        XCTAssertTrue(result.hasSuffix(".zip"))
    }

    // MARK: - Separator Tests

    func testEmptySeparator() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = "PREFIX"
        action.separator = ""

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "PREFIXfile.txt")
    }

    func testSpaceSeparator() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = "[Draft]"
        action.separator = " "

        let result = action.apply(to: "document.docx", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "[Draft] document.docx")
    }

    func testMultiCharSeparator() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .suffix
        action.customText = "FINAL"
        action.separator = " - "

        let result = action.apply(to: "proposal.pdf", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "proposal - FINAL.pdf")
    }

    // MARK: - No Extension Tests

    func testNoExtensionPrefix() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = "2024"
        action.separator = "_"

        let result = action.apply(to: "myfile", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2024_myfile")
    }

    func testNoExtensionSuffix() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .suffix
        action.customText = "backup"
        action.separator = "_"

        let result = action.apply(to: "data", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "data_backup")
    }

    // MARK: - Empty Custom Text

    func testEmptyCustomText() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = ""
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "_file.txt") // Empty string still adds separator
    }

    // MARK: - Special Characters in Custom Text

    func testSpecialCharsInCustomText() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = "[2024-01]"
        action.separator = " "

        let result = action.apply(to: "invoice.pdf", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "[2024-01] invoice.pdf")
    }

    func testUnicodeCustomText() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = "日付"
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "日付_file.txt")
    }

    // MARK: - Multiple Dots in Filename

    func testMultipleDotsPrefix() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = "2024"
        action.separator = "_"

        let result = action.apply(to: "my.file.name.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2024_my.file.name.txt")
    }

    func testMultipleDotsSuffix() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .suffix
        action.customText = "v2"
        action.separator = "_"

        let result = action.apply(to: "my.file.name.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "my.file.name_v2.txt")
    }

    // MARK: - Index and TotalCount (should be ignored)

    func testIndexAndTotalCountIgnored() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = "2024"
        action.separator = "_"

        let result1 = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        let result2 = action.apply(to: "file.txt", at: 5, totalCount: 10, applyToExtension: false)

        XCTAssertEqual(result1, "2024_file.txt")
        XCTAssertEqual(result2, "2024_file.txt")
    }

    // MARK: - Date Format Edge Cases

    func testYearOnlyFormat() {
        var action = DateTimeAction()
        action.source = .currentDate
        action.position = .prefix
        action.format = "yyyy"
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)

        let year = Calendar.current.component(.year, from: Date())
        XCTAssertEqual(result, "\(year)_file.txt")
    }

    func testMonthDayFormat() {
        var action = DateTimeAction()
        action.source = .currentDate
        action.position = .suffix
        action.format = "MM-dd"
        action.separator = "_"

        let result = action.apply(to: "log.txt", at: 0, totalCount: 1, applyToExtension: false)

        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        let expected = formatter.string(from: Date())

        XCTAssertEqual(result, "log_\(expected).txt")
    }

    // MARK: - Replace Position Tests

    func testReplaceWithCurrentDate() {
        var action = DateTimeAction()
        action.source = .currentDate
        action.position = .replace
        action.format = "yyyy-MM-dd"

        let result = action.apply(to: "oldname.txt", at: 0, totalCount: 1, applyToExtension: false)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let expected = formatter.string(from: Date())

        XCTAssertEqual(result, "\(expected).txt")
    }

    func testReplaceWithCustomText() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .replace
        action.customText = "newname"

        let result = action.apply(to: "oldname.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "newname.txt")
    }

    func testReplaceNoExtension() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .replace
        action.customText = "replaced"

        let result = action.apply(to: "oldname", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "replaced")
    }

    // MARK: - At Position Tests

    func testAtPositionStart() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 0
        action.customText = "2024"

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2024photo.jpg")
    }

    func testAtPositionMiddle() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 3
        action.customText = "_v2_"

        let result = action.apply(to: "myfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "myf_v2_ile.txt")
    }

    func testAtPositionEnd() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 5
        action.customText = "_final"

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_final.jpg")
    }

    func testAtPositionBeyondLength() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 100
        action.customText = "_end"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file_end.txt")
    }

    func testAtPositionWithCurrentDate() {
        var action = DateTimeAction()
        action.source = .currentDate
        action.position = .atPosition
        action.insertPosition = 4
        action.format = "yyyy"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)

        let year = Calendar.current.component(.year, from: Date())
        XCTAssertEqual(result, "file\(year).txt")
    }

    func testAtPositionWithPrefixSeparator() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 5
        action.customText = "2024"
        action.prefixSeparator = "["
        action.suffixSeparator = ""

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo[2024.jpg")
    }

    func testAtPositionWithSuffixSeparator() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 0
        action.customText = "prefix"
        action.prefixSeparator = ""
        action.suffixSeparator = "_"

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "prefix_photo.jpg")
    }

    func testAtPositionWithBothSeparators() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 3
        action.customText = "2024"
        action.prefixSeparator = "("
        action.suffixSeparator = ")"

        let result = action.apply(to: "myfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "myf(2024)ile.txt")
    }

    func testAtPositionNoExtension() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 2
        action.customText = "XX"

        let result = action.apply(to: "abcd", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "abXXcd")
    }

    // MARK: - Additional Edge Cases

    func testNegativeInsertPosition() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = -5
        action.customText = "PRE"

        // Negative position should clamp to 0 (start)
        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "PREfile.txt")
    }

    func testEmptyFilenameWithExtension() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 0
        action.customText = "new"

        let result = action.apply(to: ".txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "new.txt")
    }

    func testReplaceWithEmptyCustomText() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .replace
        action.customText = ""

        // Replace with empty text - name becomes empty but extension preserved
        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".txt")
    }

    func testUnicodeSeparator() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = "arrow"
        action.separator = "→"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "arrow→file.txt")
    }

    func testUnicodePrefixSuffix() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 2
        action.customText = "中"
        action.prefixSeparator = "「"
        action.suffixSeparator = "」"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "fi「中」le.txt")
    }

    func testHiddenFile() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = "backup"
        action.separator = "_"

        let result = action.apply(to: ".gitignore", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "backup_.gitignore")
    }

    func testHiddenFileAtPosition() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 0
        action.customText = "test"

        // .gitignore is treated as name ".gitignore" with no extension
        let result = action.apply(to: ".gitignore", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "test.gitignore")
    }

    func testVeryLongCustomText() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = String(repeating: "a", count: 1000)
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result.count, 1000 + 1 + 4 + 4) // custom + _ + file + .txt
    }

    func testMultipleSeparatorCharacters() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 4
        action.customText = "V2"
        action.prefixSeparator = "[["
        action.suffixSeparator = "]]"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file[[V2]].txt")
    }

    func testEmptyFilenameNoExtension() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .replace
        action.customText = "newname"

        let result = action.apply(to: "", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "newname")
    }

    func testEmojiInCustomText() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .suffix
        action.customText = "🎉"
        action.separator = " "

        let result = action.apply(to: "party.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "party 🎉.txt")
    }

    func testAtPositionWithEmptyName() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 5
        action.customText = "test"

        // ".txt" is treated as hidden file with name ".txt" and no extension
        // Position 5 is beyond 4 chars, so text appended at end
        let result = action.apply(to: ".txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertTrue(result.contains("test"))
    }

    // MARK: - Enum Property Tests

    func testDateTimeSourceIdentifiable() {
        // Just verify they have non-empty ids
        XCTAssertFalse(DateTimeSource.currentDate.id.isEmpty)
        XCTAssertFalse(DateTimeSource.customText.id.isEmpty)
    }

    func testDateTimeSourceAllCases() {
        XCTAssertEqual(DateTimeSource.allCases.count, 2)
    }

    func testDateTimePositionIdentifiable() {
        // Just verify they have non-empty ids
        XCTAssertFalse(DateTimePosition.prefix.id.isEmpty)
        XCTAssertFalse(DateTimePosition.suffix.id.isEmpty)
        XCTAssertFalse(DateTimePosition.atPosition.id.isEmpty)
        XCTAssertFalse(DateTimePosition.replace.id.isEmpty)
    }

    func testDateTimePositionAllCases() {
        XCTAssertEqual(DateTimePosition.allCases.count, 4)
    }
    
    // MARK: - Change Tracking Tests (applyWithTracking)
    
    func testTrackingCustomTextPrefix() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = "2024"
        action.separator = "_"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "2024_file.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<5) // "2024_"
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingCustomTextSuffix() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .suffix
        action.customText = "v2"
        action.separator = "-"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "file-v2.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 4..<7) // "-v2"
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingReplace() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .replace
        action.customText = "newname"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "newname.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<7) // "newname"
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 0..<4) // "file" deleted
    }
    
    func testTrackingAtPosition() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .atPosition
        action.insertPosition = 2
        action.customText = "XX"
        action.prefixSeparator = "["
        action.suffixSeparator = "]"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "fi[XX]le.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 2..<6) // "[XX]"
    }
    
    func testTrackingCurrentDate() {
        var action = DateTimeAction()
        action.source = .currentDate
        action.position = .prefix
        action.format = "yyyy"
        action.separator = "_"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        // Date changes, but format is fixed length
        XCTAssertTrue(result.newName.hasSuffix("_file.txt"))
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<5) // "YYYY_" (4 + 1)
    }
    
    func testTrackingNoExtension() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .suffix
        action.customText = "_final"
        action.separator = ""
        
        let result = action.applyWithTracking(to: "readme", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "readme_final")
        XCTAssertEqual(result.changedRanges.first, 6..<12)
    }
    
    func testTrackingApplyToExtension() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .suffix
        action.customText = "_END"
        action.separator = ""
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: true)
        
        XCTAssertEqual(result.newName, "file.txt_END")
        XCTAssertEqual(result.changedRanges.first, 8..<12)
    }
    
    func testTrackingEmptyCustomText() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .prefix
        action.customText = ""
        action.separator = "_"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        // Empty custom text + separator
        XCTAssertEqual(result.newName, "_file.txt")
        XCTAssertEqual(result.changedRanges.first, 0..<1) // Just "_"
    }
    
    func testTrackingReplaceEmptyCustomText() {
        var action = DateTimeAction()
        action.source = .customText
        action.position = .replace
        action.customText = ""
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, ".txt")
        // Changed range is 0..<0 which is effectively empty
        XCTAssertTrue(result.changedRanges.isEmpty || result.changedRanges.first == 0..<0)
        XCTAssertEqual(result.deletedRanges.first, 0..<4) // "file" deleted
    }
}
