import Foundation

enum NumberPosition: String, CaseIterable, Identifiable {
    case prefix = "Before Name"
    case suffix = "After Name"
    case atPosition = "At Position"
    case replace = "Replace Name"

    var id: String { rawValue }
}

enum NumberPadding: String, CaseIterable, Identifiable {
    case none = "No Padding"
    case auto = "Auto (based on count)"
    case fixed = "Fixed Width"

    var id: String { rawValue }
}

struct NumberingAction: RenameAction {
    var startNumber: Int = 1
    var increment: Int = 1
    var position: NumberPosition = .prefix
    var insertPosition: Int = 0
    var padding: NumberPadding = .auto
    var fixedWidth: Int = 3
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

        let number = startNumber + (index * increment)
        let numberString = formatNumber(number, totalCount: totalCount)

        let newName: String
        var changedRange: Range<Int>
        var deletedRange: Range<Int>?
        
        switch position {
        case .prefix:
            let inserted = "\(numberString)\(separator)"
            newName = "\(inserted)\(workingName)"
            changedRange = 0..<inserted.count
            
        case .suffix:
            let inserted = "\(separator)\(numberString)"
            newName = "\(workingName)\(inserted)"
            changedRange = workingName.count..<(workingName.count + inserted.count)
            
        case .atPosition:
            let result = insertAtPositionWithTracking(numberString, into: workingName)
            newName = result.newName
            changedRange = result.changedRange
            
        case .replace:
            newName = numberString
            changedRange = 0..<numberString.count
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

    /// Inserts the number at the specified position in the name with tracking
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

    private func formatNumber(_ number: Int, totalCount: Int) -> String {
        switch padding {
        case .none:
            return String(number)
        case .auto:
            let maxNumber = startNumber + ((totalCount - 1) * increment)
            let width = String(maxNumber).count
            return String(format: "%0\(width)d", number)
        case .fixed:
            return String(format: "%0\(fixedWidth)d", number)
        }
    }
}
