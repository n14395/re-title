// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import Foundation

enum RemoveMode: String, CaseIterable, Identifiable {
    case firstN = "First N Characters"
    case lastN = "Last N Characters"
    case range = "Character Range"
    case specific = "Specific Characters"

    var id: String { rawValue }
}

struct RemoveAction: RenameAction {
    var mode: RemoveMode = .firstN
    var count: Int = 0
    var rangeStart: Int = 0
    var rangeEnd: Int = 0
    var specificChars: String = ""

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

        let newName: String
        var deletedRanges: [Range<Int>] = []
        
        switch mode {
        case .firstN:
            let actualCount = min(count, workingName.count)
            if actualCount > 0 {
                deletedRanges.append(0..<actualCount)
            }
            if count >= workingName.count {
                newName = ""
            } else {
                newName = String(workingName.dropFirst(count))
            }
            
        case .lastN:
            let actualCount = min(count, workingName.count)
            if actualCount > 0 {
                deletedRanges.append((workingName.count - actualCount)..<workingName.count)
            }
            if count >= workingName.count {
                newName = ""
            } else {
                newName = String(workingName.dropLast(count))
            }
            
        case .range:
            let start = max(0, min(rangeStart, workingName.count))
            let end = max(start, min(rangeEnd, workingName.count))
            if end > start {
                deletedRanges.append(start..<end)
            }
            let startIndex = workingName.index(workingName.startIndex, offsetBy: start)
            let endIndex = workingName.index(workingName.startIndex, offsetBy: end)
            var mutableName = workingName
            mutableName.removeSubrange(startIndex..<endIndex)
            newName = mutableName
            
        case .specific:
            // Find all positions of characters to be removed
            for (i, char) in workingName.enumerated() {
                if specificChars.contains(char) {
                    deletedRanges.append(i..<(i + 1))
                }
            }
            // Merge adjacent ranges for cleaner highlighting
            deletedRanges = mergeAdjacentRanges(deletedRanges)
            newName = workingName.filter { !specificChars.contains($0) }
        }

        // Handle empty name fallback
        let finalWorkingName = newName.isEmpty ? "_" : newName
        
        // If we worked on full filename, return as-is; otherwise reattach extension
        let finalName: String
        if applyToExtension || ext.isEmpty {
            finalName = finalWorkingName
        } else {
            finalName = "\(finalWorkingName).\(ext)"
        }
        
        // For remove operations, we only have deleted ranges, no changed ranges
        return RenamePreviewResult(newName: finalName, changedRanges: [], deletedRanges: deletedRanges)
    }
    
    /// Merges adjacent ranges into single ranges (e.g., [0..<1, 1..<2, 3..<4] becomes [0..<2, 3..<4])
    private func mergeAdjacentRanges(_ ranges: [Range<Int>]) -> [Range<Int>] {
        guard !ranges.isEmpty else { return [] }
        
        let sorted = ranges.sorted { $0.lowerBound < $1.lowerBound }
        var result: [Range<Int>] = [sorted[0]]
        
        for range in sorted.dropFirst() {
            if let last = result.last, last.upperBound >= range.lowerBound {
                // Merge with previous range
                result[result.count - 1] = last.lowerBound..<max(last.upperBound, range.upperBound)
            } else {
                result.append(range)
            }
        }
        
        return result
    }
}
