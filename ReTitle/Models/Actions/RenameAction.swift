// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import Foundation

// MARK: - Rename Preview Result

/// Result of applying a rename action, including change tracking for highlighting
struct RenamePreviewResult: Sendable {
    /// The new filename after applying the action
    let newName: String
    
    /// Ranges in the new name that were changed/inserted (for highlighting in blue)
    /// These are character index ranges in `newName`
    let changedRanges: [Range<Int>]
    
    /// Ranges in the original name that were deleted/replaced (for highlighting in red)
    /// These are character index ranges in the original filename
    let deletedRanges: [Range<Int>]
    
    /// Convenience initializer for simple cases with a single changed range
    init(newName: String, changedRange: Range<Int>? = nil, deletedRange: Range<Int>? = nil) {
        self.newName = newName
        self.changedRanges = changedRange.map { [$0] } ?? []
        self.deletedRanges = deletedRange.map { [$0] } ?? []
    }
    
    /// Initializer for multiple ranges (e.g., replace all)
    init(newName: String, changedRanges: [Range<Int>], deletedRanges: [Range<Int>]) {
        self.newName = newName
        self.changedRanges = changedRanges
        self.deletedRanges = deletedRanges
    }
    
    /// Convenience initializer for when only the name changes (no specific range tracking)
    static func unchanged(_ name: String) -> RenamePreviewResult {
        RenamePreviewResult(newName: name, changedRanges: [], deletedRanges: [])
    }
    
    /// Convenience initializer for complete replacement (entire new name is highlighted)
    static func replaced(newName: String, originalLength: Int) -> RenamePreviewResult {
        RenamePreviewResult(
            newName: newName,
            changedRanges: newName.isEmpty ? [] : [0..<newName.count],
            deletedRanges: originalLength > 0 ? [0..<originalLength] : []
        )
    }
}

// MARK: - Rename Action Protocol

protocol RenameAction {
    /// Applies the rename action and returns detailed result with change tracking
    func applyWithTracking(to filename: String, at index: Int, totalCount: Int, applyToExtension: Bool) -> RenamePreviewResult
}

extension RenameAction {
    /// Convenience method that returns just the new name (for backward compatibility)
    func apply(to filename: String, at index: Int, totalCount: Int, applyToExtension: Bool) -> String {
        applyWithTracking(to: filename, at: index, totalCount: totalCount, applyToExtension: applyToExtension).newName
    }
}

// MARK: - Action Type Enum

enum ActionType: String, CaseIterable, Identifiable, Sendable {
    case searchReplace = "Replace"
    case insert = "Insert"
    case remove = "Remove"
    case caseChange = "Case"
    case numbering = "Number"
    case dateTime = "Date/Time"
    case exif = "Metadata"

    var id: String { rawValue }
}
