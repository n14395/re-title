import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
@Observable
final class RenameViewModel {
    var files: [RenameFile] = []
    var selectedActionType: ActionType = .searchReplace
    var selectedFileIDs: Set<UUID> = []
    
    /// Manages undo/redo for rename operations
    let renameUndoManager = RenameUndoManager()
    
    private var destinationFolderBookmark: Data? = nil
    private var _destinationFolder: URL? = nil
    var destinationFolder: URL? {
        get { _destinationFolder }
        set {
            // Stop accessing old folder
            if _destinationFolder != nil {
                _destinationFolder?.stopAccessingSecurityScopedResource()
            }
            _destinationFolder = newValue
            // Create bookmark for new folder
            if let url = newValue {
                destinationFolderBookmark = try? url.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
            } else {
                destinationFolderBookmark = nil
            }
        }
    }
    var applyToExtension: Bool = false

    // Action configurations
    var caseAction = CaseAction()
    var dateTimeAction = DateTimeAction()
    var exifAction = ExifAction()
    var insertAction = InsertAction()
    var numberingAction = NumberingAction()
    var removeAction = RemoveAction()
    var searchReplaceAction = SearchReplaceAction()

    var currentAction: RenameAction {
        switch selectedActionType {
        case .caseChange:
            return caseAction
        case .dateTime:
            return dateTimeAction
        case .exif:
            return exifAction
        case .insert:
            return insertAction
        case .numbering:
            return numberingAction
        case .remove:
            return removeAction
        case .searchReplace:
            return searchReplaceAction
        }
    }

    func previewName(for file: RenameFile, at index: Int) -> String {
        currentAction.apply(to: file.originalName, at: index, totalCount: files.count, applyToExtension: applyToExtension)
    }
    
    func previewResult(for file: RenameFile, at index: Int) -> RenamePreviewResult {
        currentAction.applyWithTracking(to: file.originalName, at: index, totalCount: files.count, applyToExtension: applyToExtension)
    }

    func addFiles(urls: [URL]) {
        let newFiles = urls
            .filter { url in
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
                return !isDirectory.boolValue
            }
            .filter { url in
                !files.contains { $0.url == url }
            }
            .map { RenameFile(url: $0) }

        files.append(contentsOf: newFiles)
        updateExifMetadataCache()
    }

    func removeFile(_ file: RenameFile) {
        files.removeAll { $0.id == file.id }
        updateExifMetadataCache()
    }

    func clearFiles() {
        files.removeAll()
        exifAction.metadataCache.removeAll()
    }

    func moveFiles(fromOffsets source: IndexSet, toOffset destination: Int) {
        files.move(fromOffsets: source, toOffset: destination)
    }

    /// Updates the EXIF metadata cache for all current files asynchronously
    private func updateExifMetadataCache() {
        // Capture file info on main thread
        let fileInfo = files.map { (url: $0.url, name: $0.originalName) }
        
        Task.detached(priority: .userInitiated) {
            var cache: [String: ExifMetadata] = [:]
            for info in fileInfo {
                if let metadata = await ExifMetadata.extractAsync(from: info.url) {
                    cache[info.name] = metadata
                }
            }
            let finalCache = cache
            await MainActor.run {
                self.exifAction.metadataCache = finalCache
            }
        }
    }

    /// Ensures we have access to a folder, requesting it if needed
    /// Returns true if access is available
    private func ensureFolderAccess(for folderURL: URL) -> Bool {
        return FolderAccessManager.shared.ensureAccess(to: folderURL)
    }
    
    func applyRenames() -> [RenameResult] {
        var results: [RenameResult] = []
        let fileManager = FileManager.default

        // Resolve destination folder from bookmark if needed
        var resolvedDestination: URL? = nil
        if let bookmark = destinationFolderBookmark {
            var isStale = false
            if let url = try? URL(
                resolvingBookmarkData: bookmark,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            ) {
                _ = url.startAccessingSecurityScopedResource()
                resolvedDestination = url
            }
        }
        defer {
            resolvedDestination?.stopAccessingSecurityScopedResource()
        }
        
        // Collect unique parent directories that need access
        var parentDirectories = Set<URL>()
        for file in files {
            if resolvedDestination == nil {
                parentDirectories.insert(file.parentDirectory)
            }
        }
        
        // Ensure access to all needed folders (will prompt user if needed)
        for folder in parentDirectories {
            _ = ensureFolderAccess(for: folder)
        }

        for (index, file) in files.enumerated() {
            let newName = previewName(for: file, at: index)
            
            // Skip files where the name doesn't change and we're not moving to a new folder
            if newName == file.originalName && resolvedDestination == nil {
                continue
            }
            
            let newURL: URL
            
            if let destination = resolvedDestination {
                newURL = destination.appendingPathComponent(newName)
            } else {
                newURL = file.newURL(withName: newName)
            }

            // Start accessing the file itself
            let fileAccess = file.url.startAccessingSecurityScopedResource()
            
            do {
                try fileManager.moveItem(at: file.url, to: newURL)
                results.append(RenameResult(
                    originalURL: file.url,
                    newURL: newURL,
                    success: true,
                    error: nil,
                    fileID: file.id
                ))
            } catch {
                results.append(RenameResult(
                    originalURL: file.url,
                    newURL: newURL,
                    success: false,
                    error: error.localizedDescription,
                    fileID: file.id
                ))
            }
            
            if fileAccess {
                file.url.stopAccessingSecurityScopedResource()
            }
        }

        // Update successfully renamed files with their new URLs (keep them in the list)
        for result in results where result.success {
            if let index = files.firstIndex(where: { $0.id == result.fileID }) {
                files[index] = RenameFile(id: result.fileID, url: result.newURL, parentBookmark: files[index].parentBookmark)
            }
        }
        
        updateExifMetadataCache()
        
        // Record successful renames for undo
        let successfulMappings = results
            .filter { $0.success }
            .map { (oldURL: $0.originalURL, newURL: $0.newURL) }
        renameUndoManager.recordRename(mappings: successfulMappings)

        // Count the whole batch as a single core action if anything succeeded
        if !successfulMappings.isEmpty {
            ReviewPrompt.registerCoreAction()
        }

        return results
    }
    
