import AppKit
import Foundation

/// AppDelegate to handle macOS Services menu integration
/// Allows users to right-click files in Finder and select "Open in ReTitle"
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    /// Shared view model that persists across the app lifecycle
    /// This is accessed by ContentView to display and manage files
    let viewModel = RenameViewModel()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register this object as the service provider
        // The service name "ReTitle" must match NSPortName in Info.plist
        NSApp.servicesProvider = self
        
        // Update the services menu to include our service
        NSUpdateDynamicServices()
    }
    
    /// Handle dock icon click when no windows are visible
    /// This ensures users can reopen the main window by clicking the dock icon
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // No visible windows - find and show an existing window
            for window in NSApp.windows where window.canBecomeMain {
                window.makeKeyAndOrderFront(nil)
                return true
            }
        }
        return true
    }
    
    /// Service handler called when user selects "Open in ReTitle" from Finder's Services menu
    /// - Parameters:
    ///   - pboard: Pasteboard containing the selected file URLs
    ///   - userData: Optional user data (unused)
    ///   - error: Error pointer for reporting failures
    @objc func openFilesFromService(
        _ pboard: NSPasteboard,
        userData: String?,
        error: AutoreleasingUnsafeMutablePointer<NSString?>
    ) {
        // Extract file URLs from the pasteboard
        guard let fileURLs = pboard.readObjects(forClasses: [NSURL.self], options: [
            .urlReadingFileURLsOnly: true
        ]) as? [URL] else {
            error.pointee = "Could not read file URLs from pasteboard" as NSString
            return
        }
        
        guard !fileURLs.isEmpty else {
            error.pointee = "No files were selected" as NSString
            return
        }
        
        // Add the files to the view model on the main thread
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.addFiles(urls: fileURLs)
            
            // Bring the app to the foreground
            NSApp.activate(ignoringOtherApps: true)
            
            // Ensure the main window is visible
            if let window = NSApp.windows.first {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }
}
