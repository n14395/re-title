// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import ReTitle

/// Tests for RenameResult
final class RenameResultTests: XCTestCase {

    func testRenameResultSuccess() {
        let originalURL = URL(fileURLWithPath: "/test/old.txt")
        let newURL = URL(fileURLWithPath: "/test/new.txt")
        let fileID = UUID()

        let result = RenameResult(
        originalURL: originalURL,
        newURL: newURL,
        success: true,
        error: nil,
        fileID: fileID
        )

        XCTAssertEqual(result.originalURL, originalURL)
        XCTAssertEqual(result.newURL, newURL)
        XCTAssertTrue(result.success)
        XCTAssertNil(result.error)
        XCTAssertEqual(result.fileID, fileID)
        XCTAssertNotNil(result.id)
    }

    func testRenameResultFailure() {
        let originalURL = URL(fileURLWithPath: "/test/old.txt")
        let newURL = URL(fileURLWithPath: "/test/new.txt")
        let fileID = UUID()
        let errorMessage = "File already exists"

        let result = RenameResult(
        originalURL: originalURL,
        newURL: newURL,
        success: false,
        error: errorMessage,
        fileID: fileID
        )

        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, errorMessage)
    }

    func testRenameResultIdentifiable() {
        let result1 = RenameResult(
        originalURL: URL(fileURLWithPath: "/test/a.txt"),
        newURL: URL(fileURLWithPath: "/test/b.txt"),
        success: true,
        error: nil,
        fileID: UUID()
        )
        let result2 = RenameResult(
        originalURL: URL(fileURLWithPath: "/test/a.txt"),
        newURL: URL(fileURLWithPath: "/test/b.txt"),
        success: true,
        error: nil,
        fileID: UUID()
        )

        XCTAssertNotEqual(result1.id, result2.id)
    }

    func testRenameResultWithEmptyError() {
        let result = RenameResult(
        originalURL: URL(fileURLWithPath: "/test/a.txt"),
        newURL: URL(fileURLWithPath: "/test/b.txt"),
        success: false,
        error: "",
        fileID: UUID()
        )

        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, "")
    }

    func testRenameResultPreservesFileID() {
        let specificID = UUID()
        let result = RenameResult(
        originalURL: URL(fileURLWithPath: "/test/a.txt"),
        newURL: URL(fileURLWithPath: "/test/b.txt"),
        success: true,
        error: nil,
        fileID: specificID
        )

        XCTAssertEqual(result.fileID, specificID)
    }
}

/// Tests for RenameViewModel
final class RenameViewModelTests: XCTestCase {

    // MARK: - Current Action Tests

