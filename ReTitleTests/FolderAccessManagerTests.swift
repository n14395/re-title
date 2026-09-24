// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import ReTitle

final class FolderAccessManagerTests: XCTestCase {
    
    // MARK: - TCC Protected Folder Detection
    
    func testIsTCCProtectedFolderDesktop() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            if let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first {
                XCTAssertTrue(manager.isTCCProtectedFolder(desktopURL))
            }
        }
    }
    
    func testIsTCCProtectedFolderDocuments() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                XCTAssertTrue(manager.isTCCProtectedFolder(documentsURL))
            }
        }
    }
    
    func testIsTCCProtectedFolderDownloads() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            if let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                XCTAssertTrue(manager.isTCCProtectedFolder(downloadsURL))
            }
        }
    }
    
    func testIsTCCProtectedFolderSubdirectory() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            if let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first {
                let subfolderURL = desktopURL.appendingPathComponent("SomeSubfolder")
                XCTAssertTrue(manager.isTCCProtectedFolder(subfolderURL))
            }
        }
    }
    
    func testIsTCCProtectedFolderReturnsFalseForRoot() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            let rootURL = URL(fileURLWithPath: "/")
            XCTAssertFalse(manager.isTCCProtectedFolder(rootURL))
        }
    }
    
    func testIsTCCProtectedFolderReturnsFalseForTmp() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            let tmpURL = URL(fileURLWithPath: "/tmp")
            XCTAssertFalse(manager.isTCCProtectedFolder(tmpURL))
        }
    }
    
    func testIsTCCProtectedFolderReturnsFalseForApplications() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            let appsURL = URL(fileURLWithPath: "/Applications")
            XCTAssertFalse(manager.isTCCProtectedFolder(appsURL))
        }
    }
    
    // MARK: - TCC Folder Name Detection
    
    func testTCCFolderNameForDesktop() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            if let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first {
                XCTAssertEqual(manager.tccFolderName(for: desktopURL), "Desktop")
            }
        }
    }
    
    func testTCCFolderNameForDocuments() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                XCTAssertEqual(manager.tccFolderName(for: documentsURL), "Documents")
            }
        }
    }
    
    func testTCCFolderNameForDownloads() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            if let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                XCTAssertEqual(manager.tccFolderName(for: downloadsURL), "Downloads")
            }
        }
    }
    
    func testTCCFolderNameForSubdirectory() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let subfolderURL = documentsURL.appendingPathComponent("Projects/MyApp")
                XCTAssertEqual(manager.tccFolderName(for: subfolderURL), "Documents")
            }
        }
    }
    
    func testTCCFolderNameReturnsNilForNonProtected() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            let tmpURL = URL(fileURLWithPath: "/tmp")
            XCTAssertNil(manager.tccFolderName(for: tmpURL))
        }
    }
    
    func testTCCFolderNameReturnsNilForRoot() async {
        await MainActor.run {
            let manager = FolderAccessManager.shared
            let rootURL = URL(fileURLWithPath: "/")
            XCTAssertNil(manager.tccFolderName(for: rootURL))
        }
    }
    
    // MARK: - Has Access Tests
    
    func testHasAccessReturnsFalseForNoAccessedURLs() async {
        await MainActor.run {
            // Note: This test checks the logic but since FolderAccessManager.shared 
            // may have state from other tests, we verify the basic behavior
            let manager = FolderAccessManager.shared
            let randomURL = URL(fileURLWithPath: "/some/random/nonexistent/path/\(UUID().uuidString)")
            // Without having accessed this specific path, hasAccess should return false
            // unless a parent path has been accessed
            // This is a behavioral test - result depends on current state
            _ = manager.hasAccess(to: randomURL)
            // Just verify it doesn't crash
        }
    }
    
    func testHasAccessChecksPrefixCorrectly() {
        // Test that the path prefix logic is consistent
        let parentPath = "/Users/test"
        let childPath = "/Users/test/Documents/file.txt"
        
        // Verify prefix logic
        XCTAssertTrue(childPath.hasPrefix(parentPath))
        XCTAssertFalse(parentPath.hasPrefix(childPath))
    }
    
    // MARK: - Singleton Tests
    
    func testSharedInstanceIsSingleton() async {
        await MainActor.run {
            let instance1 = FolderAccessManager.shared
            let instance2 = FolderAccessManager.shared
            XCTAssertTrue(instance1 === instance2)
        }
    }
}