    // MARK: - Undo/Redo
    
    /// Undoes the last rename operation
    func undoLastRename() {
        let result = renameUndoManager.undo()
        
        switch result {
        case .success(let mappings):
            // Update file list with restored URLs
            for mapping in mappings {
                if let index = files.firstIndex(where: { $0.url == mapping.currentURL }) {
                    files[index] = RenameFile(
                        id: files[index].id,
                        url: mapping.targetURL,
                        parentBookmark: files[index].parentBookmark
                    )
                }
            }
            updateExifMetadataCache()
            
        case .failure(let error):
            // Log error - in a full implementation we'd show an alert
            print("Undo failed: \(error.localizedDescription)")
        }
    }
    
    /// Redoes the last undone rename operation
    func redoLastRename() {
        let result = renameUndoManager.redo()
        
        switch result {
        case .success(let mappings):
            // Update file list with re-renamed URLs
            for mapping in mappings {
                if let index = files.firstIndex(where: { $0.url == mapping.currentURL }) {
                    files[index] = RenameFile(
                        id: files[index].id,
                        url: mapping.targetURL,
                        parentBookmark: files[index].parentBookmark
                    )
                }
            }
            updateExifMetadataCache()
            
        case .failure(let error):
            // Log error - in a full implementation we'd show an alert
            print("Redo failed: \(error.localizedDescription)")
        }
    }

    func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.message = "Select files to rename, or select a folder to rename files within it"
        panel.prompt = "Select"

        if panel.runModal() == .OK {
            var urls: [URL] = []
            for url in panel.urls {
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // User selected a folder - get all files in it
                        if let contents = try? FileManager.default.contentsOfDirectory(
                            at: url,
                            includingPropertiesForKeys: nil,
                            options: [.skipsHiddenFiles]
                        ) {
                            urls.append(contentsOf: contents.filter { !$0.hasDirectoryPath })
                        }
                    } else {
                        urls.append(url)
                    }
                }
            }
            addFiles(urls: urls)
        }
    }
    
    func selectDestinationFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.prompt = "Select"
        panel.message = "Choose destination folder for renamed files"

        if panel.runModal() == .OK {
            destinationFolder = panel.url
        }
    }
    
    func clearDestinationFolder() {
        destinationFolder = nil
    }
    
    var destinationFolderName: String {
        destinationFolder?.lastPathComponent ?? "Don't Move"
    }
    
    /// Returns true if any two files would have the same new name (name clash)
    var hasDuplicateNewNames: Bool {
        let allNewNames = files.enumerated().map { index, file in
            previewName(for: file, at: index)
        }
        return Set(allNewNames).count != allNewNames.count
    }
    
    /// Renames a file on disk and updates the file list with the new URL
    /// Returns nil if successful, or a RenameError if failed
    func renameFileOnDisk(_ file: RenameFile, to newName: String) -> RenameError? {
        let fileManager = FileManager.default
        let newURL = file.parentDirectory.appendingPathComponent(newName)
        
        // Don't rename if the name hasn't changed
        guard newName != file.originalName else { return nil }
        
        // Try to access parent directory via stored bookmark first
        let parentURL = file.startAccessingParentDirectory()
        defer {
            parentURL?.stopAccessingSecurityScopedResource()
        }
        
        // If no parent bookmark access, check if FolderAccessManager has access
        // Don't prompt here - let the caller handle permission errors
        let hasAccess = parentURL != nil || FolderAccessManager.shared.hasAccess(to: file.parentDirectory)
        
        // Start accessing the file itself
        let fileAccess = file.url.startAccessingSecurityScopedResource()
        defer {
            if fileAccess {
                file.url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let originalURL = file.url
            try fileManager.moveItem(at: originalURL, to: newURL)
            // Update the file in our list with the new URL, preserving the ID and bookmark
            if let index = files.firstIndex(where: { $0.id == file.id }) {
                files[index] = RenameFile(id: file.id, url: newURL, parentBookmark: file.parentBookmark)
            }
            updateExifMetadataCache()
            
            // Record for undo
            renameUndoManager.recordRename(mappings: [(oldURL: originalURL, newURL: newURL)])

            // A successful single-file rename is also a core action
            ReviewPrompt.registerCoreAction()

            return nil
        } catch let nsError as NSError {
            // Check for permission-related errors
            let isPermissionError = nsError.domain == NSCocoaErrorDomain &&
                (nsError.code == NSFileWriteNoPermissionError ||
                 nsError.code == NSFileReadNoPermissionError ||
                 nsError.code == 513) // Operation not permitted
            
            if isPermissionError || !hasAccess {
                return RenameError(
                    message: nsError.localizedDescription,
                    isPermissionError: true,
                    folderURL: file.parentDirectory
                )
            }
            
            return RenameError(
                message: nsError.localizedDescription,
                isPermissionError: false,
                folderURL: nil
            )
        }
    }
}

/// Represents an error that occurred during renaming
struct RenameError {
    let message: String
    let isPermissionError: Bool
    let folderURL: URL?
}

struct RenameResult: Identifiable {
    let id = UUID()
    let originalURL: URL
    let newURL: URL
    let success: Bool
    let error: String?
    let fileID: UUID
}
