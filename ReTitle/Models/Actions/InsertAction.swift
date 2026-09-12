import Foundation

enum InsertMode: String, CaseIterable, Identifiable {
    case insert = "Insert"
    case overwrite = "Overwrite"

    var id: String { rawValue }
}

enum InsertPosition: String, CaseIterable, Identifiable {
    case start = "At Start"
    case end = "At End"
    case position = "At Position"

    var id: String { rawValue }
}

struct InsertAction: RenameAction {
    var mode: InsertMode = .insert
    var position: InsertPosition = .start
    var positionIndex: Int = 0
    var text: String = ""
    var overwriteLength: Int = 0

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

        guard !text.isEmpty else {
            return .unchanged(filename)
        }

        let insertIndex: Int
        switch position {
        case .start:
            insertIndex = 0
        case .end:
            insertIndex = workingName.count
        case .position:
            insertIndex = min(max(0, positionIndex), workingName.count)
        }

        var newName = workingName
        let stringIndex = workingName.index(workingName.startIndex, offsetBy: insertIndex)
        
        var changedRange: Range<Int>
        var deletedRange: Range<Int>?

        switch mode {
        case .insert:
            newName.insert(contentsOf: text, at: stringIndex)
            changedRange = insertIndex..<(insertIndex + text.count)
            // No deletion for pure insert
            
        case .overwrite:
            let endOffset = min(insertIndex + overwriteLength, workingName.count)
            let endIndex = workingName.index(workingName.startIndex, offsetBy: endOffset)
            
            // Track what's being deleted
            if endOffset > insertIndex {
                deletedRange = insertIndex..<endOffset
            }
            
            newName.replaceSubrange(stringIndex..<endIndex, with: text)
            changedRange = insertIndex..<(insertIndex + text.count)
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
}
