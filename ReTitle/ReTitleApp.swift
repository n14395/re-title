// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import SwiftUI

@main
struct ReTitleApp: App {
    /// Use AppDelegate for Services menu integration
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /// Track whether onboarding has been completed
    @State private var showOnboarding = !FolderAccessManager.shared.isOnboardingComplete

    init() {
        ReviewPrompt.registerLaunch()
        #if SPARKLE
        SparkleUpdater.start()
        #endif
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            Group {
                if showOnboarding {
                    OnboardingView {
                        showOnboarding = false
                    }
                } else {
                    ContentView(viewModel: appDelegate.viewModel, showOnboarding: $showOnboarding)
                }
            }
            .onAppear {
                // Start accessing any stored folders on app launch
                FolderAccessManager.shared.startAccessingAll()
            }
        }
        .windowResizability(.contentMinSize)
        .commands {
            ReTitleCommands()
            #if SPARKLE
            SparkleCommands()
            #endif
        }
    }
}

/// Manages persistent folder access using security-scoped bookmarks
/// Stores multiple folder bookmarks to handle files from different locations
@MainActor
final class FolderAccessManager {
    static let shared = FolderAccessManager()
    
    private let bookmarksKey = "com.retitle.folderAccessBookmarks"
    private let onboardingCompleteKey = "com.retitle.onboardingComplete"
    private var accessedURLs: [URL] = []
    
    // MARK: - Onboarding
    
    /// Returns true if onboarding has been completed
    var isOnboardingComplete: Bool {
        UserDefaults.standard.bool(forKey: onboardingCompleteKey)
    }
    
    /// Returns true if any bookmarks have been stored
    var hasAnyStoredBookmarks: Bool {
        !getStoredBookmarks().isEmpty
    }
    
    /// Mark onboarding as complete
    func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: onboardingCompleteKey)
    }
    
    /// Store a bookmark for a folder (public for onboarding use)
    /// - Parameter url: The folder URL to store access for
    /// - Returns: true if the bookmark was stored successfully
    func storeAccessBookmark(for url: URL) -> Bool {
        return storeAccess(to: url)
    }
    
    // MARK: - Folder Access
    
    /// Request folder access from user for a specific folder and store bookmark
    /// - Parameter folderURL: The folder to request access for (opens panel at this location)
    /// - Returns: true if access was granted
    func requestAccess(for folderURL: URL) -> Bool {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = folderURL
        panel.message = "ReTitle needs access to this folder to rename files.\nPlease select: \(folderURL.lastPathComponent)"
        panel.prompt = "Grant Access"
        
        if panel.runModal() == .OK, let url = panel.url {
            return storeAccess(to: url)
        }
        return false
    }
    
    /// Store a security-scoped bookmark for a folder
    private func storeAccess(to url: URL) -> Bool {
        do {
            let bookmark = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            // Get existing bookmarks
            var bookmarks = getStoredBookmarks()
            bookmarks[url.path] = bookmark
            
            // Save updated bookmarks
            if let data = try? JSONEncoder().encode(bookmarks) {
                UserDefaults.standard.set(data, forKey: bookmarksKey)
            }
            
            // Start accessing immediately
            if url.startAccessingSecurityScopedResource() {
                accessedURLs.append(url)
            }
            
            return true
        } catch {
            print("Failed to create bookmark: \(error)")
            return false
        }
    }
    
    /// Get stored bookmarks dictionary
    private func getStoredBookmarks() -> [String: Data] {
        guard let data = UserDefaults.standard.data(forKey: bookmarksKey),
              let bookmarks = try? JSONDecoder().decode([String: Data].self, from: data) else {
            return [:]
        }
        return bookmarks
    }
    
    /// Start accessing all stored folders - call at app launch
    func startAccessingAll() {
        let bookmarks = getStoredBookmarks()
        
        for (_, bookmarkData) in bookmarks {
            do {
                var isStale = false
                let url = try URL(
                    resolvingBookmarkData: bookmarkData,
                    options: .withSecurityScope,
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
                
                if url.startAccessingSecurityScopedResource() {
                    accessedURLs.append(url)
                }
            } catch {
                // Ignore errors for individual bookmarks
            }
        }
    }
    
    /// Check if we have access to a folder (or its parent)
    func hasAccess(to folderURL: URL) -> Bool {
        let folderPath = folderURL.path
        return accessedURLs.contains { accessedURL in
            folderPath.hasPrefix(accessedURL.path)
        }
    }
    
    /// Try to get access to a folder - returns true if we have it or can get it
    func ensureAccess(to folderURL: URL) -> Bool {
        if hasAccess(to: folderURL) {
            return true
        }
        return requestAccess(for: folderURL)
    }
    
    /// Check if a URL is in a TCC-protected folder (Desktop, Documents, Downloads)
    func isTCCProtectedFolder(_ url: URL) -> Bool {
        let fileManager = FileManager.default
        let protectedDirectories: [FileManager.SearchPathDirectory] = [
            .desktopDirectory,
            .documentDirectory,
            .downloadsDirectory
        ]
        
        for directory in protectedDirectories {
            if let protectedURL = fileManager.urls(for: directory, in: .userDomainMask).first {
                if url.path.hasPrefix(protectedURL.path) {
                    return true
                }
            }
        }
        return false
    }
    
    /// Get a user-friendly name for a TCC-protected folder
    func tccFolderName(for url: URL) -> String? {
        let fileManager = FileManager.default
        let directories: [(FileManager.SearchPathDirectory, String)] = [
            (.desktopDirectory, "Desktop"),
            (.documentDirectory, "Documents"),
            (.downloadsDirectory, "Downloads")
        ]
        
        for (directory, name) in directories {
            if let protectedURL = fileManager.urls(for: directory, in: .userDomainMask).first {
                if url.path.hasPrefix(protectedURL.path) {
                    return name
                }
            }
        }
        return nil
    }
    
    /// Stop accessing all folders - call at app termination
    func stopAccessingAll() {
        for url in accessedURLs {
            url.stopAccessingSecurityScopedResource()
        }
        accessedURLs.removeAll()
    }
}
