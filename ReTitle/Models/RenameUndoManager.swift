// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import Foundation

/// Manages undo/redo operations for file renames
@Observable
final class RenameUndoManager {
    
    // MARK: - Types
    
    /// Represents a single file rename mapping
    struct RenameMapping {
        let oldURL: URL
        let newURL: URL
    }
    
    /// Represents a batch of rename operations that can be undone/redone together
    struct RenameOperation {
        let mappings: [RenameMapping]
        let timestamp: Date
        
        init(mappings: [RenameMapping], timestamp: Date = Date()) {
            self.mappings = mappings
            self.timestamp = timestamp
        }
    }
    
    // MARK: - Properties
    
    /// Maximum number of operations to keep in the undo stack
    private let maxStackSize = 25
    
    /// Stack of operations that can be undone
    private var undoStack: [RenameOperation] = []
    
    /// Stack of operations that can be redone
    private var redoStack: [RenameOperation] = []
    
    /// Whether there are operations that can be undone
    var canUndo: Bool { !undoStack.isEmpty }
    
    /// Whether there are operations that can be redone
    var canRedo: Bool { !redoStack.isEmpty }
    
    /// Description of the next undo operation (for menu item)
    var undoMenuTitle: String {
        guard canUndo else { return "Undo" }
        let count = undoStack.last?.mappings.count ?? 0
        return count == 1 ? "Undo Rename" : "Undo Rename \(count) Files"
    }
    
    /// Description of the next redo operation (for menu item)
    var redoMenuTitle: String {
        guard canRedo else { return "Redo" }
        let count = redoStack.last?.mappings.count ?? 0
        return count == 1 ? "Redo Rename" : "Redo Rename \(count) Files"
    }
    
    // MARK: - Public Methods
    
    /// Records a rename operation for potential undo
    /// - Parameter mappings: Array of (oldURL, newURL) pairs for each renamed file
    func recordRename(mappings: [(oldURL: URL, newURL: URL)]) {
        guard !mappings.isEmpty else { return }
        
        let renameMappings = mappings.map { RenameMapping(oldURL: $0.oldURL, newURL: $0.newURL) }
        let operation = RenameOperation(mappings: renameMappings)
        
        undoStack.append(operation)
        
        // Trim stack if it exceeds max size
        if undoStack.count > maxStackSize {
            undoStack.removeFirst(undoStack.count - maxStackSize)
        }
        
        // Clear redo stack when a new operation is recorded
        redoStack.removeAll()
    }
    
    /// Performs undo of the last rename operation
    /// - Returns: Result containing array of (currentURL, targetURL) pairs to reverse, or an error
    func undo() -> Result<[(currentURL: URL, targetURL: URL)], UndoError> {
        guard let operation = undoStack.popLast() else {
            return .failure(.noOperationsToUndo)
        }
        
        let fileManager = FileManager.default
        var reverseMappings: [(currentURL: URL, targetURL: URL)] = []
        var successfulMappings: [RenameMapping] = []
        var errors: [String] = []
        
        // Reverse each rename: newURL -> oldURL
        for mapping in operation.mappings {
            // Check if the file still exists at newURL
            if fileManager.fileExists(atPath: mapping.newURL.path) {
                // Check if target location is available
                if fileManager.fileExists(atPath: mapping.oldURL.path) {
                    errors.append("Cannot restore \"\(mapping.newURL.lastPathComponent)\" - file already exists at original location")
                } else {
                    do {
                        try fileManager.moveItem(at: mapping.newURL, to: mapping.oldURL)
                        reverseMappings.append((currentURL: mapping.newURL, targetURL: mapping.oldURL))
                        successfulMappings.append(mapping)
                    } catch {
                        errors.append("Failed to restore \"\(mapping.newURL.lastPathComponent)\": \(error.localizedDescription)")
                    }
                }
            } else {
                errors.append("Cannot undo - file \"\(mapping.newURL.lastPathComponent)\" no longer exists")
            }
        }
        
        // If we successfully undid any renames, push to redo stack
        if !successfulMappings.isEmpty {
            let redoOperation = RenameOperation(mappings: successfulMappings, timestamp: operation.timestamp)
            redoStack.append(redoOperation)
        }
        
        if errors.isEmpty {
            return .success(reverseMappings)
        } else if !reverseMappings.isEmpty {
            // Partial success - some files were restored
            return .success(reverseMappings)
        } else {
            return .failure(.operationFailed(errors.joined(separator: "\n")))
        }
    }
    
    /// Performs redo of the last undone operation
    /// - Returns: Result containing array of (currentURL, targetURL) pairs to re-apply, or an error
    func redo() -> Result<[(currentURL: URL, targetURL: URL)], UndoError> {
        guard let operation = redoStack.popLast() else {
            return .failure(.noOperationsToRedo)
        }
        
        let fileManager = FileManager.default
        var redoMappings: [(currentURL: URL, targetURL: URL)] = []
        var successfulMappings: [RenameMapping] = []
        var errors: [String] = []
        
        // Re-apply each rename: oldURL -> newURL
        for mapping in operation.mappings {
            // Check if the file exists at oldURL (where we put it back during undo)
            if fileManager.fileExists(atPath: mapping.oldURL.path) {
                // Check if target location is available
                if fileManager.fileExists(atPath: mapping.newURL.path) {
                    errors.append("Cannot redo rename to \"\(mapping.newURL.lastPathComponent)\" - file already exists")
                } else {
                    do {
                        try fileManager.moveItem(at: mapping.oldURL, to: mapping.newURL)
                        redoMappings.append((currentURL: mapping.oldURL, targetURL: mapping.newURL))
                        successfulMappings.append(mapping)
                    } catch {
                        errors.append("Failed to redo rename \"\(mapping.oldURL.lastPathComponent)\": \(error.localizedDescription)")
                    }
                }
            } else {
                errors.append("Cannot redo - file \"\(mapping.oldURL.lastPathComponent)\" no longer exists")
            }
        }
        
        // If we successfully redid any renames, push back to undo stack
        if !successfulMappings.isEmpty {
            let undoOperation = RenameOperation(mappings: successfulMappings, timestamp: operation.timestamp)
            undoStack.append(undoOperation)
        }
        
        if errors.isEmpty {
            return .success(redoMappings)
        } else if !redoMappings.isEmpty {
            // Partial success
            return .success(redoMappings)
        } else {
            return .failure(.operationFailed(errors.joined(separator: "\n")))
        }
    }
    
    /// Clears all undo/redo history
    func clearHistory() {
        undoStack.removeAll()
        redoStack.removeAll()
    }
    
    // MARK: - Errors
    
    enum UndoError: Error, LocalizedError, Equatable {
        case noOperationsToUndo
        case noOperationsToRedo
        case operationFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .noOperationsToUndo:
                return "No operations to undo"
            case .noOperationsToRedo:
                return "No operations to redo"
            case .operationFailed(let message):
                return message
            }
        }
    }
}
