// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import Foundation

enum DateTimeSource: String, CaseIterable, Identifiable {
    case currentDate = "Current Date"
    case customText = "Custom Text"

    var id: String { rawValue }
}

enum DateTimePosition: String, CaseIterable, Identifiable {
    case prefix = "Before Name"
    case suffix = "After Name"
    case atPosition = "At Position"
    case replace = "Replace Name"

    var id: String { rawValue }
}

struct DateTimeAction: RenameAction {
    var source: DateTimeSource = .currentDate
    var position: DateTimePosition = .prefix
    var insertPosition: Int = 0
    var format: String = "yyyy-MM-dd"
    var customText: String = ""
    var separator: String = "_"
    var prefixSeparator: String = ""
    var suffixSeparator: String = ""

    func applyWithTracking(to filename: String, at index: Int, totalCount: Int, applyToExtension: Bool) -> RenamePreviewResult {
        let url = URL(fileURLWithPath: filename)
        let ext = url.pathExtension
        
        // If applyToExtension is true, work on full filename; otherwise just the name
        let workingName: String
        if applyToExtension || ext.isEmpty {
            workingName = url.lastPathComponent
        } else {
            workingName = url.deletingPathExtension().lastPathComponent
        }

        let dateString: String
        switch source {
        case .currentDate:
            let formatter = DateFormatter()
            formatter.dateFormat = format
            dateString = formatter.string(from: Date())
        case .customText:
            dateString = customText
        }

        let newName: String
        var changedRange: Range<Int>
        var deletedRange: Range<Int>?
        
        switch position {
        case .prefix:
            let inserted = "\(dateString)\(separator)"
            newName = "\(inserted)\(workingName)"
            changedRange = 0..<inserted.count
            
        case .suffix:
            let inserted = "\(separator)\(dateString)"
            newName = "\(workingName)\(inserted)"
            changedRange = workingName.count..<(workingName.count + inserted.count)
            
        case .atPosition:
            let result = insertAtPositionWithTracking(dateString, into: workingName)
            newName = result.newName
            changedRange = result.changedRange
            
        case .replace:
            newName = dateString
            changedRange = 0..<dateString.count
            deletedRange = 0..<workingName.count
        }

        // If we worked on full filename, return as-is; otherwise reattach extension
        let finalName: String
        if applyToExtension || ext.isEmpty {
            finalName = newName
        } else {
            finalName = "\(newName).\(ext)"
        }
        
        return RenamePreviewResult(newName: finalName, changedRange: changedRange, deletedRange: deletedRange)
    }

    /// Inserts the date/time value at the specified position in the name with tracking
    private func insertAtPositionWithTracking(_ value: String, into name: String) -> (newName: String, changedRange: Range<Int>) {
        // Clamp position to valid range
        let pos = max(0, min(insertPosition, name.count))

        // Build the insertion string with prefix and suffix separators
        let insertionString = "\(prefixSeparator)\(value)\(suffixSeparator)"

        let index = name.index(name.startIndex, offsetBy: pos)
        var result = name
        result.insert(contentsOf: insertionString, at: index)
        
        return (result, pos..<(pos + insertionString.count))
    }
}