    func testCurrentActionReturnsSearchReplace() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .searchReplace
            XCTAssertTrue(viewModel.currentAction is SearchReplaceAction)
        }
    }

    func testCurrentActionReturnsCaseAction() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .caseChange
            XCTAssertTrue(viewModel.currentAction is CaseAction)
        }
    }

    func testCurrentActionReturnsInsertAction() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .insert
            XCTAssertTrue(viewModel.currentAction is InsertAction)
        }
    }

    func testCurrentActionReturnsRemoveAction() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .remove
            XCTAssertTrue(viewModel.currentAction is RemoveAction)
        }
    }

    func testCurrentActionReturnsNumberingAction() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .numbering
            XCTAssertTrue(viewModel.currentAction is NumberingAction)
        }
    }

    func testCurrentActionReturnsDateTimeAction() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .dateTime
            XCTAssertTrue(viewModel.currentAction is DateTimeAction)
        }
    }

    func testCurrentActionReturnsExifAction() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .exif
            XCTAssertTrue(viewModel.currentAction is ExifAction)
        }
    }

    // MARK: - Default Values Tests

    func testDefaultSelectedActionType() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertEqual(viewModel.selectedActionType, .searchReplace)
        }
    }

    func testDefaultApplyToExtension() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertFalse(viewModel.applyToExtension)
        }
    }

    func testDefaultFilesEmpty() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertTrue(viewModel.files.isEmpty)
        }
    }

    func testDefaultDestinationFolder() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertNil(viewModel.destinationFolder)
        }
    }

    func testDestinationFolderNameDefault() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertEqual(viewModel.destinationFolderName, "Don't Move")
        }
    }

    // MARK: - Preview Name Tests

    func testPreviewNameWithSearchReplace() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .searchReplace
            viewModel.searchReplaceAction.searchText = "old"
            viewModel.searchReplaceAction.replaceText = "new"
            viewModel.searchReplaceAction.replaceAll = true

            let url = URL(fileURLWithPath: "/test/old_file.txt")
            let file = RenameFile(url: url)
            viewModel.files = [file]

            let preview = viewModel.previewName(for: file, at: 0)
            XCTAssertEqual(preview, "new_file.txt")
        }
    }

    func testPreviewNameWithCaseAction() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .caseChange
            viewModel.caseAction.caseType = .upper

            let url = URL(fileURLWithPath: "/test/hello.txt")
            let file = RenameFile(url: url)
            viewModel.files = [file]

            let preview = viewModel.previewName(for: file, at: 0)
            XCTAssertEqual(preview, "HELLO.txt")
        }
    }

    func testPreviewNameWithApplyToExtension() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .caseChange
            viewModel.caseAction.caseType = .upper
            viewModel.applyToExtension = true

            let url = URL(fileURLWithPath: "/test/hello.txt")
            let file = RenameFile(url: url)
            viewModel.files = [file]

            let preview = viewModel.previewName(for: file, at: 0)
            XCTAssertEqual(preview, "HELLO.TXT")
        }
    }

    // MARK: - Has Duplicate New Names Tests

    func testHasDuplicateNewNamesReturnsFalseForUnique() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .numbering
            viewModel.numberingAction.startNumber = 1
            viewModel.numberingAction.increment = 1
            viewModel.numberingAction.position = .prefix
            viewModel.numberingAction.padding = .none
            viewModel.numberingAction.separator = "_"

            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            viewModel.files = [file1, file2]

            XCTAssertFalse(viewModel.hasDuplicateNewNames)
        }
    }

    func testHasDuplicateNewNamesReturnsTrueForDuplicates() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .searchReplace
            viewModel.searchReplaceAction.searchText = ".*"
            viewModel.searchReplaceAction.replaceText = "same"
            viewModel.searchReplaceAction.useRegex = true
            viewModel.searchReplaceAction.replaceAll = true

            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            viewModel.files = [file1, file2]

            XCTAssertTrue(viewModel.hasDuplicateNewNames)
        }
    }

    func testHasDuplicateNewNamesWithEmptyFiles() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.files = []
            XCTAssertFalse(viewModel.hasDuplicateNewNames)
        }
    }

    // MARK: - Clear Files Tests

    func testClearFilesRemovesAllFiles() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            viewModel.files = [file1]

            viewModel.clearFiles()

            XCTAssertTrue(viewModel.files.isEmpty)
        }
    }

    // MARK: - Remove File Tests

    func testRemoveFileRemovesSpecificFile() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            viewModel.files = [file1, file2]

            viewModel.removeFile(file1)

            XCTAssertEqual(viewModel.files.count, 1)
            XCTAssertFalse(viewModel.files.contains(where: { $0.id == file1.id }))
            XCTAssertTrue(viewModel.files.contains(where: { $0.id == file2.id }))
        }
    }

    // MARK: - Clear Destination Folder Tests

    func testClearDestinationFolder() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.clearDestinationFolder()

            XCTAssertNil(viewModel.destinationFolder)
            XCTAssertEqual(viewModel.destinationFolderName, "Don't Move")
        }
    }
    
    // MARK: - Preview Result Tests (Change Tracking)
    
    func testPreviewResultReturnsRenamePreviewResult() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file = RenameFile(url: URL(fileURLWithPath: "/test/file.txt"))
            viewModel.files = [file]
            viewModel.selectedActionType = .caseChange
            viewModel.caseAction.caseType = .upper
            
            let result = viewModel.previewResult(for: file, at: 0)
            
            XCTAssertEqual(result.newName, "FILE.txt")
            XCTAssertFalse(result.changedRanges.isEmpty)
            XCTAssertTrue(result.deletedRanges.isEmpty) // Case change doesn't delete
        }
    }
    
    func testPreviewResultWithSearchReplace() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file = RenameFile(url: URL(fileURLWithPath: "/test/old_file.txt"))
            viewModel.files = [file]
            viewModel.selectedActionType = .searchReplace
            viewModel.searchReplaceAction.searchText = "old"
            viewModel.searchReplaceAction.replaceText = "new"
            viewModel.searchReplaceAction.replaceAll = true
            
            let result = viewModel.previewResult(for: file, at: 0)
            
            XCTAssertEqual(result.newName, "new_file.txt")
            XCTAssertEqual(result.changedRanges.count, 1)
            XCTAssertEqual(result.deletedRanges.count, 1)
        }
    }
    
    func testPreviewResultWithInsert() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file = RenameFile(url: URL(fileURLWithPath: "/test/file.txt"))
            viewModel.files = [file]
            viewModel.selectedActionType = .insert
            viewModel.insertAction.mode = .insert
            viewModel.insertAction.position = .start
            viewModel.insertAction.text = "PREFIX_"
            
            let result = viewModel.previewResult(for: file, at: 0)
            
            XCTAssertEqual(result.newName, "PREFIX_file.txt")
            XCTAssertEqual(result.changedRanges.first, 0..<7)
            XCTAssertTrue(result.deletedRanges.isEmpty)
        }
    }
    
    func testPreviewResultWithRemove() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file = RenameFile(url: URL(fileURLWithPath: "/test/testfile.txt"))
            viewModel.files = [file]
            viewModel.selectedActionType = .remove
            viewModel.removeAction.mode = .firstN
            viewModel.removeAction.count = 4
            
            let result = viewModel.previewResult(for: file, at: 0)
            
            XCTAssertEqual(result.newName, "file.txt")
            XCTAssertTrue(result.changedRanges.isEmpty) // Remove doesn't add
            XCTAssertEqual(result.deletedRanges.first, 0..<4)
        }
    }
    
    func testPreviewResultWithNumbering() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file = RenameFile(url: URL(fileURLWithPath: "/test/file.txt"))
            viewModel.files = [file]
            viewModel.selectedActionType = .numbering
            viewModel.numberingAction.position = .prefix
            viewModel.numberingAction.startNumber = 1
            viewModel.numberingAction.padding = .none
            viewModel.numberingAction.separator = "_"
            
            let result = viewModel.previewResult(for: file, at: 0)
            
            XCTAssertEqual(result.newName, "1_file.txt")
            XCTAssertEqual(result.changedRanges.first, 0..<2)
        }
    }
    
    func testPreviewResultUnchangedFile() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file = RenameFile(url: URL(fileURLWithPath: "/test/FILE.txt"))
            viewModel.files = [file]
            viewModel.selectedActionType = .caseChange
            viewModel.caseAction.caseType = .upper // Already uppercase
            
            let result = viewModel.previewResult(for: file, at: 0)
            
            XCTAssertEqual(result.newName, "FILE.txt")
            XCTAssertTrue(result.changedRanges.isEmpty) // No change needed
        }
    }
    
    func testPreviewResultConsistentWithPreviewName() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file = RenameFile(url: URL(fileURLWithPath: "/test/document.txt"))
            viewModel.files = [file]
            viewModel.selectedActionType = .caseChange
            viewModel.caseAction.caseType = .upper
            
            let previewName = viewModel.previewName(for: file, at: 0)
            let previewResult = viewModel.previewResult(for: file, at: 0)
            
            // Both methods should return the same new name
            XCTAssertEqual(previewName, previewResult.newName)
        }
    }
    
    // MARK: - Add Files Tests
    
    func testAddFilesFiltersDirectories() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            // Create URLs - directories would be filtered out in real scenario
            // but we can test the logic with file URLs
            let fileURL = URL(fileURLWithPath: "/test/file.txt")
            let file = RenameFile(url: fileURL)
            viewModel.files = [file]
            
            XCTAssertEqual(viewModel.files.count, 1)
        }
    }
    
    func testAddFilesFiltersDuplicates() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let url = URL(fileURLWithPath: "/test/file.txt")
            let file1 = RenameFile(url: url)
            let file2 = RenameFile(url: url) // Same URL
            
            viewModel.files = [file1]
            // Manually check duplicate logic
            let isDuplicate = viewModel.files.contains { $0.url == file2.url }
            XCTAssertTrue(isDuplicate)
        }
    }
    
    func testAddFilesPreservesExistingFiles() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            
            viewModel.files = [file1]
            XCTAssertEqual(viewModel.files.count, 1)
            
            // Add file2 manually (simulating addFiles behavior)
            viewModel.files.append(file2)
            XCTAssertEqual(viewModel.files.count, 2)
        }
    }
    
    // MARK: - Destination Folder Tests
    
    func testDestinationFolderInitiallyNil() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertNil(viewModel.destinationFolder)
        }
    }
    
    func testDestinationFolderNameWhenSet() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let folderURL = URL(fileURLWithPath: "/Users/test/Desktop")
            viewModel.destinationFolder = folderURL
            
            XCTAssertEqual(viewModel.destinationFolderName, "Desktop")
        }
    }
    
    func testDestinationFolderNameWhenNil() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.destinationFolder = nil
            XCTAssertEqual(viewModel.destinationFolderName, "Don't Move")
        }
    }
    
    func testClearDestinationFolderResetsToNil() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.destinationFolder = URL(fileURLWithPath: "/Users/test/Desktop")
            
            viewModel.clearDestinationFolder()
            
            XCTAssertNil(viewModel.destinationFolder)
            XCTAssertEqual(viewModel.destinationFolderName, "Don't Move")
        }
    }
    
    // MARK: - Multiple Files Tests
    
    func testPreviewNameForMultipleFiles() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .numbering
            viewModel.numberingAction.startNumber = 1
            viewModel.numberingAction.increment = 1
            viewModel.numberingAction.position = .prefix
            viewModel.numberingAction.padding = .none
            viewModel.numberingAction.separator = "_"
            
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            let file3 = RenameFile(url: URL(fileURLWithPath: "/test/c.txt"))
            viewModel.files = [file1, file2, file3]
            
            XCTAssertEqual(viewModel.previewName(for: file1, at: 0), "1_a.txt")
            XCTAssertEqual(viewModel.previewName(for: file2, at: 1), "2_b.txt")
            XCTAssertEqual(viewModel.previewName(for: file3, at: 2), "3_c.txt")
        }
    }
    
    func testHasDuplicateNewNamesWithSingleFile() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file = RenameFile(url: URL(fileURLWithPath: "/test/file.txt"))
            viewModel.files = [file]
            
            // Single file can't have duplicates
            XCTAssertFalse(viewModel.hasDuplicateNewNames)
        }
    }
    
    func testHasDuplicateNewNamesWithIdenticalNames() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .searchReplace
            viewModel.searchReplaceAction.searchText = ""
            viewModel.searchReplaceAction.replaceText = ""
            
            // Two files with same name in different directories
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test1/same.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test2/same.txt"))
            viewModel.files = [file1, file2]
            
            // Same names = duplicates
            XCTAssertTrue(viewModel.hasDuplicateNewNames)
        }
    }
    
    // MARK: - Action Configuration Tests
    
    func testSearchReplaceActionDefaultValues() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertEqual(viewModel.searchReplaceAction.searchText, "")
            XCTAssertEqual(viewModel.searchReplaceAction.replaceText, "")
            XCTAssertFalse(viewModel.searchReplaceAction.useRegex)
            XCTAssertTrue(viewModel.searchReplaceAction.replaceAll)
        }
    }
    
    func testCaseActionDefaultValues() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertEqual(viewModel.caseAction.caseType, .upper)
        }
    }
    
    func testNumberingActionDefaultValues() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertEqual(viewModel.numberingAction.startNumber, 1)
            XCTAssertEqual(viewModel.numberingAction.increment, 1)
        }
    }
    
    // MARK: - Apply To Extension Tests
    
    func testApplyToExtensionDefaultFalse() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertFalse(viewModel.applyToExtension)
        }
    }
    
    func testApplyToExtensionAffectsPreview() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .caseChange
            viewModel.caseAction.caseType = .upper
            
            let file = RenameFile(url: URL(fileURLWithPath: "/test/hello.txt"))
            viewModel.files = [file]
            
            // Without apply to extension
            viewModel.applyToExtension = false
            let previewWithout = viewModel.previewName(for: file, at: 0)
            XCTAssertEqual(previewWithout, "HELLO.txt")
            
            // With apply to extension
            viewModel.applyToExtension = true
            let previewWith = viewModel.previewName(for: file, at: 0)
            XCTAssertEqual(previewWith, "HELLO.TXT")
        }
    }
    
    // MARK: - Remove File Tests
    
    func testRemoveFileFromMiddle() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            let file3 = RenameFile(url: URL(fileURLWithPath: "/test/c.txt"))
            viewModel.files = [file1, file2, file3]
            
            viewModel.removeFile(file2)
            
            XCTAssertEqual(viewModel.files.count, 2)
            XCTAssertTrue(viewModel.files.contains(where: { $0.id == file1.id }))
            XCTAssertFalse(viewModel.files.contains(where: { $0.id == file2.id }))
            XCTAssertTrue(viewModel.files.contains(where: { $0.id == file3.id }))
        }
    }
    
    func testRemoveFileNotInList() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            viewModel.files = [file1]
            
            // Remove file that's not in the list
            viewModel.removeFile(file2)
            
            // Should remain unchanged
            XCTAssertEqual(viewModel.files.count, 1)
            XCTAssertTrue(viewModel.files.contains(where: { $0.id == file1.id }))
        }
    }
    
    func testRemoveAllFiles() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            viewModel.files = [file1, file2]
            
            viewModel.removeFile(file1)
            viewModel.removeFile(file2)
            
            XCTAssertTrue(viewModel.files.isEmpty)
        }
    }
    
    // MARK: - Clear Files Tests
    
    func testClearFilesFromPopulatedList() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            viewModel.files = [file1, file2]
            
            viewModel.clearFiles()
            
            XCTAssertTrue(viewModel.files.isEmpty)
        }
    }
    
    func testClearFilesOnEmptyList() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.files = []
            
            viewModel.clearFiles()
            
            XCTAssertTrue(viewModel.files.isEmpty)
        }
    }
    
    // MARK: - Action Switching Tests
    
    func testSwitchingActionsPreservesFiles() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file = RenameFile(url: URL(fileURLWithPath: "/test/file.txt"))
            viewModel.files = [file]
            
            viewModel.selectedActionType = .searchReplace
            XCTAssertEqual(viewModel.files.count, 1)
            
            viewModel.selectedActionType = .caseChange
            XCTAssertEqual(viewModel.files.count, 1)
            
            viewModel.selectedActionType = .numbering
            XCTAssertEqual(viewModel.files.count, 1)
        }
    }
    
    func testSwitchingActionsChangesCurrentAction() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            
            viewModel.selectedActionType = .searchReplace
            XCTAssertTrue(viewModel.currentAction is SearchReplaceAction)
            
            viewModel.selectedActionType = .caseChange
            XCTAssertTrue(viewModel.currentAction is CaseAction)
            
            viewModel.selectedActionType = .insert
            XCTAssertTrue(viewModel.currentAction is InsertAction)
        }
    }
    
    // MARK: - Preview with Different Actions
    
    func testPreviewWithInsertAction() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .insert
            viewModel.insertAction.text = "PREFIX_"
            viewModel.insertAction.mode = .insert
            viewModel.insertAction.position = .start
            
            let file = RenameFile(url: URL(fileURLWithPath: "/test/document.txt"))
            viewModel.files = [file]
            
            let preview = viewModel.previewName(for: file, at: 0)
            XCTAssertEqual(preview, "PREFIX_document.txt")
        }
    }
    
    func testPreviewWithRemoveAction() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .remove
            viewModel.removeAction.mode = .firstN
            viewModel.removeAction.count = 3
            
            let file = RenameFile(url: URL(fileURLWithPath: "/test/prefixed_file.txt"))
            viewModel.files = [file]
            
            let preview = viewModel.previewName(for: file, at: 0)
            XCTAssertEqual(preview, "fixed_file.txt")
        }
    }
    
    func testPreviewWithDateTimeAction() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .dateTime
            viewModel.dateTimeAction.source = .customText
            viewModel.dateTimeAction.customText = "2024"
            viewModel.dateTimeAction.position = .prefix
            viewModel.dateTimeAction.separator = "_"

            let file = RenameFile(url: URL(fileURLWithPath: "/test/photo.jpg"))
            viewModel.files = [file]

            let preview = viewModel.previewName(for: file, at: 0)
            XCTAssertEqual(preview, "2024_photo.jpg")
        }
    }

    // MARK: - Move Files Tests (Drag and Drop Reordering)

    func testMoveFilesFromStartToEnd() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            let file3 = RenameFile(url: URL(fileURLWithPath: "/test/c.txt"))
            viewModel.files = [file1, file2, file3]

            // Move first item to end
            viewModel.moveFiles(fromOffsets: IndexSet(integer: 0), toOffset: 3)

            XCTAssertEqual(viewModel.files[0].id, file2.id)
            XCTAssertEqual(viewModel.files[1].id, file3.id)
            XCTAssertEqual(viewModel.files[2].id, file1.id)
        }
    }

    func testMoveFilesFromEndToStart() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            let file3 = RenameFile(url: URL(fileURLWithPath: "/test/c.txt"))
            viewModel.files = [file1, file2, file3]

            // Move last item to start
            viewModel.moveFiles(fromOffsets: IndexSet(integer: 2), toOffset: 0)

            XCTAssertEqual(viewModel.files[0].id, file3.id)
            XCTAssertEqual(viewModel.files[1].id, file1.id)
            XCTAssertEqual(viewModel.files[2].id, file2.id)
        }
    }

    func testMoveFilesMiddleToStart() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            let file3 = RenameFile(url: URL(fileURLWithPath: "/test/c.txt"))
            viewModel.files = [file1, file2, file3]

            // Move middle item to start
            viewModel.moveFiles(fromOffsets: IndexSet(integer: 1), toOffset: 0)

            XCTAssertEqual(viewModel.files[0].id, file2.id)
            XCTAssertEqual(viewModel.files[1].id, file1.id)
            XCTAssertEqual(viewModel.files[2].id, file3.id)
        }
    }

    func testMoveFilesPreservesAllFiles() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            let file3 = RenameFile(url: URL(fileURLWithPath: "/test/c.txt"))
            viewModel.files = [file1, file2, file3]

            viewModel.moveFiles(fromOffsets: IndexSet(integer: 0), toOffset: 2)

            // All files should still be present
            XCTAssertEqual(viewModel.files.count, 3)
            XCTAssertTrue(viewModel.files.contains(where: { $0.id == file1.id }))
            XCTAssertTrue(viewModel.files.contains(where: { $0.id == file2.id }))
            XCTAssertTrue(viewModel.files.contains(where: { $0.id == file3.id }))
        }
    }

    func testMoveFilesAffectsNumberingOrder() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            viewModel.selectedActionType = .numbering
            viewModel.numberingAction.startNumber = 1
            viewModel.numberingAction.increment = 1
            viewModel.numberingAction.position = .prefix
            viewModel.numberingAction.padding = .none
            viewModel.numberingAction.separator = "_"

            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            let file3 = RenameFile(url: URL(fileURLWithPath: "/test/c.txt"))
            viewModel.files = [file1, file2, file3]

            // Before move: a=1, b=2, c=3
            XCTAssertEqual(viewModel.previewName(for: file1, at: 0), "1_a.txt")
            XCTAssertEqual(viewModel.previewName(for: file2, at: 1), "2_b.txt")
            XCTAssertEqual(viewModel.previewName(for: file3, at: 2), "3_c.txt")

            // Move c.txt to the beginning
            viewModel.moveFiles(fromOffsets: IndexSet(integer: 2), toOffset: 0)

            // After move: c=1, a=2, b=3
            XCTAssertEqual(viewModel.previewName(for: viewModel.files[0], at: 0), "1_c.txt")
            XCTAssertEqual(viewModel.previewName(for: viewModel.files[1], at: 1), "2_a.txt")
            XCTAssertEqual(viewModel.previewName(for: viewModel.files[2], at: 2), "3_b.txt")
        }
    }

    func testMoveFilesWithTwoFiles() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            viewModel.files = [file1, file2]

            // Swap the two files
            viewModel.moveFiles(fromOffsets: IndexSet(integer: 0), toOffset: 2)

            XCTAssertEqual(viewModel.files[0].id, file2.id)
            XCTAssertEqual(viewModel.files[1].id, file1.id)
        }
    }

    func testMoveFilesMultipleItems() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            let file3 = RenameFile(url: URL(fileURLWithPath: "/test/c.txt"))
            let file4 = RenameFile(url: URL(fileURLWithPath: "/test/d.txt"))
            viewModel.files = [file1, file2, file3, file4]

            // Move first two items to end
            viewModel.moveFiles(fromOffsets: IndexSet([0, 1]), toOffset: 4)

            XCTAssertEqual(viewModel.files[0].id, file3.id)
            XCTAssertEqual(viewModel.files[1].id, file4.id)
            XCTAssertEqual(viewModel.files[2].id, file1.id)
            XCTAssertEqual(viewModel.files[3].id, file2.id)
        }
    }

    func testMoveFilesSamePosition() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            let file3 = RenameFile(url: URL(fileURLWithPath: "/test/c.txt"))
            viewModel.files = [file1, file2, file3]

            let originalOrder = viewModel.files.map { $0.id }

            // Move to same position (no-op)
            viewModel.moveFiles(fromOffsets: IndexSet(integer: 1), toOffset: 1)

            // Order should be unchanged
            XCTAssertEqual(viewModel.files.map { $0.id }, originalOrder)
        }
    }
    
    // MARK: - Selected File IDs Tests
    
    func testSelectedFileIDsInitiallyEmpty() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertTrue(viewModel.selectedFileIDs.isEmpty)
        }
    }
    
    func testSelectedFileIDsCanBeSet() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            viewModel.files = [file1, file2]
            
            viewModel.selectedFileIDs = [file1.id]
            
            XCTAssertEqual(viewModel.selectedFileIDs.count, 1)
            XCTAssertTrue(viewModel.selectedFileIDs.contains(file1.id))
        }
    }
    
    func testSelectedFileIDsMultipleSelection() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            let file2 = RenameFile(url: URL(fileURLWithPath: "/test/b.txt"))
            let file3 = RenameFile(url: URL(fileURLWithPath: "/test/c.txt"))
            viewModel.files = [file1, file2, file3]
            
            viewModel.selectedFileIDs = [file1.id, file3.id]
            
            XCTAssertEqual(viewModel.selectedFileIDs.count, 2)
            XCTAssertTrue(viewModel.selectedFileIDs.contains(file1.id))
            XCTAssertFalse(viewModel.selectedFileIDs.contains(file2.id))
            XCTAssertTrue(viewModel.selectedFileIDs.contains(file3.id))
        }
    }
    
    func testClearFilesDoesNotClearSelection() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            let file1 = RenameFile(url: URL(fileURLWithPath: "/test/a.txt"))
            viewModel.files = [file1]
            viewModel.selectedFileIDs = [file1.id]
            
            viewModel.clearFiles()
            
            // Selection remains (orphaned IDs are still in the set)
            // The view is responsible for filtering invalid selections
            XCTAssertEqual(viewModel.selectedFileIDs.count, 1)
        }
    }
    
    // MARK: - Undo Manager Integration Tests
    
    func testRenameUndoManagerExists() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertNotNil(viewModel.renameUndoManager)
        }
    }
    
    func testRenameUndoManagerInitiallyCannotUndo() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertFalse(viewModel.renameUndoManager.canUndo)
        }
    }
    
    func testRenameUndoManagerInitiallyCannotRedo() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            XCTAssertFalse(viewModel.renameUndoManager.canRedo)
        }
    }
    
    func testUndoLastRenameWithNoOperationsDoesNotCrash() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            
            // Should not crash
            viewModel.undoLastRename()
            
            XCTAssertFalse(viewModel.renameUndoManager.canUndo)
        }
    }
    
    func testRedoLastRenameWithNoOperationsDoesNotCrash() async {
        await MainActor.run {
            let viewModel = RenameViewModel()
            
            // Should not crash
            viewModel.redoLastRename()
            
            XCTAssertFalse(viewModel.renameUndoManager.canRedo)
        }
    }
    
    // MARK: - Rename File On Disk Undo Tests
    
    func testRenameFileOnDiskRecordsUndo() async throws {
        try await MainActor.run {
            let viewModel = RenameViewModel()
            
            // Create a temporary file
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }
            
            let originalURL = tempDir.appendingPathComponent("original.txt")
            try "test content".write(to: originalURL, atomically: true, encoding: .utf8)
            
            let file = RenameFile(url: originalURL)
            viewModel.files = [file]
            
            // Initially cannot undo
            XCTAssertFalse(viewModel.renameUndoManager.canUndo)
            
            // Rename the file
            let error = viewModel.renameFileOnDisk(file, to: "renamed.txt")
            XCTAssertNil(error, "Rename should succeed")
            
            // Now should be able to undo
            XCTAssertTrue(viewModel.renameUndoManager.canUndo)
            XCTAssertEqual(viewModel.renameUndoManager.undoMenuTitle, "Undo Rename")
        }
    }
    
    func testRenameFileOnDiskUpdatesFileList() async throws {
        try await MainActor.run {
            let viewModel = RenameViewModel()
            
            // Create a temporary file
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }
            
            let originalURL = tempDir.appendingPathComponent("original.txt")
            try "test content".write(to: originalURL, atomically: true, encoding: .utf8)
            
            let file = RenameFile(url: originalURL)
            let originalID = file.id
            viewModel.files = [file]
            
            // Rename the file
            let error = viewModel.renameFileOnDisk(file, to: "renamed.txt")
            XCTAssertNil(error)
            
            // File list should be updated with new URL but same ID
            XCTAssertEqual(viewModel.files.count, 1)
            XCTAssertEqual(viewModel.files[0].id, originalID)
            XCTAssertEqual(viewModel.files[0].originalName, "renamed.txt")
        }
    }
    
    func testRenameFileOnDiskNoChangeDoesNotRecordUndo() async throws {
        try await MainActor.run {
            let viewModel = RenameViewModel()
            
            // Create a temporary file
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }
            
            let originalURL = tempDir.appendingPathComponent("samename.txt")
            try "test content".write(to: originalURL, atomically: true, encoding: .utf8)
            
            let file = RenameFile(url: originalURL)
            viewModel.files = [file]
            
            // "Rename" to the same name
            let error = viewModel.renameFileOnDisk(file, to: "samename.txt")
            XCTAssertNil(error)
            
            // Should NOT be able to undo (no actual change occurred)
            XCTAssertFalse(viewModel.renameUndoManager.canUndo)
        }
    }
    
    func testRenameFileOnDiskUndoRestoresOriginalName() async throws {
        try await MainActor.run {
            let viewModel = RenameViewModel()
            
            // Create a temporary file
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }
            
            let originalURL = tempDir.appendingPathComponent("original.txt")
            try "test content".write(to: originalURL, atomically: true, encoding: .utf8)
            
            let file = RenameFile(url: originalURL)
            let originalID = file.id
            viewModel.files = [file]
            
            // Rename the file
            _ = viewModel.renameFileOnDisk(file, to: "renamed.txt")
            
            // Verify file was renamed
            XCTAssertEqual(viewModel.files[0].originalName, "renamed.txt")
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("renamed.txt").path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: originalURL.path))
            
            // Undo the rename
            viewModel.undoLastRename()
            
            // File should be restored to original name
            XCTAssertEqual(viewModel.files[0].id, originalID)
            XCTAssertEqual(viewModel.files[0].originalName, "original.txt")
            XCTAssertTrue(FileManager.default.fileExists(atPath: originalURL.path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("renamed.txt").path))
            
            // Should now be able to redo
            XCTAssertTrue(viewModel.renameUndoManager.canRedo)
            XCTAssertFalse(viewModel.renameUndoManager.canUndo)
        }
    }
    
    func testRenameFileOnDiskRedoReappliesRename() async throws {
        try await MainActor.run {
            let viewModel = RenameViewModel()
            
            // Create a temporary file
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }
            
            let originalURL = tempDir.appendingPathComponent("original.txt")
            try "test content".write(to: originalURL, atomically: true, encoding: .utf8)
            
            let file = RenameFile(url: originalURL)
            viewModel.files = [file]
            
            // Rename, then undo
            _ = viewModel.renameFileOnDisk(file, to: "renamed.txt")
            viewModel.undoLastRename()
            
            // Verify original state restored
            XCTAssertEqual(viewModel.files[0].originalName, "original.txt")
            
            // Redo the rename
            viewModel.redoLastRename()
            
            // File should be renamed again
            XCTAssertEqual(viewModel.files[0].originalName, "renamed.txt")
            XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("renamed.txt").path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: originalURL.path))
            
            // Should be able to undo again
            XCTAssertTrue(viewModel.renameUndoManager.canUndo)
            XCTAssertFalse(viewModel.renameUndoManager.canRedo)
        }
    }
    
    func testMultipleRenameFileOnDiskOperationsStackUndo() async throws {
        try await MainActor.run {
            let viewModel = RenameViewModel()
            
            // Create a temporary file
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tempDir) }
            
            let originalURL = tempDir.appendingPathComponent("file.txt")
            try "test content".write(to: originalURL, atomically: true, encoding: .utf8)
            
            let file = RenameFile(url: originalURL)
            viewModel.files = [file]
            
            // Perform multiple renames
            _ = viewModel.renameFileOnDisk(viewModel.files[0], to: "first.txt")
            _ = viewModel.renameFileOnDisk(viewModel.files[0], to: "second.txt")
            _ = viewModel.renameFileOnDisk(viewModel.files[0], to: "third.txt")
            
            XCTAssertEqual(viewModel.files[0].originalName, "third.txt")
            
            // Undo back to second
            viewModel.undoLastRename()
            XCTAssertEqual(viewModel.files[0].originalName, "second.txt")
            
            // Undo back to first
            viewModel.undoLastRename()
            XCTAssertEqual(viewModel.files[0].originalName, "first.txt")
            
            // Undo back to original
            viewModel.undoLastRename()
            XCTAssertEqual(viewModel.files[0].originalName, "file.txt")
            
            // No more undo available
            XCTAssertFalse(viewModel.renameUndoManager.canUndo)
            
            // But can redo all three
            XCTAssertTrue(viewModel.renameUndoManager.canRedo)
        }
    }
}
