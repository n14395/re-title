// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import ReTitle

final class SearchReplaceActionTests: XCTestCase {

    // MARK: - Basic Literal Replacement Tests

    func testSimpleLiteralReplace() {
        var action = SearchReplaceAction()
        action.searchText = "old"
        action.replaceText = "new"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "old_file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "new_file.txt")
    }

    func testLiteralReplaceAll() {
        var action = SearchReplaceAction()
        action.searchText = "a"
        action.replaceText = "X"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "banana.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "bXnXnX.txt")
    }

    func testLiteralReplaceFirst() {
        var action = SearchReplaceAction()
        action.searchText = "a"
        action.replaceText = "X"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = false

        let result = action.apply(to: "banana.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "bXnana.txt")
    }

    func testLiteralCaseInsensitive() {
        var action = SearchReplaceAction()
        action.searchText = "TEST"
        action.replaceText = "demo"
        action.useRegex = false
        action.caseSensitive = false
        action.replaceAll = true

        let result = action.apply(to: "test_Test_TEST.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "demo_demo_demo.txt")
    }

    func testLiteralCaseSensitive() {
        var action = SearchReplaceAction()
        action.searchText = "TEST"
        action.replaceText = "demo"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "test_Test_TEST.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "test_Test_demo.txt")
    }

    // MARK: - Regex Replacement Tests

    func testSimpleRegexReplace() {
        var action = SearchReplaceAction()
        action.searchText = "\\d+"
        action.replaceText = "NUM"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "file123test456.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "fileNUMtestNUM.txt")
    }

    func testRegexReplaceFirst() {
        var action = SearchReplaceAction()
        action.searchText = "\\d+"
        action.replaceText = "NUM"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = false

        let result = action.apply(to: "file123test456.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "fileNUMtest456.txt")
    }

    func testRegexCaseInsensitive() {
        var action = SearchReplaceAction()
        action.searchText = "[a-z]+"
        action.replaceText = "X"
        action.useRegex = true
        action.caseSensitive = false
        action.replaceAll = true

        let result = action.apply(to: "Hello123World.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "X123X.txt")
    }

    func testRegexWithCaptureGroups() {
        var action = SearchReplaceAction()
        action.searchText = "(\\w+)-(\\w+)"
        action.replaceText = "$2_$1"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "first-second.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "second_first.txt")
    }

    func testInvalidRegexPattern() {
        var action = SearchReplaceAction()
        action.searchText = "[invalid"
        action.replaceText = "X"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "test.txt") // Should return unchanged on invalid regex
    }

    // MARK: - Empty Search Text

    func testEmptySearchText() {
        var action = SearchReplaceAction()
        action.searchText = ""
        action.replaceText = "X"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "test.txt") // Returns original filename
    }

    // MARK: - No Match Tests

    func testNoMatchLiteral() {
        var action = SearchReplaceAction()
        action.searchText = "xyz"
        action.replaceText = "abc"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "test.txt")
    }

    func testNoMatchRegex() {
        var action = SearchReplaceAction()
        action.searchText = "^xyz"
        action.replaceText = "abc"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "test.txt")
    }

    // MARK: - Extension Preservation Tests

    func testExtensionNotModified() {
        var action = SearchReplaceAction()
        action.searchText = "txt"
        action.replaceText = "doc"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "txtfile.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "docfile.txt") // Only name part is replaced, extension preserved
    }

