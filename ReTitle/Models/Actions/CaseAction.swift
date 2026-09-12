import Foundation

enum CaseType: String, CaseIterable, Identifiable {
    case upper = "UPPERCASE"
    case lower = "lowercase"
    case title = "Title Case"
    case sentence = "Sentence case"

    var id: String { rawValue }
}

struct CaseAction: RenameAction {
    var caseType: CaseType = .upper

    func applyWithTracking(to filename: String, at index: Int, totalCount: Int, applyToExtension: Bool) -> RenamePreviewResult {
        let url = URL(fileURLWithPath: filename)
        let name = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension

        let transformedName = transformCase(name)
        let finalExtension = applyToExtension ? transformCase(ext) : ext

        // Find character-level differences and merge into ranges
        var changedRanges = findChangedRanges(original: name, transformed: transformedName)
        
        // Add extension changes if applicable
        if applyToExtension && !ext.isEmpty {
            let extChanges = findChangedRanges(original: ext, transformed: finalExtension)
            let extOffset = transformedName.count + 1 // +1 for the dot
            for range in extChanges {
                changedRanges.append((range.lowerBound + extOffset)..<(range.upperBound + extOffset))
            }
        }

        let finalName: String
        if finalExtension.isEmpty {
            finalName = transformedName
        } else {
            finalName = "\(transformedName).\(finalExtension)"
        }
        
        // For case changes, the original and new have same length, so no deletions
        return RenamePreviewResult(newName: finalName, changedRanges: changedRanges, deletedRanges: [])
    }

    private func transformCase(_ text: String) -> String {
        switch caseType {
        case .upper:
            return text.uppercased()
        case .lower:
            return text.lowercased()
        case .title:
            return text.capitalized
        case .sentence:
            guard let first = text.first else { return text }
            return first.uppercased() + text.dropFirst().lowercased()
        }
    }
    
    /// Finds ranges of characters that differ between original and transformed strings
    /// Merges adjacent changed characters into single ranges
    private func findChangedRanges(original: String, transformed: String) -> [Range<Int>] {
        guard original.count == transformed.count else {
            // If lengths differ (shouldn't happen for case changes), highlight everything
            return transformed.isEmpty ? [] : [0..<transformed.count]
        }
        
        var changedIndices: [Int] = []
        let origChars = Array(original)
        let transChars = Array(transformed)
        
        for i in 0..<origChars.count {
            if origChars[i] != transChars[i] {
                changedIndices.append(i)
            }
        }
        
        // Merge adjacent indices into ranges
        return mergeIndicesToRanges(changedIndices)
    }
    
    /// Merges a list of indices into contiguous ranges
    /// e.g., [0, 1, 2, 5, 6] becomes [0..<3, 5..<7]
    private func mergeIndicesToRanges(_ indices: [Int]) -> [Range<Int>] {
        guard !indices.isEmpty else { return [] }
        
        var result: [Range<Int>] = []
        var rangeStart = indices[0]
        var rangeEnd = indices[0]
        
        for i in 1..<indices.count {
            if indices[i] == rangeEnd + 1 {
                // Extend current range
                rangeEnd = indices[i]
            } else {
                // Save current range and start new one
                result.append(rangeStart..<(rangeEnd + 1))
                rangeStart = indices[i]
                rangeEnd = indices[i]
            }
        }
        
        // Don't forget the last range
        result.append(rangeStart..<(rangeEnd + 1))
        
        return result
    }
}
