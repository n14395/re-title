import SwiftUI

/// Menu bar commands for ReTitle
struct ReTitleCommands: Commands {
    
    var body: some Commands {
        // Replace the default "New" item with our file commands
        CommandGroup(replacing: .newItem) {
            FileMenuCommands()
        }
        
        // Replace the default undo/redo with our rename undo/redo
        CommandGroup(replacing: .undoRedo) {
            EditMenuCommands()
        }
        
        // New Action menu for switching between action types
        CommandMenu("Action") {
            ActionMenuCommands()
        }
        
        // Add onboarding option to Help menu
        CommandGroup(after: .help) {
            HelpMenuCommands()
        }
        
        // Add Window menu for showing the main window when closed
        CommandGroup(before: .windowList) {
            WindowMenuCommands()
        }
    }
}

// MARK: - Window Menu Commands

struct WindowMenuCommands: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        Button("Show Main Window") {
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: "main")
        }
        .keyboardShortcut("0", modifiers: .command)
    }
}

// MARK: - File Menu Commands

struct FileMenuCommands: View {
    @FocusedValue(\.renameViewModel) var viewModel
    
    var body: some View {
        Button("Add Files...") {
            viewModel?.openFilePicker()
        }
        .keyboardShortcut("o", modifiers: .command)
        
        Divider()
        
        Button("Select Destination...") {
            viewModel?.selectDestinationFolder()
        }
        .keyboardShortcut("d", modifiers: [.command, .shift])
        
        Button("Rename In Place") {
            viewModel?.clearDestinationFolder()
        }
        .keyboardShortcut("i", modifiers: [.command, .shift])
        .disabled(viewModel?.destinationFolder == nil)
        
        Divider()
        
        Button("Apply Renames") {
            _ = viewModel?.applyRenames()
        }
        .keyboardShortcut(.return, modifiers: .command)
        .disabled(viewModel?.files.isEmpty ?? true || viewModel?.hasDuplicateNewNames ?? false)
        
        Divider()
        
        Button("Clear All Files") {
            viewModel?.clearFiles()
        }
        .keyboardShortcut(.delete, modifiers: .command)
        .disabled(viewModel?.files.isEmpty ?? true)
    }
}

// MARK: - Edit Menu Commands

struct EditMenuCommands: View {
    @FocusedValue(\.renameViewModel) var viewModel
    @FocusedValue(\.selectedFileIDs) var selectedFileIDs
    
    var body: some View {
        Button(viewModel?.renameUndoManager.undoMenuTitle ?? "Undo") {
            viewModel?.undoLastRename()
        }
        .keyboardShortcut("z", modifiers: .command)
        .disabled(!(viewModel?.renameUndoManager.canUndo ?? false))
        
        Button(viewModel?.renameUndoManager.redoMenuTitle ?? "Redo") {
            viewModel?.redoLastRename()
        }
        .keyboardShortcut("z", modifiers: [.command, .shift])
        .disabled(!(viewModel?.renameUndoManager.canRedo ?? false))
        
        Divider()
        
        Button("Remove Selected") {
            guard let viewModel = viewModel,
                  let selection = selectedFileIDs?.wrappedValue else { return }
            
            let filesToRemove = viewModel.files.filter { selection.contains($0.id) }
            for file in filesToRemove {
                viewModel.removeFile(file)
            }
            selectedFileIDs?.wrappedValue.removeAll()
        }
        .keyboardShortcut(.delete, modifiers: [])
        .disabled(selectedFileIDs?.wrappedValue.isEmpty ?? true)
        
        Divider()
        
        Toggle("Include Extension", isOn: Binding(
            get: { viewModel?.applyToExtension ?? false },
            set: { viewModel?.applyToExtension = $0 }
        ))
        .keyboardShortcut("e", modifiers: .command)
    }
}

// MARK: - Action Menu Commands

struct ActionMenuCommands: View {
    @FocusedValue(\.renameViewModel) var viewModel
    
    var body: some View {
        actionButton(for: .searchReplace, title: "Replace", shortcut: "1")
        actionButton(for: .insert, title: "Insert", shortcut: "2")
        actionButton(for: .remove, title: "Remove", shortcut: "3")
        actionButton(for: .caseChange, title: "Case", shortcut: "4")
        actionButton(for: .numbering, title: "Number", shortcut: "5")
        actionButton(for: .dateTime, title: "Date/Time", shortcut: "6")
        actionButton(for: .exif, title: "Metadata", shortcut: "7")
    }
    
    @ViewBuilder
    private func actionButton(for type: ActionType, title: String, shortcut: Character) -> some View {
        Button {
            viewModel?.selectedActionType = type
        } label: {
            if viewModel?.selectedActionType == type {
                Text("\(Image(systemName: "checkmark")) \(title)")
            } else {
                Text("      \(title)")
            }
        }
        .keyboardShortcut(KeyEquivalent(shortcut), modifiers: .command)
    }
}

// MARK: - Help Menu Commands

struct HelpMenuCommands: View {
    @FocusedValue(\.showOnboarding) var showOnboarding
    
    var body: some View {
        Divider()
        
        Button("Show Onboarding...") {
            showOnboarding?.wrappedValue = true
        }
    }
}
