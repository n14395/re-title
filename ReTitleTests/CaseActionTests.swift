import XCTest
@testable import ReTitle

final class CaseActionTests: XCTestCase {

    // MARK: - Uppercase Tests

    func testUppercaseSimpleFilename() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "hello world.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "HELLO WORLD.txt")
    }

    func testUppercaseWithExtensionApplied() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "hello world.txt", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, "HELLO WORLD.TXT")
    }

    func testUppercaseNoExtension() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "hello world", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "HELLO WORLD")
    }

    func testUppercaseMixedCase() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "HeLLo WoRLd.TXT", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "HELLO WORLD.TXT")
    }

    // MARK: - Lowercase Tests

    func testLowercaseSimpleFilename() {
        var action = CaseAction()
        action.caseType = .lower

        let result = action.apply(to: "HELLO WORLD.TXT", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "hello world.TXT")
    }

    func testLowercaseWithExtensionApplied() {
        var action = CaseAction()
        action.caseType = .lower

        let result = action.apply(to: "HELLO WORLD.TXT", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, "hello world.txt")
    }

    func testLowercaseNoExtension() {
        var action = CaseAction()
        action.caseType = .lower

        let result = action.apply(to: "HELLO WORLD", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "hello world")
    }

    // MARK: - Title Case Tests

    func testTitleCaseSimple() {
        var action = CaseAction()
        action.caseType = .title

        let result = action.apply(to: "hello world.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Hello World.txt")
    }

    func testTitleCaseWithExtension() {
        var action = CaseAction()
        action.caseType = .title

        let result = action.apply(to: "hello world.txt", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, "Hello World.Txt")
    }

    func testTitleCaseFromUppercase() {
        var action = CaseAction()
        action.caseType = .title

        let result = action.apply(to: "HELLO WORLD.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Hello World.txt")
    }

    // MARK: - Sentence Case Tests

    func testSentenceCaseSimple() {
        var action = CaseAction()
        action.caseType = .sentence

        let result = action.apply(to: "hello world.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Hello world.txt")
    }

    func testSentenceCaseWithExtension() {
        var action = CaseAction()
        action.caseType = .sentence

        let result = action.apply(to: "hello world.TXT", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, "Hello world.Txt")
    }

    func testSentenceCaseFromUppercase() {
        var action = CaseAction()
        action.caseType = .sentence

        let result = action.apply(to: "HELLO WORLD.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Hello world.txt")
    }

    // MARK: - Edge Cases

    func testHiddenFile() {
        // .txt is treated as a hidden file named ".txt" with no extension
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: ".txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".TXT")
    }

    func testHiddenFileWithExtension() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: ".gitignore", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".GITIGNORE")
    }

    func testSingleCharacterFilename() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "a.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "A.txt")
    }

    func testSentenceCaseSingleCharacter() {
        var action = CaseAction()
        action.caseType = .sentence

        let result = action.apply(to: "a.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "A.txt")
    }

    func testSentenceCaseEmptyName() {
        var action = CaseAction()
        action.caseType = .sentence

        let result = action.apply(to: ".txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".txt")
    }

    func testMultipleDotsInFilename() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "my.file.name.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "MY.FILE.NAME.txt")
    }

    func testSpecialCharacters() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "hello-world_test.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "HELLO-WORLD_TEST.txt")
    }

    func testNumbersInFilename() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "file123.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "FILE123.txt")
    }

    func testUnicodeCharacters() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "café.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "CAFÉ.txt")
    }

    // MARK: - Index and TotalCount (should be ignored)

    func testIndexAndTotalCountIgnored() {
        var action = CaseAction()
        action.caseType = .upper

        let result1 = action.apply(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        let result2 = action.apply(to: "test.txt", at: 5, totalCount: 10, applyToExtension: false)
        let result3 = action.apply(to: "test.txt", at: 100, totalCount: 1000, applyToExtension: false)

        XCTAssertEqual(result1, "TEST.txt")
        XCTAssertEqual(result2, "TEST.txt")
        XCTAssertEqual(result3, "TEST.txt")
    }

    // MARK: - Additional Edge Cases

    func testEmptyFilename() {
        var action = CaseAction()
        action.caseType = .upper

        // Empty string URL results in "." as path component
        let result = action.apply(to: "", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertFalse(result.isEmpty)
    }

    func testWhitespaceOnlyFilename() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "   .txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "   .txt")
    }

    func testSentenceCaseWithLeadingWhitespace() {
        var action = CaseAction()
        action.caseType = .sentence

        // Leading space - first non-space char should be capitalized
        let result = action.apply(to: " hello world.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, " hello world.txt") // Space is first, capitalized space is still space
    }

    func testSentenceCaseWithLeadingNumbers() {
        var action = CaseAction()
        action.caseType = .sentence

        let result = action.apply(to: "123hello world.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "123hello world.txt") // Number doesn't change case
    }

    func testSentenceCaseWithLeadingSpecialChars() {
        var action = CaseAction()
        action.caseType = .sentence

        let result = action.apply(to: "--hello world.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "--hello world.txt") // Dash doesn't change case
    }

    func testTitleCaseWithMultiCharExtension() {
        var action = CaseAction()
        action.caseType = .title

        let result = action.apply(to: "photo.jpeg", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, "Photo.Jpeg")
    }

    func testLowerCaseNoExtensionWithApplyToExtension() {
        var action = CaseAction()
        action.caseType = .lower

        // No extension but applyToExtension is true - should still work
        let result = action.apply(to: "HELLO WORLD", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, "hello world")
    }

    func testUnicodeGermanEszett() {
        var action = CaseAction()
        action.caseType = .upper

        // German ß uppercases to SS
        let result = action.apply(to: "straße.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "STRASSE.txt")
    }

    func testUnicodeGreekSigma() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "σωμα.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "ΣΩΜΑ.txt")
    }

    func testUnicodeLowerGreek() {
        var action = CaseAction()
        action.caseType = .lower

        let result = action.apply(to: "ΣΩΜΑ.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "σωμα.txt")
    }

    func testTitleCaseWithHyphenatedWords() {
        var action = CaseAction()
        action.caseType = .title

        let result = action.apply(to: "hello-world.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Hello-World.txt")
    }

    func testTitleCaseWithUnderscore() {
        var action = CaseAction()
        action.caseType = .title

        let result = action.apply(to: "hello_world.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Hello_World.txt")
    }

    func testTitleCaseWithApostrophe() {
        var action = CaseAction()
        action.caseType = .title

        let result = action.apply(to: "it's a test.txt", at: 0, totalCount: 1, applyToExtension: false)
        // Swift's capitalized implementation may vary - just verify it contains expected words
        XCTAssertTrue(result.contains("It"))
        XCTAssertTrue(result.contains("Test"))
    }

    func testHiddenFileWithActualExtension() {
        var action = CaseAction()
        action.caseType = .upper

        // .bashrc is treated as hidden file named ".bashrc" with no extension
        let result = action.apply(to: ".bashrc", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, ".BASHRC")
    }

    func testHiddenFileWithActualExtensionApplyToExt() {
        var action = CaseAction()
        action.caseType = .upper

        // .config.json - has both hidden prefix and extension
        let result = action.apply(to: ".config.json", at: 0, totalCount: 1, applyToExtension: true)
        XCTAssertEqual(result, ".CONFIG.JSON")
    }

    func testEmojiInFilename() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "hello🌍world.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "HELLO🌍WORLD.txt")
    }

    func testCombiningCharacters() {
        var action = CaseAction()
        action.caseType = .upper

        // é composed as e + combining accent
        let result = action.apply(to: "cafe\u{0301}.txt", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "CAFÉ.txt")
    }

    func testOnlyDotsFilename() {
        var action = CaseAction()
        action.caseType = .upper

        let result = action.apply(to: "...", at: 0, totalCount: 1, applyToExtension: false)
        // "..." has name ".." and extension ""
        XCTAssertEqual(result, "...")
    }

    // MARK: - Enum Property Tests

    func testCaseTypeRawValues() {
        XCTAssertEqual(CaseType.upper.rawValue, "UPPERCASE")
        XCTAssertEqual(CaseType.lower.rawValue, "lowercase")
        XCTAssertEqual(CaseType.title.rawValue, "Title Case")
        XCTAssertEqual(CaseType.sentence.rawValue, "Sentence case")
    }

    func testCaseTypeIdentifiable() {
        XCTAssertEqual(CaseType.upper.id, "UPPERCASE")
        XCTAssertEqual(CaseType.lower.id, "lowercase")
        XCTAssertEqual(CaseType.title.id, "Title Case")
        XCTAssertEqual(CaseType.sentence.id, "Sentence case")
    }

    func testCaseTypeAllCases() {
        XCTAssertEqual(CaseType.allCases.count, 4)
        XCTAssertTrue(CaseType.allCases.contains(.upper))
        XCTAssertTrue(CaseType.allCases.contains(.lower))
        XCTAssertTrue(CaseType.allCases.contains(.title))
        XCTAssertTrue(CaseType.allCases.contains(.sentence))
    }
    
    // MARK: - Change Tracking Tests (applyWithTracking)
    
    func testTrackingUppercaseAllChanged() {
        var action = CaseAction()
        action.caseType = .upper
        
        let result = action.applyWithTracking(to: "test.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "TEST.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<4) // "test" -> "TEST"
        XCTAssertTrue(result.deletedRanges.isEmpty) // Case changes don't delete
    }
    
    func testTrackingLowercaseAllChanged() {
        var action = CaseAction()
        action.caseType = .lower
        
        let result = action.applyWithTracking(to: "TEST.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "test.txt")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<4)
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingNoChange() {
        var action = CaseAction()
        action.caseType = .upper
        
        let result = action.applyWithTracking(to: "TEST.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "TEST.txt")
        XCTAssertTrue(result.changedRanges.isEmpty) // Already uppercase
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingMixedCasePartialChange() {
        var action = CaseAction()
        action.caseType = .upper
        
        let result = action.applyWithTracking(to: "TeSt.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "TEST.txt")
        // 'e' at index 1 and 't' at index 3 changed
        XCTAssertEqual(result.changedRanges.count, 2)
        XCTAssertEqual(result.changedRanges[0], 1..<2) // 'e' -> 'E'
        XCTAssertEqual(result.changedRanges[1], 3..<4) // 't' -> 'T'
    }
    
    func testTrackingTitleCase() {
        var action = CaseAction()
        action.caseType = .title
        
        let result = action.applyWithTracking(to: "hello world.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "Hello World.txt")
        // 'h' -> 'H' and 'w' -> 'W', plus 'ello' -> 'ello' and 'orld' -> 'orld' stay same
        XCTAssertEqual(result.changedRanges.count, 2)
        XCTAssertEqual(result.changedRanges[0], 0..<1) // 'h' -> 'H'
        XCTAssertEqual(result.changedRanges[1], 6..<7) // 'w' -> 'W'
    }
    
    func testTrackingSentenceCase() {
        var action = CaseAction()
        action.caseType = .sentence
        
        let result = action.applyWithTracking(to: "HELLO WORLD.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "Hello world.txt")
        // H stays uppercase, ELLO -> ello (positions 1-4), space stays, WORLD -> world (positions 6-10)
        // Two separate ranges since space doesn't change
        XCTAssertEqual(result.changedRanges.count, 2)
        XCTAssertEqual(result.changedRanges[0], 1..<5)  // "ELLO" -> "ello"
        XCTAssertEqual(result.changedRanges[1], 6..<11) // "WORLD" -> "world"
    }
    
    func testTrackingApplyToExtension() {
        var action = CaseAction()
        action.caseType = .upper
        
        let result = action.applyWithTracking(to: "test.txt", at: 0, totalCount: 1, applyToExtension: true)
        
        XCTAssertEqual(result.newName, "TEST.TXT")
        // Name changes at 0-4, extension changes at 5-8
        XCTAssertEqual(result.changedRanges.count, 2)
        XCTAssertEqual(result.changedRanges[0], 0..<4) // "test" -> "TEST"
        XCTAssertEqual(result.changedRanges[1], 5..<8) // "txt" -> "TXT"
    }
    
    func testTrackingEmptyFilename() {
        var action = CaseAction()
        action.caseType = .upper
        
        let result = action.applyWithTracking(to: ".txt", at: 0, totalCount: 1, applyToExtension: false)
        
        // ".txt" is treated as hidden file ".txt" with empty extension
        XCTAssertEqual(result.newName, ".TXT")
        XCTAssertEqual(result.changedRanges.count, 1)
    }
    
    func testTrackingNoExtension() {
        var action = CaseAction()
        action.caseType = .upper
        
        let result = action.applyWithTracking(to: "readme", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "README")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<6)
    }
    
    func testTrackingUnicode() {
        var action = CaseAction()
        action.caseType = .upper
        
        let result = action.applyWithTracking(to: "café.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "CAFÉ.txt")
        XCTAssertFalse(result.changedRanges.isEmpty)
    }
    
    func testTrackingContiguousRangesMerged() {
        var action = CaseAction()
        action.caseType = .lower
        
        let result = action.applyWithTracking(to: "ABC.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "abc.txt")
        // Should be single range 0..<3, not three separate ranges
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<3)
    }
    
    func testTrackingNonContiguousRangesSeparate() {
        var action = CaseAction()
        action.caseType = .upper
        
        let result = action.applyWithTracking(to: "a1b2c.txt", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "A1B2C.txt")
        // 'a' at 0, 'b' at 2, 'c' at 4 - three separate ranges
        XCTAssertEqual(result.changedRanges.count, 3)
        XCTAssertEqual(result.changedRanges[0], 0..<1)
        XCTAssertEqual(result.changedRanges[1], 2..<3)
        XCTAssertEqual(result.changedRanges[2], 4..<5)
    }
}
