// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import ReTitle

final class RenameUndoManagerTests: XCTestCase {
    
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        // Create a temporary directory for file operations
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDirectory)
        tempDirectory = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateCannotUndo() {
        let undoManager = RenameUndoManager()
        XCTAssertFalse(undoManager.canUndo)
    }
    
    func testInitialStateCannotRedo() {
        let undoManager = RenameUndoManager()
        XCTAssertFalse(undoManager.canRedo)
    }
    
    func testInitialUndoMenuTitle() {
        let undoManager = RenameUndoManager()
        XCTAssertEqual(undoManager.undoMenuTitle, "Undo")
    }
    
    func testInitialRedoMenuTitle() {
        let undoManager = RenameUndoManager()
        XCTAssertEqual(undoManager.redoMenuTitle, "Redo")
    }
    
    // MARK: - Record Rename Tests
    
    func testRecordRenameEnablesUndo() {
        let oldURL = tempDirectory.appendingPathComponent("old.txt")
        let newURL = tempDirectory.appendingPathComponent("new.txt")
        
        let undoManager = RenameUndoManager()
        undoManager.recordRename(mappings: [(oldURL: oldURL, newURL: newURL)])
        
        XCTAssertTrue(undoManager.canUndo)
    }
    
    func testRecordEmptyMappingsDoesNotEnableUndo() {
        let undoManager = RenameUndoManager()
        undoManager.recordRename(mappings: [])
        
        XCTAssertFalse(undoManager.canUndo)
    }
    
    func testRecordRenameClearsRedoStack() throws {
        // Create test files
        let file1 = tempDirectory.appendingPathComponent("file1.txt")
        let file1Renamed = tempDirectory.appendingPathComponent("file1_renamed.txt")
        try "test".write(to: file1, atomically: true, encoding: .utf8)
        try FileManager.default.moveItem(at: file1, to: file1Renamed)
        
        let file2 = tempDirectory.appendingPathComponent("file2.txt")
        let file2Renamed = tempDirectory.appendingPathComponent("file2_renamed.txt")
        try "test2".write(to: file2, atomically: true, encoding: .utf8)
        try FileManager.default.moveItem(at: file2, to: file2Renamed)
        
        let undoManager = RenameUndoManager()
        
        // Record first rename and undo
        undoManager.recordRename(mappings: [(oldURL: file1, newURL: file1Renamed)])
        _ = undoManager.undo()
        
        XCTAssertTrue(undoManager.canRedo, "Should be able to redo after undo")
        
        // Record a new rename - should clear redo stack
        undoManager.recordRename(mappings: [(oldURL: file2, newURL: file2Renamed)])
        
        XCTAssertFalse(undoManager.canRedo, "Redo stack should be cleared after new operation")
    }
    
    // MARK: - Menu Title Tests
    
    func testUndoMenuTitleSingleFile() {
        let oldURL = tempDirectory.appendingPathComponent("old.txt")
        let newURL = tempDirectory.appendingPathComponent("new.txt")
        
        let undoManager = RenameUndoManager()
        undoManager.recordRename(mappings: [(oldURL: oldURL, newURL: newURL)])
        
        XCTAssertEqual(undoManager.undoMenuTitle, "Undo Rename")
    }
    
    func testUndoMenuTitleMultipleFiles() {
        let mappings = [
            (oldURL: tempDirectory.appendingPathComponent("old1.txt"),
             newURL: tempDirectory.appendingPathComponent("new1.txt")),
            (oldURL: tempDirectory.appendingPathComponent("old2.txt"),
             newURL: tempDirectory.appendingPathComponent("new2.txt")),
            (oldURL: tempDirectory.appendingPathComponent("old3.txt"),
             newURL: tempDirectory.appendingPathComponent("new3.txt"))
        ]
        
        let undoManager = RenameUndoManager()
        undoManager.recordRename(mappings: mappings)
        
        XCTAssertEqual(undoManager.undoMenuTitle, "Undo Rename 3 Files")
    }
    
    // MARK: - Undo Tests
    
    func testUndoReversesRename() throws {
        // Create and rename a file
        let originalURL = tempDirectory.appendingPathComponent("original.txt")
        let renamedURL = tempDirectory.appendingPathComponent("renamed.txt")
        try "test content".write(to: originalURL, atomically: true, encoding: .utf8)
        try FileManager.default.moveItem(at: originalURL, to: renamedURL)
        
        let undoManager = RenameUndoManager()
        
        // Record the rename
        undoManager.recordRename(mappings: [(oldURL: originalURL, newURL: renamedURL)])
        
        // Undo
        let result = undoManager.undo()
        
        switch result {
        case .success(let mappings):
            XCTAssertEqual(mappings.count, 1)
            XCTAssertEqual(mappings[0].currentURL, renamedURL)
            XCTAssertEqual(mappings[0].targetURL, originalURL)
            
            // Verify file was moved back
            XCTAssertTrue(FileManager.default.fileExists(atPath: originalURL.path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: renamedURL.path))
            
        case .failure(let error):
            XCTFail("Undo should succeed: \(error)")
        }
    }
    
    func testUndoEnablesRedo() throws {
        let originalURL = tempDirectory.appendingPathComponent("original.txt")
        let renamedURL = tempDirectory.appendingPathComponent("renamed.txt")
        try "test".write(to: originalURL, atomically: true, encoding: .utf8)
        try FileManager.default.moveItem(at: originalURL, to: renamedURL)
        
        let undoManager = RenameUndoManager()
        undoManager.recordRename(mappings: [(oldURL: originalURL, newURL: renamedURL)])
        _ = undoManager.undo()
        
        XCTAssertTrue(undoManager.canRedo)
    }
    
    func testUndoFailsWhenFileDeleted() {
        let originalURL = tempDirectory.appendingPathComponent("original.txt")
        let renamedURL = tempDirectory.appendingPathComponent("renamed.txt")
        
        let undoManager = RenameUndoManager()
        
        // Record a rename without actually having the file
        undoManager.recordRename(mappings: [(oldURL: originalURL, newURL: renamedURL)])
        
        let result = undoManager.undo()
        
        switch result {
        case .success:
            XCTFail("Undo should fail when file doesn't exist")
        case .failure:
            // Expected
            break
        }
    }
    
    func testUndoWithNoOperations() {
        let undoManager = RenameUndoManager()
        let result = undoManager.undo()
        
        switch result {
        case .success:
            XCTFail("Undo should fail with no operations")
        case .failure(let error):
            XCTAssertEqual(error, .noOperationsToUndo)
        }
    }
    
    // MARK: - Redo Tests
    
    func testRedoReappliesRename() throws {
        // Create, rename, record, and undo
        let originalURL = tempDirectory.appendingPathComponent("original.txt")
        let renamedURL = tempDirectory.appendingPathComponent("renamed.txt")
        try "test content".write(to: originalURL, atomically: true, encoding: .utf8)
        try FileManager.default.moveItem(at: originalURL, to: renamedURL)
        
        let undoManager = RenameUndoManager()
        undoManager.recordRename(mappings: [(oldURL: originalURL, newURL: renamedURL)])
        _ = undoManager.undo()
        
        // Now redo
        let result = undoManager.redo()
        
        switch result {
        case .success(let mappings):
            XCTAssertEqual(mappings.count, 1)
            XCTAssertEqual(mappings[0].currentURL, originalURL)
            XCTAssertEqual(mappings[0].targetURL, renamedURL)
            
            // Verify file was renamed again
            XCTAssertFalse(FileManager.default.fileExists(atPath: originalURL.path))
            XCTAssertTrue(FileManager.default.fileExists(atPath: renamedURL.path))
            
        case .failure(let error):
            XCTFail("Redo should succeed: \(error)")
        }
    }
    
    func testRedoEnablesUndoAgain() throws {
        let originalURL = tempDirectory.appendingPathComponent("original.txt")
        let renamedURL = tempDirectory.appendingPathComponent("renamed.txt")
        try "test".write(to: originalURL, atomically: true, encoding: .utf8)
        try FileManager.default.moveItem(at: originalURL, to: renamedURL)
        
        let undoManager = RenameUndoManager()
        undoManager.recordRename(mappings: [(oldURL: originalURL, newURL: renamedURL)])
        _ = undoManager.undo()
        
        XCTAssertFalse(undoManager.canUndo, "Cannot undo after undoing single operation")
        
        _ = undoManager.redo()
        
        XCTAssertTrue(undoManager.canUndo, "Can undo after redo")
    }
    
    func testRedoWithNoOperations() {
        let undoManager = RenameUndoManager()
        let result = undoManager.redo()
        
        switch result {
        case .success:
            XCTFail("Redo should fail with no operations")
        case .failure(let error):
            XCTAssertEqual(error, .noOperationsToRedo)
        }
    }
    
    // MARK: - Stack Limit Tests
    
    func testStackLimitsTo25Operations() {
        let undoManager = RenameUndoManager()
        
        // Record 30 operations
        for i in 0..<30 {
            let oldURL = tempDirectory.appendingPathComponent("old\(i).txt")
            let newURL = tempDirectory.appendingPathComponent("new\(i).txt")
            undoManager.recordRename(mappings: [(oldURL: oldURL, newURL: newURL)])
        }
        
        // Should still be able to undo (stack not empty)
        XCTAssertTrue(undoManager.canUndo)
        
        // Count how many undos we can do
        var undoCount = 0
        while undoManager.canUndo {
            _ = undoManager.undo()
            undoCount += 1
        }
        
        // Should be limited to 25
        XCTAssertEqual(undoCount, 25, "Stack should be limited to 25 operations")
    }
    
    // MARK: - Clear History Tests
    
    func testClearHistoryRemovesAllOperations() {
        let oldURL = tempDirectory.appendingPathComponent("old.txt")
        let newURL = tempDirectory.appendingPathComponent("new.txt")
        
        let undoManager = RenameUndoManager()
        undoManager.recordRename(mappings: [(oldURL: oldURL, newURL: newURL)])
        XCTAssertTrue(undoManager.canUndo)
        
        undoManager.clearHistory()
        
        XCTAssertFalse(undoManager.canUndo)
        XCTAssertFalse(undoManager.canRedo)
    }
    
    // MARK: - Multiple File Tests
    
    func testUndoMultipleFilesInSingleOperation() throws {
        // Create and rename multiple files
        var mappings: [(oldURL: URL, newURL: URL)] = []
        
        for i in 1...3 {
            let original = tempDirectory.appendingPathComponent("file\(i).txt")
            let renamed = tempDirectory.appendingPathComponent("renamed\(i).txt")
            try "content \(i)".write(to: original, atomically: true, encoding: .utf8)
            try FileManager.default.moveItem(at: original, to: renamed)
            mappings.append((oldURL: original, newURL: renamed))
        }
        
        let tempDir = tempDirectory!
        
        let undoManager = RenameUndoManager()
        undoManager.recordRename(mappings: mappings)
        
        // Undo all at once
        let result = undoManager.undo()
        
        switch result {
        case .success(let undoMappings):
            XCTAssertEqual(undoMappings.count, 3)
            
            // Verify all files were restored
            for i in 1...3 {
                let original = tempDir.appendingPathComponent("file\(i).txt")
                let renamed = tempDir.appendingPathComponent("renamed\(i).txt")
                XCTAssertTrue(FileManager.default.fileExists(atPath: original.path), "file\(i).txt should exist")
                XCTAssertFalse(FileManager.default.fileExists(atPath: renamed.path), "renamed\(i).txt should not exist")
            }
            
        case .failure(let error):
            XCTFail("Undo should succeed: \(error)")
        }
    }
    
    // MARK: - Redo Menu Title Tests
    
    func testRedoMenuTitleSingleFile() throws {
        let originalURL = tempDirectory.appendingPathComponent("original.txt")
        let renamedURL = tempDirectory.appendingPathComponent("renamed.txt")
        try "test".write(to: originalURL, atomically: true, encoding: .utf8)
        try FileManager.default.moveItem(at: originalURL, to: renamedURL)
        
        let undoManager = RenameUndoManager()
        undoManager.recordRename(mappings: [(oldURL: originalURL, newURL: renamedURL)])
        _ = undoManager.undo()
        
        XCTAssertEqual(undoManager.redoMenuTitle, "Redo Rename")
    }
    
    func testRedoMenuTitleMultipleFiles() throws {
        var mappings: [(oldURL: URL, newURL: URL)] = []
        for i in 1...3 {
            let original = tempDirectory.appendingPathComponent("file\(i).txt")
            let renamed = tempDirectory.appendingPathComponent("renamed\(i).txt")
            try "content".write(to: original, atomically: true, encoding: .utf8)
            try FileManager.default.moveItem(at: original, to: renamed)
            mappings.append((oldURL: original, newURL: renamed))
        }
        
        let undoManager = RenameUndoManager()
        undoManager.recordRename(mappings: mappings)
        _ = undoManager.undo()
        
        XCTAssertEqual(undoManager.redoMenuTitle, "Redo Rename 3 Files")
    }
}