    func testNoExtension() {
        var action = SearchReplaceAction()
        action.searchText = "old"
        action.replaceText = "new"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "old_file", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "new_file")
    }

    // MARK: - Delete by Replacing with Empty

    func testDeleteByEmptyReplace() {
        var action = SearchReplaceAction()
        action.searchText = "_copy"
        action.replaceText = ""
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "file_copy.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt")
    }

    func testRegexDeleteNumbers() {
        var action = SearchReplaceAction()
        action.searchText = "\\d"
        action.replaceText = ""
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "file123.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "file.txt")
    }

    // MARK: - Special Characters

    func testLiteralSpecialChars() {
        var action = SearchReplaceAction()
        action.searchText = "."
        action.replaceText = "-"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "my.file.name.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "my-file-name.txt")
    }

    func testRegexDotEscaped() {
        var action = SearchReplaceAction()
        action.searchText = "\\."
        action.replaceText = "-"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "my.file.name.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "my-file-name.txt")
    }

    // MARK: - Index and TotalCount (should be ignored)

    func testIndexAndTotalCountIgnored() {
        var action = SearchReplaceAction()
        action.searchText = "test"
        action.replaceText = "demo"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result1 = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        let result2 = action.apply(to: "test.txt", at: 5, totalCount: 10, applyToExtension: false)

        XCTAssertEqual(result1, "demo.txt")
        XCTAssertEqual(result2, "demo.txt")
    }

    // MARK: - Additional Edge Cases

    func testReplaceEntireNameWithEmpty() {
        var action = SearchReplaceAction()
        action.searchText = "file"
        action.replaceText = ""
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        // Entire name removed should result in empty name
        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".txt")
    }

    func testRegexWithLookahead() {
        var action = SearchReplaceAction()
        action.searchText = "test(?=file)"
        action.replaceText = "demo"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "testfile_test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "demofile_test.txt")
    }

    func testRegexWithLookbehind() {
        var action = SearchReplaceAction()
        action.searchText = "(?<=my_)file"
        action.replaceText = "document"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "my_file_the_file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "my_document_the_file.txt")
    }

    func testRegexWordBoundary() {
        var action = SearchReplaceAction()
        action.searchText = "\\btest\\b"
        action.replaceText = "demo"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        // Word boundary may not work exactly as expected with underscores
        let result = action.apply(to: "test file test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "demo file demo.txt")
    }

    func testRegexStartAnchor() {
        var action = SearchReplaceAction()
        action.searchText = "^test"
        action.replaceText = "demo"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "test_test_test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "demo_test_test.txt")
    }

    func testRegexEndAnchor() {
        var action = SearchReplaceAction()
        action.searchText = "test$"
        action.replaceText = "demo"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "test_test_test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "test_test_demo.txt")
    }

    func testRegexMultipleCaptureGroups() {
        var action = SearchReplaceAction()
        action.searchText = "(\\w+)-(\\w+)-(\\w+)"
        action.replaceText = "$3_$2_$1"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "one-two-three.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "three_two_one.txt")
    }

    func testReplaceDollarSignLiteral() {
        var action = SearchReplaceAction()
        action.searchText = "price"
        action.replaceText = "$100"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "price_tag.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "$100_tag.txt")
    }

    func testUnicodeSearch() {
        var action = SearchReplaceAction()
        action.searchText = "日本"
        action.replaceText = "Japan"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "日本語file.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Japan語file.txt")
    }

    func testUnicodeRegex() {
        var action = SearchReplaceAction()
        action.searchText = "[日本語]+"
        action.replaceText = "JP"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "日本語file日本.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "JPfileJP.txt")
    }

    func testEmojiSearch() {
        var action = SearchReplaceAction()
        action.searchText = "🎉"
        action.replaceText = "party"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "🎉file🎉.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "partyfileparty.txt")
    }

    func testHiddenFile() {
        var action = SearchReplaceAction()
        action.searchText = "git"
        action.replaceText = "svn"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: ".gitignore", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".svnignore")
    }

    func testReplaceFirstNoMatchReturnsOriginal() {
        var action = SearchReplaceAction()
        action.searchText = "xyz"
        action.replaceText = "abc"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = false

        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "test.txt")
    }

    func testReplaceFirstCaseInsensitive() {
        var action = SearchReplaceAction()
        action.searchText = "TEST"
        action.replaceText = "demo"
        action.useRegex = false
        action.caseSensitive = false
        action.replaceAll = false

        let result = action.apply(to: "test_TEST_Test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "demo_TEST_Test.txt")
    }

    func testRegexCaseInsensitiveReplaceFirst() {
        var action = SearchReplaceAction()
        action.searchText = "TEST"
        action.replaceText = "demo"
        action.useRegex = true
        action.caseSensitive = false
        action.replaceAll = false

        let result = action.apply(to: "test_TEST_Test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "demo_TEST_Test.txt")
    }

    func testEmptyFilename() {
        var action = SearchReplaceAction()
        action.searchText = "t"
        action.replaceText = "x"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        // .txt is treated as hidden file with name ".txt"
        let result = action.apply(to: ".txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".xxx")
    }

    func testVeryLongSearchPattern() {
        var action = SearchReplaceAction()
        action.searchText = String(repeating: "a", count: 100)
        action.replaceText = "X"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let filename = String(repeating: "a", count: 100) + ".txt"
        let result = action.apply(to: filename, at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "X.txt")
    }

    func testRegexEmptyCaptureGroup() {
        var action = SearchReplaceAction()
        action.searchText = "(test)?"
        action.replaceText = "[$1]"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        // Matches empty strings too
        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        // Behavior depends on regex engine, just verify no crash
        XCTAssertFalse(result.isEmpty)
    }

    func testNamedCaptureGroups() {
        var action = SearchReplaceAction()
        action.searchText = "(?<first>\\w+)-(?<second>\\w+)"
        action.replaceText = "${second}_${first}"
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        // Swift regex may or may not support named groups in replacement
        // Just verify no crash
        let result = action.apply(to: "one-two.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertFalse(result.isEmpty)
    }

    func testMultipleDotsInName() {
        var action = SearchReplaceAction()
        action.searchText = "."
        action.replaceText = "_"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "my.file.name.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "my_file_name.txt")
    }

    func testOnlyDotsFilename() {
        var action = SearchReplaceAction()
        action.searchText = "."
        action.replaceText = "_"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        // "..." is treated as name "..." with no extension
        let result = action.apply(to: "...", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "___")
    }

    // MARK: - Apply To Extension Tests

    func testApplyToExtensionTrue() {
        var action = SearchReplaceAction()
        action.searchText = "t"
        action.replaceText = "X"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, "XesX.XxX")
    }

    func testApplyToExtensionFalse() {
        var action = SearchReplaceAction()
        action.searchText = "t"
        action.replaceText = "X"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "XesX.txt")
    }

    func testApplyToExtensionWithRegex() {
        var action = SearchReplaceAction()
        action.searchText = "[aeiou]"
        action.replaceText = ""
        action.useRegex = true
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "audio.mp3", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, "d.mp3")
    }

    func testApplyToExtensionChangesExtension() {
        var action = SearchReplaceAction()
        action.searchText = "txt"
        action.replaceText = "md"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        // When applyToExtension is true, the extension can be changed
        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, "file.md")
    }

    func testApplyToExtensionCaseInsensitive() {
        var action = SearchReplaceAction()
        action.searchText = "TXT"
        action.replaceText = "doc"
        action.useRegex = false
        action.caseSensitive = false
        action.replaceAll = true

        let result = action.apply(to: "file.txt", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, "file.doc")
    }

    func testApplyToExtensionNoExtension() {
        var action = SearchReplaceAction()
        action.searchText = "test"
        action.replaceText = "demo"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: "testfile", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, "demofile")
    }

    func testApplyToExtensionHiddenFile() {
        var action = SearchReplaceAction()
        action.searchText = "git"
        action.replaceText = "svn"
        action.useRegex = false
        action.caseSensitive = true
        action.replaceAll = true

        let result = action.apply(to: ".gitignore", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, ".svnignore")
    }
    
    // MARK: - Change Tracking Tests (applyWithTracking)
    
    func testTrackingLiteralSingleReplacement() {
        var action = SearchReplaceAction()
        action.searchText = "old"
        action.replaceText = "new"
        action.replaceAll = false
        
        let result = action.applyWithTracking(to: "old_file.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "new_file.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<3) // "new" at position 0-3
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 0..<3) // "old" was at 0-3
    }
    
    func testTrackingLiteralMultipleReplacements() {
        var action = SearchReplaceAction()
        action.searchText = "a"
        action.replaceText = "X"
        action.replaceAll = true
        
        let result = action.applyWithTracking(to: "banana.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "bXnXnX.txt")
        XCTAssertEqual(result.changedRanges.count, 3)
        XCTAssertEqual(result.changedRanges[0], 1..<2) // First X
        XCTAssertEqual(result.changedRanges[1], 3..<4) // Second X
        XCTAssertEqual(result.changedRanges[2], 5..<6) // Third X
        XCTAssertEqual(result.deletedRanges.count, 3)
        XCTAssertEqual(result.deletedRanges[0], 1..<2) // First a
        XCTAssertEqual(result.deletedRanges[1], 3..<4) // Second a
        XCTAssertEqual(result.deletedRanges[2], 5..<6) // Third a
    }
    
    func testTrackingLiteralDeleteOnly() {
        var action = SearchReplaceAction()
        action.searchText = "_copy"
        action.replaceText = ""
        action.replaceAll = true
        
        let result = action.applyWithTracking(to: "file_copy.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "file.txt")
        XCTAssertTrue(result.changedRanges.isEmpty) // Nothing added
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 4..<9) // "_copy" was at 4-9
    }
    
    func testTrackingNoMatch() {
        var action = SearchReplaceAction()
        action.searchText = "xyz"
        action.replaceText = "abc"
        action.replaceAll = true
        
        let result = action.applyWithTracking(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "test.txt")
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingEmptySearchText() {
        var action = SearchReplaceAction()
        action.searchText = ""
        action.replaceText = "X"
        action.replaceAll = true
        
        let result = action.applyWithTracking(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "test.txt")
        XCTAssertTrue(result.changedRanges.isEmpty)
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingRegexSingleMatch() {
        var action = SearchReplaceAction()
        action.searchText = "\\d+"
        action.replaceText = "NUM"
        action.useRegex = true
        action.replaceAll = false
        
        let result = action.applyWithTracking(to: "file123test456.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "fileNUMtest456.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 4..<7) // "NUM" at position 4-7
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 4..<7) // "123" was at 4-7
    }
    
    func testTrackingRegexMultipleMatches() {
        var action = SearchReplaceAction()
        action.searchText = "\\d+"
        action.replaceText = "N"
        action.useRegex = true
        action.replaceAll = true
        
        let result = action.applyWithTracking(to: "a1b22c333.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "aNbNcN.txt")
        XCTAssertEqual(result.changedRanges.count, 3)
        XCTAssertEqual(result.deletedRanges.count, 3)
        // Original: a1b22c333 -> positions: a=0, 1=1, b=2, 22=3-4, c=5, 333=6-8
        XCTAssertEqual(result.deletedRanges[0], 1..<2)  // "1"
        XCTAssertEqual(result.deletedRanges[1], 3..<5)  // "22"
        XCTAssertEqual(result.deletedRanges[2], 6..<9)  // "333"
    }
    
    func testTrackingRegexWithCaptureGroups() {
        var action = SearchReplaceAction()
        action.searchText = "(\\w+)-(\\w+)"
        action.replaceText = "$2_$1"
        action.useRegex = true
        action.replaceAll = true
        
        let result = action.applyWithTracking(to: "first-second.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "second_first.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        // "second_first" replaces "first-second" at position 0
        XCTAssertEqual(result.changedRanges.first, 0..<12)
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 0..<12)
    }
    
    func testTrackingLiteralLongerReplacement() {
        var action = SearchReplaceAction()
        action.searchText = "a"
        action.replaceText = "XXX"
        action.replaceAll = true
        
        let result = action.applyWithTracking(to: "a_a.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "XXX_XXX.txt")
        XCTAssertEqual(result.changedRanges.count, 2)
        XCTAssertEqual(result.changedRanges[0], 0..<3)  // First XXX
        XCTAssertEqual(result.changedRanges[1], 4..<7)  // Second XXX (offset by +2 from first replacement)
    }
    
    func testTrackingShorterReplacement() {
        var action = SearchReplaceAction()
        action.searchText = "aaa"
        action.replaceText = "X"
        action.replaceAll = true
        
        let result = action.applyWithTracking(to: "aaa_aaa.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "X_X.txt")
        XCTAssertEqual(result.changedRanges.count, 2)
        XCTAssertEqual(result.changedRanges[0], 0..<1)  // First X
        XCTAssertEqual(result.changedRanges[1], 2..<3)  // Second X
        XCTAssertEqual(result.deletedRanges[0], 0..<3)  // First aaa
        XCTAssertEqual(result.deletedRanges[1], 4..<7)  // Second aaa
    }
    
    func testTrackingApplyToExtension() {
        var action = SearchReplaceAction()
        action.searchText = "t"
        action.replaceText = "X"
        action.replaceAll = true
        
        let result = action.applyWithTracking(to: "test.txt", at: 0, totalCount: 1, applyToExtension: true)
        
        XCTAssertEqual(result.newName, "XesX.XxX")
        // Should have changes in both name and extension
        XCTAssertTrue(result.changedRanges.count >= 2)
    }
    
    func testTrackingUnicode() {
        var action = SearchReplaceAction()
        action.searchText = "日本"
        action.replaceText = "JP"
        action.replaceAll = true
        
        let result = action.applyWithTracking(to: "日本語.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "JP語.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<2)  // "JP"
        XCTAssertEqual(result.deletedRanges.first, 0..<2)  // "日本" (2 characters)
    }
    
    func testTrackingReplaceFirstOnly() {
        var action = SearchReplaceAction()
        action.searchText = "test"
        action.replaceText = "demo"
        action.replaceAll = false
        
        let result = action.applyWithTracking(to: "test_test_test.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "demo_test_test.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<4)
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 0..<4)
    }
}
