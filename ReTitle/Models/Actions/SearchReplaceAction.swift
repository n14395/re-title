// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import Foundation

struct SearchReplaceAction: RenameAction {
    var searchText: String = ""
    var replaceText: String = ""
    var useRegex: Bool = false
    var caseSensitive: Bool = true
    var replaceAll: Bool = true

    func applyWithTracking(to filename: String, at index: Int, totalCount: Int, applyToExtension: Bool) -> RenamePreviewResult {
        let url = URL(fileURLWithPath: filename)
        let name = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension

        guard !searchText.isEmpty else {
            return .unchanged(filename)
        }

        let nameResult: (newName: String, changedRanges: [Range<Int>], deletedRanges: [Range<Int>])
        let extResult: (newName: String, changedRanges: [Range<Int>], deletedRanges: [Range<Int>])
        
        if useRegex {
            nameResult = applyRegexWithTracking(to: name)
            extResult = applyToExtension ? applyRegexWithTracking(to: ext) : (ext, [], [])
        } else {
            nameResult = applyLiteralWithTracking(to: name)
            extResult = applyToExtension ? applyLiteralWithTracking(to: ext) : (ext, [], [])
        }

        // Combine results
        let newFilename: String
        var allChangedRanges = nameResult.changedRanges
        var allDeletedRanges = nameResult.deletedRanges
        
        if extResult.newName.isEmpty {
            newFilename = nameResult.newName
        } else {
            newFilename = "\(nameResult.newName).\(extResult.newName)"
            
            // Offset extension ranges by name length + 1 (for the dot)
            let extOffset = nameResult.newName.count + 1
            let origExtOffset = name.count + 1
            
            for range in extResult.changedRanges {
                allChangedRanges.append((range.lowerBound + extOffset)..<(range.upperBound + extOffset))
            }
            for range in extResult.deletedRanges {
                allDeletedRanges.append((range.lowerBound + origExtOffset)..<(range.upperBound + origExtOffset))
            }
        }
        
        return RenamePreviewResult(newName: newFilename, changedRanges: allChangedRanges, deletedRanges: allDeletedRanges)
    }

    private func applyRegexWithTracking(to name: String) -> (newName: String, changedRanges: [Range<Int>], deletedRanges: [Range<Int>]) {
        do {
            var options: NSRegularExpression.Options = []
            if !caseSensitive {
                options.insert(.caseInsensitive)
            }
            let regex = try NSRegularExpression(pattern: searchText, options: options)
            let range = NSRange(name.startIndex..., in: name)
            
            let matches: [NSTextCheckingResult]
            if replaceAll {
                matches = regex.matches(in: name, options: [], range: range)
            } else {
                if let firstMatch = regex.firstMatch(in: name, options: [], range: range) {
                    matches = [firstMatch]
                } else {
                    matches = []
                }
            }
            
            guard !matches.isEmpty else {
                return (name, [], [])
            }
            
            // Process matches in reverse order to maintain correct indices
            var result = name
            var changedRanges: [Range<Int>] = []
            var deletedRanges: [Range<Int>] = []
            
            for match in matches {
                guard let swiftRange = Range(match.range, in: name) else { continue }
                
                let matchStart = name.distance(from: name.startIndex, to: swiftRange.lowerBound)
                let matchLength = name.distance(from: swiftRange.lowerBound, to: swiftRange.upperBound)
                
                // Store deleted range (in original string)
                deletedRanges.append(matchStart..<(matchStart + matchLength))
            }
            
            // Now do the actual replacement and track new positions
            if replaceAll {
                result = regex.stringByReplacingMatches(in: name, options: [], range: range, withTemplate: replaceText)
                
                // Calculate changed ranges in the new string
                var currentOffset = 0
                for match in matches {
                    guard let swiftRange = Range(match.range, in: name) else { continue }
                    let matchStart = name.distance(from: name.startIndex, to: swiftRange.lowerBound)
                    let matchLength = name.distance(from: swiftRange.lowerBound, to: swiftRange.upperBound)
                    
                    // Expand the template for this match to get actual replacement length
                    let matchedString = String(name[swiftRange])
                    let expandedReplacement = regex.stringByReplacingMatches(
                        in: matchedString,
                        options: [],
                        range: NSRange(matchedString.startIndex..., in: matchedString),
                        withTemplate: replaceText
                    )
                    let replacementLength = expandedReplacement.count
                    
                    let adjustedStart = matchStart + currentOffset
                    if replacementLength > 0 {
                        changedRanges.append(adjustedStart..<(adjustedStart + replacementLength))
                    }
                    currentOffset += replacementLength - matchLength
                }
            } else if let match = matches.first, let swiftRange = Range(match.range, in: name) {
                let matchStart = name.distance(from: name.startIndex, to: swiftRange.lowerBound)
                result.replaceSubrange(swiftRange, with: replaceText)
                if !replaceText.isEmpty {
                    changedRanges.append(matchStart..<(matchStart + replaceText.count))
                }
            }
            
            return (result, changedRanges, deletedRanges)
        } catch {
            return (name, [], [])
        }
    }

    private func applyLiteralWithTracking(to name: String) -> (newName: String, changedRanges: [Range<Int>], deletedRanges: [Range<Int>]) {
        let options: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
        
        if replaceAll {
            // Find all occurrences
            var searchRange = name.startIndex..<name.endIndex
            var matches: [Range<String.Index>] = []
            
            while let foundRange = name.range(of: searchText, options: options, range: searchRange) {
                matches.append(foundRange)
                searchRange = foundRange.upperBound..<name.endIndex
            }
            
            guard !matches.isEmpty else {
                return (name, [], [])
            }
            
            // Calculate deleted ranges (in original)
            var deletedRanges: [Range<Int>] = []
            for match in matches {
                let start = name.distance(from: name.startIndex, to: match.lowerBound)
                let end = name.distance(from: name.startIndex, to: match.upperBound)
                deletedRanges.append(start..<end)
            }
            
            // Do the replacement and calculate new positions
            var result = name
            var changedRanges: [Range<Int>] = []
            var currentOffset = 0
            
            for match in matches {
                let originalStart = name.distance(from: name.startIndex, to: match.lowerBound)
                let adjustedStart = originalStart + currentOffset
                
                if !replaceText.isEmpty {
                    changedRanges.append(adjustedStart..<(adjustedStart + replaceText.count))
                }
                
                currentOffset += replaceText.count - searchText.count
            }
            
            // Perform the actual replacement
            if caseSensitive {
                result = name.replacingOccurrences(of: searchText, with: replaceText)
            } else {
                result = name.replacingOccurrences(of: searchText, with: replaceText, options: .caseInsensitive)
            }
            
            return (result, changedRanges, deletedRanges)
        } else {
            // Replace first only
            guard let foundRange = name.range(of: searchText, options: options) else {
                return (name, [], [])
            }
            
            let start = name.distance(from: name.startIndex, to: foundRange.lowerBound)
            let end = name.distance(from: name.startIndex, to: foundRange.upperBound)
            
            var result = name
            result.replaceSubrange(foundRange, with: replaceText)
            
            let changedRanges: [Range<Int>] = replaceText.isEmpty ? [] : [start..<(start + replaceText.count)]
            let deletedRanges: [Range<Int>] = [start..<end]
            
            return (result, changedRanges, deletedRanges)
        }
    }
}
