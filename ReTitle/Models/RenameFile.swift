// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import Foundation

struct RenameFile: Identifiable, Equatable {
    let id: UUID
    let url: URL
    let parentBookmark: Data?
    
    init(url: URL) {
        self.id = UUID()
        self.url = url
        // Create a security-scoped bookmark for the parent directory
        self.parentBookmark = try? url.deletingLastPathComponent().bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }
    
    init(id: UUID, url: URL, parentBookmark: Data? = nil) {
        self.id = id
        self.url = url
        self.parentBookmark = parentBookmark ?? (try? url.deletingLastPathComponent().bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        ))
    }

    var originalName: String {
        url.lastPathComponent
    }

    var nameWithoutExtension: String {
        url.deletingPathExtension().lastPathComponent
    }

    var fileExtension: String {
        url.pathExtension
    }

    var parentDirectory: URL {
        url.deletingLastPathComponent()
    }

    func newURL(withName newName: String) -> URL {
        parentDirectory.appendingPathComponent(newName)
    }
    
    /// Resolves and starts accessing the parent directory from the bookmark
    /// Returns the URL if successful, caller must call stopAccessingSecurityScopedResource when done
    func startAccessingParentDirectory() -> URL? {
        guard let bookmark = parentBookmark else { return nil }
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: bookmark,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else { return nil }
        
        if url.startAccessingSecurityScopedResource() {
            return url
        }
        return nil
    }
    
    static func == (lhs: RenameFile, rhs: RenameFile) -> Bool {
        lhs.id == rhs.id && lhs.url == rhs.url
    }
}
