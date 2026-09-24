// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import ReTitle

final class RenameErrorTests: XCTestCase {
    
    // MARK: - Basic Initialization
    
    func testRenameErrorWithAllFields() {
        let folderURL = URL(fileURLWithPath: "/Users/test/Documents")
        let error = RenameError(
            message: "Permission denied",
            isPermissionError: true,
            folderURL: folderURL
        )
        
        XCTAssertEqual(error.message, "Permission denied")
        XCTAssertTrue(error.isPermissionError)
        XCTAssertEqual(error.folderURL, folderURL)
    }
    
    func testRenameErrorNonPermissionError() {
        let error = RenameError(
            message: "File already exists",
            isPermissionError: false,
            folderURL: nil
        )
        
        XCTAssertEqual(error.message, "File already exists")
        XCTAssertFalse(error.isPermissionError)
        XCTAssertNil(error.folderURL)
    }
    
    func testRenameErrorPermissionErrorWithFolder() {
        let folderURL = URL(fileURLWithPath: "/Users/test/Desktop")
        let error = RenameError(
            message: "Operation not permitted",
            isPermissionError: true,
            folderURL: folderURL
        )
        
        XCTAssertTrue(error.isPermissionError)
        XCTAssertNotNil(error.folderURL)
        XCTAssertEqual(error.folderURL?.lastPathComponent, "Desktop")
    }
    
    func testRenameErrorEmptyMessage() {
        let error = RenameError(
            message: "",
            isPermissionError: false,
            folderURL: nil
        )
        
        XCTAssertEqual(error.message, "")
        XCTAssertFalse(error.isPermissionError)
    }
    
    func testRenameErrorLongMessage() {
        let longMessage = String(repeating: "Error details. ", count: 100)
        let error = RenameError(
            message: longMessage,
            isPermissionError: false,
            folderURL: nil
        )
        
        XCTAssertEqual(error.message, longMessage)
    }
    
    // MARK: - URL Path Tests
    
    func testRenameErrorWithNestedFolderURL() {
        let folderURL = URL(fileURLWithPath: "/Users/test/Documents/Projects/MyApp/Resources")
        let error = RenameError(
            message: "Access denied",
            isPermissionError: true,
            folderURL: folderURL
        )
        
        XCTAssertEqual(error.folderURL?.path, "/Users/test/Documents/Projects/MyApp/Resources")
    }
    
    func testRenameErrorWithRootFolderURL() {
        let folderURL = URL(fileURLWithPath: "/")
        let error = RenameError(
            message: "Permission denied",
            isPermissionError: true,
            folderURL: folderURL
        )
        
        XCTAssertEqual(error.folderURL?.path, "/")
    }
    
    func testRenameErrorWithSpacesInPath() {
        let folderURL = URL(fileURLWithPath: "/Users/test/My Documents/My Project")
        let error = RenameError(
            message: "Permission denied",
            isPermissionError: true,
            folderURL: folderURL
        )
        
        XCTAssertTrue(error.folderURL?.path.contains("My Documents") ?? false)
    }
    
    // MARK: - Message Content Tests
    
    func testRenameErrorWithUnicodeMessage() {
        let error = RenameError(
            message: "权限被拒绝 - アクセスが拒否されました",
            isPermissionError: true,
            folderURL: nil
        )
        
        XCTAssertTrue(error.message.contains("权限"))
        XCTAssertTrue(error.message.contains("アクセス"))
    }
    
    func testRenameErrorWithSpecialCharactersInMessage() {
        let error = RenameError(
            message: "Error: File \"test.txt\" couldn't be renamed (code: -1)",
            isPermissionError: false,
            folderURL: nil
        )
        
        XCTAssertTrue(error.message.contains("\"test.txt\""))
        XCTAssertTrue(error.message.contains("(code: -1)"))
    }
    
    func testRenameErrorWithNewlinesInMessage() {
        let error = RenameError(
            message: "Error occurred.\nDetails: Permission denied.\nPlease try again.",
            isPermissionError: true,
            folderURL: nil
        )
        
        XCTAssertTrue(error.message.contains("\n"))
    }
}
