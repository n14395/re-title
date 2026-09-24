// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import ReTitle

final class NumberingActionTests: XCTestCase {

    // MARK: - Prefix Position Tests

    func testPrefixNumbering() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "1_file.txt")
    }

    func testPrefixNumberingSecondFile() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 1, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "2_file.txt")
    }

    // MARK: - Suffix Position Tests

    func testSuffixNumbering() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .suffix
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "file_1.txt")
    }

    func testSuffixNumberingMultiple() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .suffix
        action.padding = .none
        action.separator = "-"

        let results = (0..<3).map { action.apply(to: "file.txt", at: $0, totalCount: 3, applyToExtension: false) }
        XCTAssertEqual(results, ["file-1.txt", "file-2.txt", "file-3.txt"])
    }

    // MARK: - Replace Position Tests

    func testReplaceNumbering() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .replace
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "1.txt")
    }

    func testReplaceNumberingKeepsExtension() {
        var action = NumberingAction()
        action.startNumber = 100
        action.increment = 1
        action.position = .replace
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: "myfile.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "100.jpg")
    }

    // MARK: - Start Number Tests

    func testCustomStartNumber() {
        var action = NumberingAction()
        action.startNumber = 100
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "100_file.txt")
    }

    func testStartNumberWithIndex() {
        var action = NumberingAction()
        action.startNumber = 10
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 2, totalCount: 5, applyToExtension: false)
        XCTAssertEqual(result, "12_file.txt")
    }

    // MARK: - Increment Tests

    func testCustomIncrement() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 5
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let results = (0..<3).map { action.apply(to: "file.txt", at: $0, totalCount: 3, applyToExtension: false) }
        XCTAssertEqual(results, ["1_file.txt", "6_file.txt", "11_file.txt"])
    }

    func testIncrementByTen() {
        var action = NumberingAction()
        action.startNumber = 0
        action.increment = 10
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let results = (0..<3).map { action.apply(to: "file.txt", at: $0, totalCount: 3, applyToExtension: false) }
        XCTAssertEqual(results, ["0_file.txt", "10_file.txt", "20_file.txt"])
    }

    // MARK: - No Padding Tests

    func testNoPaddingSingleDigit() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 100, applyToExtension: false)
        XCTAssertEqual(result, "1_file.txt")
    }

    func testNoPaddingLargeNumber() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 99, totalCount: 100, applyToExtension: false)
        XCTAssertEqual(result, "100_file.txt")
    }

    // MARK: - Auto Padding Tests

    func testAutoPaddingSmallCount() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .auto
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 9, applyToExtension: false)
        XCTAssertEqual(result, "1_file.txt") // Max is 9, single digit
    }

    func testAutoPaddingDoubleDigit() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .auto
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 10, applyToExtension: false)
        XCTAssertEqual(result, "01_file.txt") // Max is 10, two digits
    }

    func testAutoPaddingTripleDigit() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .auto
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 100, applyToExtension: false)
        XCTAssertEqual(result, "001_file.txt") // Max is 100, three digits
    }

    func testAutoPaddingWithIncrement() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 10
        action.position = .prefix
        action.padding = .auto
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 10, applyToExtension: false)
        XCTAssertEqual(result, "01_file.txt") // Max is 1 + 9*10 = 91, two digits
    }

    // MARK: - Fixed Padding Tests

    func testFixedPaddingWidth3() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .fixed
        action.fixedWidth = 3
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 5, applyToExtension: false)
        XCTAssertEqual(result, "001_file.txt")
    }

    func testFixedPaddingWidth5() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .fixed
        action.fixedWidth = 5
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 5, applyToExtension: false)
        XCTAssertEqual(result, "00001_file.txt")
    }

    func testFixedPaddingExceedsWidth() {
        var action = NumberingAction()
        action.startNumber = 1000
        action.increment = 1
        action.position = .prefix
        action.padding = .fixed
        action.fixedWidth = 2
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "1000_file.txt") // Number exceeds width, no truncation
    }

    // MARK: - Separator Tests

    func testEmptySeparator() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = ""

        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "1file.txt")
    }

    func testDashSeparator() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "-"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "1-file.txt")
    }

    func testMultiCharSeparator() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .suffix
        action.padding = .none
        action.separator = " - "

        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "file - 1.txt")
    }

    // MARK: - No Extension Tests

    func testNoExtension() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: "myfile", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "1_myfile")
    }

    func testNoExtensionReplace() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .replace
        action.padding = .fixed
        action.fixedWidth = 3
        action.separator = "_"

        let result = action.apply(to: "myfile", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "001")
    }

    // MARK: - Batch Processing Simulation

    func testBatchProcessing() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .auto
        action.separator = "_"

        let files = ["a.txt", "b.txt", "c.txt", "d.txt", "e.txt"]
        let results = files.enumerated().map { action.apply(to: $0.element, at: $0.offset, totalCount: files.count, applyToExtension: false) }

        XCTAssertEqual(results, ["1_a.txt", "2_b.txt", "3_c.txt", "4_d.txt", "5_e.txt"])
    }

    // MARK: - At Position Tests

    func testAtPositionStart() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = 0
        action.padding = .none

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 5, applyToExtension: false)
        XCTAssertEqual(result, "1photo.jpg")
    }

    func testAtPositionMiddle() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = 3
        action.padding = .fixed
        action.fixedWidth = 2

        let result = action.apply(to: "myfile.txt", at: 0, totalCount: 10, applyToExtension: false)
        XCTAssertEqual(result, "myf01ile.txt")
    }

    func testAtPositionEnd() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = 5
        action.padding = .none

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 5, applyToExtension: false)
        XCTAssertEqual(result, "photo1.jpg")
    }

    func testAtPositionBeyondLength() {
        var action = NumberingAction()
        action.startNumber = 100
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = 999
        action.padding = .none

        let result = action.apply(to: "file.txt", at: 0, totalCount: 5, applyToExtension: false)
        XCTAssertEqual(result, "file100.txt")
    }

    func testAtPositionWithPrefixSeparator() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = 5
        action.padding = .fixed
        action.fixedWidth = 3
        action.prefixSeparator = "_"
        action.suffixSeparator = ""

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 10, applyToExtension: false)
        XCTAssertEqual(result, "photo_001.jpg")
    }

    func testAtPositionWithSuffixSeparator() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = 0
        action.padding = .fixed
        action.fixedWidth = 2
        action.prefixSeparator = ""
        action.suffixSeparator = "_"

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 10, applyToExtension: false)
        XCTAssertEqual(result, "01_photo.jpg")
    }

    func testAtPositionWithBothSeparators() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = 3
        action.padding = .fixed
        action.fixedWidth = 2
        action.prefixSeparator = "["
        action.suffixSeparator = "]"

        let result = action.apply(to: "myfile.txt", at: 0, totalCount: 10, applyToExtension: false)
        XCTAssertEqual(result, "myf[01]ile.txt")
    }

    func testAtPositionWithAutoPadding() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = 4
        action.padding = .auto
        action.prefixSeparator = "-"
        action.suffixSeparator = ""

        let result = action.apply(to: "file.txt", at: 0, totalCount: 100, applyToExtension: false)
        XCTAssertEqual(result, "file-001.txt")
    }

    func testAtPositionBatchProcessing() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = 4
        action.padding = .auto
        action.prefixSeparator = "_"
        action.suffixSeparator = ""

        let files = ["img1.jpg", "img2.jpg", "img3.jpg"]
        let results = files.enumerated().map { action.apply(to: $0.element, at: $0.offset, totalCount: files.count, applyToExtension: false) }

        XCTAssertEqual(results, ["img1_1.jpg", "img2_2.jpg", "img3_3.jpg"])
    }

    func testAtPositionNoExtension() {
        var action = NumberingAction()
        action.startNumber = 10
        action.increment = 5
        action.position = .atPosition
        action.insertPosition = 2
        action.padding = .none

        let result = action.apply(to: "abcd", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "ab10cd")
    }

    // MARK: - Additional Edge Cases

    func testNegativeStartNumber() {
        var action = NumberingAction()
        action.startNumber = -5
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let results = (0..<3).map { action.apply(to: "file.txt", at: $0, totalCount: 3, applyToExtension: false) }
        XCTAssertEqual(results, ["-5_file.txt", "-4_file.txt", "-3_file.txt"])
    }

    func testZeroIncrement() {
        var action = NumberingAction()
        action.startNumber = 5
        action.increment = 0
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        // Zero increment means all files get the same number
        let results = (0..<3).map { action.apply(to: "file.txt", at: $0, totalCount: 3, applyToExtension: false) }
        XCTAssertEqual(results, ["5_file.txt", "5_file.txt", "5_file.txt"])
    }

    func testNegativeIncrement() {
        var action = NumberingAction()
        action.startNumber = 10
        action.increment = -2
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let results = (0..<4).map { action.apply(to: "file.txt", at: $0, totalCount: 4, applyToExtension: false) }
        XCTAssertEqual(results, ["10_file.txt", "8_file.txt", "6_file.txt", "4_file.txt"])
    }

    func testNegativeInsertPosition() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = -10
        action.padding = .none

        // Negative position should clamp to 0
        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "1file.txt")
    }

    func testHiddenFile() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: ".gitignore", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "1_.gitignore")
    }

    func testHiddenFileReplace() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .replace
        action.padding = .fixed
        action.fixedWidth = 3

        // .gitignore has no extension, so the whole name is replaced
        let result = action.apply(to: ".gitignore", at: 0, totalCount: 10, applyToExtension: false)
        XCTAssertEqual(result, "001")
    }

    func testFixedWidthZero() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .fixed
        action.fixedWidth = 0
        action.separator = "_"

        // Zero width effectively means no padding
        let result = action.apply(to: "file.txt", at: 0, totalCount: 5, applyToExtension: false)
        XCTAssertEqual(result, "1_file.txt")
    }

    func testFixedWidthOne() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .fixed
        action.fixedWidth = 1
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 5, applyToExtension: false)
        XCTAssertEqual(result, "1_file.txt")
    }

    func testVeryLargeNumbers() {
        var action = NumberingAction()
        action.startNumber = 999999
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "999999_file.txt")
    }

    func testEmptyFilename() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        // .txt is treated as hidden file named ".txt"
        let result = action.apply(to: ".txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "1_.txt")
    }

    func testReplaceWithEmptyName() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .replace
        action.padding = .fixed
        action.fixedWidth = 3

        // .txt is treated as hidden file with name ".txt" and no extension
        // Replace replaces the entire name
        let result = action.apply(to: ".txt", at: 0, totalCount: 10, applyToExtension: false)
        XCTAssertEqual(result, "001")
    }

    func testAutoPaddingWithTotalCountZero() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .auto
        action.separator = "_"

        // Edge case: totalCount of 0
        let result = action.apply(to: "file.txt", at: 0, totalCount: 0, applyToExtension: false)
        XCTAssertEqual(result, "1_file.txt")
    }

    func testAtPositionWithNegativeStartAndPadding() {
        var action = NumberingAction()
        action.startNumber = -10
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = 4
        action.padding = .fixed
        action.fixedWidth = 4
        action.prefixSeparator = "_"
        action.suffixSeparator = ""

        // Padding with negative numbers
        let result = action.apply(to: "file.txt", at: 0, totalCount: 5, applyToExtension: false)
        XCTAssertEqual(result, "file_-010.txt")
    }

    func testUnicodeSeparator() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "→"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "1→file.txt")
    }

    func testEmojiInFilename() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = 5
        action.padding = .none

        let result = action.apply(to: "hello🌍.txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "hello1🌍.txt")
    }

    func testReplacePositionWithSeparatorIgnored() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .replace
        action.padding = .none
        action.separator = "_IGNORED_"

        // Separator should be ignored in replace mode
        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: false)
        XCTAssertEqual(result, "1.txt")
    }

    // MARK: - Enum Property Tests

    func testNumberPositionIdentifiable() {
        // Just verify they have non-empty ids (raw values)
        XCTAssertFalse(NumberPosition.prefix.id.isEmpty)
        XCTAssertFalse(NumberPosition.suffix.id.isEmpty)
        XCTAssertFalse(NumberPosition.replace.id.isEmpty)
        XCTAssertFalse(NumberPosition.atPosition.id.isEmpty)
    }

    func testNumberPaddingIdentifiable() {
        // Just verify they have non-empty ids
        XCTAssertFalse(NumberPadding.none.id.isEmpty)
        XCTAssertFalse(NumberPadding.auto.id.isEmpty)
        XCTAssertFalse(NumberPadding.fixed.id.isEmpty)
    }

    func testNumberPositionAllCases() {
        XCTAssertEqual(NumberPosition.allCases.count, 4)
    }

    func testNumberPaddingAllCases() {
        XCTAssertEqual(NumberPadding.allCases.count, 3)
    }

    // MARK: - Apply To Extension Tests

    func testPrefixNumberingApplyToExtension() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .prefix
        action.padding = .none
        action.separator = "_"

        // With applyToExtension=true, extension is treated as part of the name
        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: true)
        XCTAssertTrue(result.hasPrefix("1_"))
    }

    func testSuffixNumberingApplyToExtension() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .suffix
        action.padding = .none
        action.separator = "_"

        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: true)
        XCTAssertTrue(result.contains("_1"))
    }

    func testReplaceNumberingApplyToExtension() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .replace
        action.padding = .fixed
        action.fixedWidth = 3

        let result = action.apply(to: "file.txt", at: 0, totalCount: 10, applyToExtension: true)
        // In replace mode with applyToExtension, entire filename replaced
        XCTAssertEqual(result, "001")
    }

    func testAtPositionNumberingApplyToExtension() {
        var action = NumberingAction()
        action.startNumber = 1
        action.increment = 1
        action.position = .atPosition
        action.insertPosition = 4
        action.padding = .none

        let result = action.apply(to: "file.txt", at: 0, totalCount: 3, applyToExtension: true)
        // With applyToExtension=true, entire filename is treated as the name
        XCTAssertTrue(result.contains("1"))
    }
    
    // MARK: - Change Tracking Tests (applyWithTracking)
    
    func testTrackingPrefixNumbering() {
        var action = NumberingAction()
        action.position = .prefix
        action.startNumber = 1
        action.padding = .none
        action.separator = "_"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "1_file.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<2) // "1_"
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingSuffixNumbering() {
        var action = NumberingAction()
        action.position = .suffix
        action.startNumber = 1
        action.padding = .none
        action.separator = "_"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "file_1.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 4..<6) // "_1" at end of name
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingReplaceNumbering() {
        var action = NumberingAction()
        action.position = .replace
        action.startNumber = 1
        action.padding = .fixed
        action.fixedWidth = 3
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "001.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<3) // "001"
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 0..<4) // "file" deleted
    }
    
    func testTrackingAtPosition() {
        var action = NumberingAction()
        action.position = .atPosition
        action.insertPosition = 2
        action.startNumber = 5
        action.padding = .none
        action.prefixSeparator = "["
        action.suffixSeparator = "]"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "fi[5]le.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 2..<5) // "[5]"
    }
    
    func testTrackingWithAutoPadding() {
        var action = NumberingAction()
        action.position = .prefix
        action.startNumber = 1
        action.padding = .auto
        action.separator = "_"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 100, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "001_file.txt")
        XCTAssertEqual(result.changedRanges.first, 0..<4) // "001_"
    }
    
    func testTrackingWithIncrement() {
        var action = NumberingAction()
        action.position = .prefix
        action.startNumber = 10
        action.increment = 5
        action.padding = .none
        action.separator = "-"
        
        let result = action.applyWithTracking(to: "file.txt", at: 2, totalCount: 5, applyToExtension: false)
        
        // index 2: 10 + (2 * 5) = 20
        XCTAssertEqual(result.newName, "20-file.txt")
        XCTAssertEqual(result.changedRanges.first, 0..<3) // "20-"
    }
    
    func testTrackingNoExtension() {
        var action = NumberingAction()
        action.position = .suffix
        action.startNumber = 1
        action.padding = .none
        action.separator = "_"
        
        let result = action.applyWithTracking(to: "readme", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "readme_1")
        XCTAssertEqual(result.changedRanges.first, 6..<8)
    }
    
    func testTrackingApplyToExtension() {
        var action = NumberingAction()
        action.position = .suffix
        action.startNumber = 1
        action.padding = .none
        action.separator = "_"
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: true)
        
        XCTAssertEqual(result.newName, "file.txt_1")
        XCTAssertEqual(result.changedRanges.first, 8..<10) // "_1" at very end
    }
    
    func testTrackingEmptySeparator() {
        var action = NumberingAction()
        action.position = .prefix
        action.startNumber = 1
        action.padding = .none
        action.separator = ""
        
        let result = action.applyWithTracking(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "1file.txt")
        XCTAssertEqual(result.changedRanges.first, 0..<1) // Just "1"
    }
}
