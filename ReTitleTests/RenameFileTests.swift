import XCTest
@testable import ReTitle

final class RenameFileTests: XCTestCase {

    // MARK: - Original Name Tests

    func testOriginalNameSimple() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/file.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, "file.txt")
    }

    func testOriginalNameNoExtension() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/myfile")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, "myfile")
    }

    func testOriginalNameMultipleDots() {
        let url = URL(fileURLWithPath: "/Users/test/my.file.name.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, "my.file.name.txt")
    }

    func testOriginalNameWithSpaces() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/my file name.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, "my file name.txt")
    }

    // MARK: - Name Without Extension Tests

    func testNameWithoutExtensionSimple() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/file.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.nameWithoutExtension, "file")
    }

    func testNameWithoutExtensionNoExtension() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/myfile")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.nameWithoutExtension, "myfile")
    }

    func testNameWithoutExtensionMultipleDots() {
        let url = URL(fileURLWithPath: "/Users/test/my.file.name.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.nameWithoutExtension, "my.file.name")
    }

    func testNameWithoutExtensionHiddenFile() {
        let url = URL(fileURLWithPath: "/Users/test/.gitignore")
        let file = RenameFile(url: url)

        // Hidden files with no extension after the dot
        XCTAssertEqual(file.nameWithoutExtension, ".gitignore")
    }

    // MARK: - File Extension Tests

    func testFileExtensionSimple() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/file.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.fileExtension, "txt")
    }

    func testFileExtensionUppercase() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/file.TXT")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.fileExtension, "TXT")
    }

    func testFileExtensionMultipleDots() {
        let url = URL(fileURLWithPath: "/Users/test/archive.tar.gz")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.fileExtension, "gz")
    }

    func testFileExtensionNone() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/myfile")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.fileExtension, "")
    }

    func testFileExtensionLong() {
        let url = URL(fileURLWithPath: "/Users/test/file.javascript")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.fileExtension, "javascript")
    }

    // MARK: - Parent Directory Tests

    func testParentDirectorySimple() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/file.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.parentDirectory.path, "/Users/test/Documents")
    }

    func testParentDirectoryNested() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/Projects/MyApp/file.swift")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.parentDirectory.path, "/Users/test/Documents/Projects/MyApp")
    }

    func testParentDirectoryRoot() {
        let url = URL(fileURLWithPath: "/file.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.parentDirectory.path, "/")
    }

    // MARK: - New URL Tests

    func testNewURLSimple() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/file.txt")
        let file = RenameFile(url: url)

        let newURL = file.newURL(withName: "renamed.txt")
        XCTAssertEqual(newURL.path, "/Users/test/Documents/renamed.txt")
    }

    func testNewURLPreservesDirectory() {
        let url = URL(fileURLWithPath: "/Users/test/Projects/code.swift")
        let file = RenameFile(url: url)

        let newURL = file.newURL(withName: "newcode.swift")
        XCTAssertEqual(newURL.path, "/Users/test/Projects/newcode.swift")
    }

    func testNewURLDifferentExtension() {
        let url = URL(fileURLWithPath: "/Users/test/image.jpg")
        let file = RenameFile(url: url)

        let newURL = file.newURL(withName: "image.png")
        XCTAssertEqual(newURL.path, "/Users/test/image.png")
    }

    func testNewURLWithSpaces() {
        let url = URL(fileURLWithPath: "/Users/test/old name.txt")
        let file = RenameFile(url: url)

        let newURL = file.newURL(withName: "new name with spaces.txt")
        XCTAssertEqual(newURL.path, "/Users/test/new name with spaces.txt")
    }

    func testNewURLNoExtension() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/file.txt")
        let file = RenameFile(url: url)

        let newURL = file.newURL(withName: "noextension")
        XCTAssertEqual(newURL.path, "/Users/test/Documents/noextension")
    }

    // MARK: - Identifiable Tests

    func testUniqueIdentifiers() {
        let url = URL(fileURLWithPath: "/Users/test/file.txt")
        let file1 = RenameFile(url: url)
        let file2 = RenameFile(url: url)

        // Each instance should have a unique ID
        XCTAssertNotEqual(file1.id, file2.id)
    }

    // MARK: - Equatable Tests

    func testEquatableSameURL() {
        let url = URL(fileURLWithPath: "/Users/test/file.txt")
        let file1 = RenameFile(url: url)
        let file2 = RenameFile(url: url)

        // Different instances with same URL should still be different (due to UUID)
        XCTAssertNotEqual(file1, file2)
    }

    func testEquatableDifferentURL() {
        let file1 = RenameFile(url: URL(fileURLWithPath: "/Users/test/file1.txt"))
        let file2 = RenameFile(url: URL(fileURLWithPath: "/Users/test/file2.txt"))

        XCTAssertNotEqual(file1, file2)
    }

    // MARK: - Special Characters Tests

    func testSpecialCharactersInName() {
        let url = URL(fileURLWithPath: "/Users/test/[2024] Report (Final).pdf")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, "[2024] Report (Final).pdf")
        XCTAssertEqual(file.nameWithoutExtension, "[2024] Report (Final)")
        XCTAssertEqual(file.fileExtension, "pdf")
    }

    func testUnicodeCharacters() {
        let url = URL(fileURLWithPath: "/Users/test/日本語ファイル.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, "日本語ファイル.txt")
        XCTAssertEqual(file.nameWithoutExtension, "日本語ファイル")
        XCTAssertEqual(file.fileExtension, "txt")
    }

    func testEmojiInName() {
        let url = URL(fileURLWithPath: "/Users/test/📄Document.pdf")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, "📄Document.pdf")
        XCTAssertEqual(file.nameWithoutExtension, "📄Document")
    }

    // MARK: - Edge Cases

    func testHiddenFileWithExtension() {
        let url = URL(fileURLWithPath: "/Users/test/.config.json")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, ".config.json")
        XCTAssertEqual(file.nameWithoutExtension, ".config")
        XCTAssertEqual(file.fileExtension, "json")
    }

    func testOnlyExtension() {
        let url = URL(fileURLWithPath: "/Users/test/.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, ".txt")
    }

    func testVeryLongFilename() {
        let longName = String(repeating: "a", count: 200)
        let url = URL(fileURLWithPath: "/Users/test/\(longName).txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.nameWithoutExtension, longName)
        XCTAssertEqual(file.fileExtension, "txt")
    }

    // MARK: - Additional Edge Cases

    func testNewURLWithEmptyName() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/file.txt")
        let file = RenameFile(url: url)

        // Empty name appends just empty to parent, resulting in parent directory
        let newURL = file.newURL(withName: "")
        // appendingPathComponent("") results in "/Users/test/Documents" (trailing slash normalized)
        XCTAssertTrue(newURL.path.contains("Documents"))
    }

    func testOnlyDotsFilename() {
        let url = URL(fileURLWithPath: "/Users/test/...")
        let file = RenameFile(url: url)

        // ... is treated as name ".." with extension ""
        XCTAssertEqual(file.originalName, "...")
    }

    func testDoubleDotFilename() {
        let url = URL(fileURLWithPath: "/Users/test/..")
        let file = RenameFile(url: url)

        // .. is a directory reference
        XCTAssertEqual(file.originalName, "..")
    }

    func testFilenameWithLeadingSpaces() {
        let url = URL(fileURLWithPath: "/Users/test/ filename.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, " filename.txt")
        XCTAssertEqual(file.nameWithoutExtension, " filename")
    }

    func testFilenameWithTrailingSpaces() {
        let url = URL(fileURLWithPath: "/Users/test/filename .txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, "filename .txt")
        XCTAssertEqual(file.nameWithoutExtension, "filename ")
    }

    func testNewURLWithSpecialCharacters() {
        let url = URL(fileURLWithPath: "/Users/test/old.txt")
        let file = RenameFile(url: url)

        let newURL = file.newURL(withName: "[new] (file) #1.txt")
        XCTAssertEqual(newURL.path, "/Users/test/[new] (file) #1.txt")
    }

    func testNewURLWithUnicode() {
        let url = URL(fileURLWithPath: "/Users/test/old.txt")
        let file = RenameFile(url: url)

        let newURL = file.newURL(withName: "日本語ファイル.txt")
        XCTAssertEqual(newURL.path, "/Users/test/日本語ファイル.txt")
    }

    func testPercentEncodedURL() {
        // URL with percent encoding
        let url = URL(fileURLWithPath: "/Users/test/file%20name.txt")
        let file = RenameFile(url: url)

        // URL API handles percent encoding
        XCTAssertFalse(file.originalName.isEmpty)
    }

    func testVeryDeepDirectoryNesting() {
        let deepPath = "/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/file.txt"
        let url = URL(fileURLWithPath: deepPath)
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, "file.txt")
        XCTAssertEqual(file.parentDirectory.path, "/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t")
    }

    func testTarGzExtension() {
        let url = URL(fileURLWithPath: "/Users/test/archive.tar.gz")
        let file = RenameFile(url: url)

        // Only the last extension is returned
        XCTAssertEqual(file.fileExtension, "gz")
        XCTAssertEqual(file.nameWithoutExtension, "archive.tar")
    }

    func testCombiningCharactersInFilename() {
        // café with e + combining accent
        let url = URL(fileURLWithPath: "/Users/test/cafe\u{0301}.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.fileExtension, "txt")
        XCTAssertTrue(file.nameWithoutExtension.contains("caf"))
    }

    func testHiddenFileNoExtension() {
        let url = URL(fileURLWithPath: "/Users/test/.bashrc")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, ".bashrc")
        XCTAssertEqual(file.nameWithoutExtension, ".bashrc")
        XCTAssertEqual(file.fileExtension, "")
    }

    func testHiddenFileWithMultipleDots() {
        let url = URL(fileURLWithPath: "/Users/test/.config.backup.json")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, ".config.backup.json")
        XCTAssertEqual(file.fileExtension, "json")
        XCTAssertEqual(file.nameWithoutExtension, ".config.backup")
    }

    func testNewURLPreservesHiddenPrefix() {
        let url = URL(fileURLWithPath: "/Users/test/.gitignore")
        let file = RenameFile(url: url)

        let newURL = file.newURL(withName: ".svnignore")
        XCTAssertEqual(newURL.path, "/Users/test/.svnignore")
    }

    func testSingleCharacterFilename() {
        let url = URL(fileURLWithPath: "/Users/test/a.txt")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, "a.txt")
        XCTAssertEqual(file.nameWithoutExtension, "a")
        XCTAssertEqual(file.fileExtension, "txt")
    }

    func testSingleCharacterFilenameNoExtension() {
        let url = URL(fileURLWithPath: "/Users/test/x")
        let file = RenameFile(url: url)

        XCTAssertEqual(file.originalName, "x")
        XCTAssertEqual(file.nameWithoutExtension, "x")
        XCTAssertEqual(file.fileExtension, "")
    }
}
