import SwiftUI
import UniformTypeIdentifiers

struct FileListView: View {
    @Bindable var viewModel: RenameViewModel
    @State private var isTargeted = false
    @State private var editingFileID: UUID?
    @State private var showingEditSheet = false
    @State private var editSheetName = ""
    @State private var showingRenameError = false
    @State private var renameErrorMessage = ""
    @State private var showingPermissionError = false
    @State private var permissionErrorFolderURL: URL?
    @State private var draggingFileID: UUID?

    var body: some View {
        Group {
            if viewModel.files.isEmpty {
                emptyState
            } else {
                fileTable
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
            return true
        }
        .background(isTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
        .animation(.easeInOut(duration: 0.2), value: isTargeted)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Drop files here or click Add Files")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }

    /// Set of new names that appear more than once (duplicates)
    private var duplicateNewNames: Set<String> {
        let allNewNames = viewModel.files.enumerated().map { index, file in
            viewModel.previewName(for: file, at: index)
        }
        var seen = Set<String>()
        var duplicates = Set<String>()
        for name in allNewNames {
            if seen.contains(name) {
                duplicates.insert(name)
            } else {
                seen.insert(name)
            }
        }
        return duplicates
    }
    
    private var fileTable: some View {
        let duplicates = duplicateNewNames

        return List(selection: $viewModel.selectedFileIDs) {
            ForEach(Array(viewModel.files.enumerated()), id: \.element.id) { index, file in
                let result = viewModel.previewResult(for: file, at: index)
                let isDuplicate = duplicates.contains(result.newName)

                HStack(spacing: 0) {
                    // Original Name column
                    HStack {
                        Image(systemName: iconForFile(file))
                            .foregroundStyle(.secondary)
                        highlightedOriginalName(original: file.originalName, deletedRanges: result.deletedRanges)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)

                    // New Name column
                    HStack {
                        highlightedNewName(result: result, isDuplicate: isDuplicate)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)

                    // Remove button
                    Button {
                        viewModel.removeFile(file)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 30)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                .opacity(draggingFileID == file.id ? 0.5 : 1.0)
                .onDrag {
                    draggingFileID = file.id
                    return NSItemProvider(object: file.id.uuidString as NSString)
                }
                .onDrop(of: [.text], delegate: FileDropDelegate(
                    fileID: file.id,
                    files: $viewModel.files,
                    draggingFileID: $draggingFileID
                ))
            }
            .onMove { source, destination in
                viewModel.moveFiles(fromOffsets: source, toOffset: destination)
            }

            // Drop zone at the end of the list for dropping items to the last position
            if draggingFileID != nil {
                Color.clear
                    .frame(height: 20)
                    .onDrop(of: [.text], delegate: EndDropDelegate(
                        files: $viewModel.files,
                        draggingFileID: $draggingFileID
                    ))
            }
        }
        .contextMenu(forSelectionType: UUID.self) { selectedIDs in
            let selectedFiles = viewModel.files.filter { selectedIDs.contains($0.id) }
            let isSingleSelection = selectedFiles.count == 1
            
            // Edit Name - only enabled for single selection
            Button {
                if let file = selectedFiles.first {
                    editingFileID = file.id
                    editSheetName = file.originalName
                    showingEditSheet = true
                }
            } label: {
                Label("Edit Name", systemImage: "pencil")
            }
            .disabled(!isSingleSelection)
            
            // Reveal in Finder - works for multiple files
            Button {
                let urls = selectedFiles.map { $0.url }
                NSWorkspace.shared.activateFileViewerSelecting(urls)
            } label: {
                Label("Reveal in Finder", systemImage: "folder")
            }
            
            Divider()
            
            // Remove - works for multiple files
            Button(role: .destructive) {
                for file in selectedFiles {
                    viewModel.removeFile(file)
                }
            } label: {
                Label(selectedFiles.count > 1 ? "Remove \(selectedFiles.count) Files" : "Remove", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditNameView(
                name: $editSheetName,
                onSave: {
                    if let fileID = editingFileID,
                       let file = viewModel.files.first(where: { $0.id == fileID }) {
                        if let error = viewModel.renameFileOnDisk(file, to: editSheetName) {
                            if error.isPermissionError, let folderURL = error.folderURL {
                                permissionErrorFolderURL = folderURL
                                renameErrorMessage = error.message
                                showingPermissionError = true
                            } else {
                                renameErrorMessage = error.message
                                showingRenameError = true
                            }
                        }
                    }
                    showingEditSheet = false
                    editingFileID = nil
                },
                onCancel: {
                    showingEditSheet = false
                    editingFileID = nil
                }
            )
        }
        .alert("Rename Failed", isPresented: $showingRenameError) {
            Button("OK") { }
        } message: {
            Text(renameErrorMessage)
        }
        .alert("Permission Required", isPresented: $showingPermissionError) {
            Button("Grant Access") {
                if let folderURL = permissionErrorFolderURL {
                    _ = FolderAccessManager.shared.requestAccess(for: folderURL)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if let folderURL = permissionErrorFolderURL {
                Text("ReTitle needs permission to access \"\(folderURL.lastPathComponent)\" to rename files.\n\n\(renameErrorMessage)")
            } else {
                Text(renameErrorMessage)
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    return
                }

                DispatchQueue.main.async {
                    viewModel.addFiles(urls: [url])
                }
            }
        }
    }

    // MARK: - Highlighting
    
    /// Creates a Text view for the original name with deleted portions highlighted in blue with strikethrough
    @ViewBuilder
    private func highlightedOriginalName(original: String, deletedRanges: [Range<Int>]) -> some View {
        if deletedRanges.isEmpty {
            Text(original)
        } else {
            Text(attributedOriginal(original: original, deletedRanges: deletedRanges))
        }
    }
    
    /// Creates a Text view for the new name with changed portions highlighted in blue, or red background if duplicate
    @ViewBuilder
    private func highlightedNewName(result: RenamePreviewResult, isDuplicate: Bool) -> some View {
        if isDuplicate {
            Text(result.newName)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.red.opacity(0.3))
                .cornerRadius(4)
        } else if result.changedRanges.isEmpty {
            Text(result.newName)
                .foregroundStyle(.secondary)
        } else {
            Text(attributedNewName(result: result))
        }
    }
    
    /// Creates an AttributedString for the original name with deleted ranges in blue with strikethrough
    private func attributedOriginal(original: String, deletedRanges: [Range<Int>]) -> AttributedString {
        var result = AttributedString(original)
        
        for range in deletedRanges {
            // Clamp range to valid bounds
            let start = max(0, min(range.lowerBound, original.count))
            let end = max(start, min(range.upperBound, original.count))
            
            guard start < end else { continue }
            
            let startIndex = result.index(result.startIndex, offsetByCharacters: start)
            let endIndex = result.index(result.startIndex, offsetByCharacters: end)
            result[startIndex..<endIndex].foregroundColor = .blue
            result[startIndex..<endIndex].strikethroughStyle = .single
        }
        
        return result
    }
    
    /// Creates an AttributedString for the new name with changed ranges in blue
    private func attributedNewName(result: RenamePreviewResult) -> AttributedString {
        var attributed = AttributedString(result.newName)
        
        for range in result.changedRanges {
            // Clamp range to valid bounds
            let start = max(0, min(range.lowerBound, result.newName.count))
            let end = max(start, min(range.upperBound, result.newName.count))
            
            guard start < end else { continue }
            
            let startIndex = attributed.index(attributed.startIndex, offsetByCharacters: start)
            let endIndex = attributed.index(attributed.startIndex, offsetByCharacters: end)
            attributed[startIndex..<endIndex].foregroundColor = .blue
        }
        
        return attributed
    }
    
    private func iconForFile(_ file: RenameFile) -> String {
        let ext = file.fileExtension.lowercased()
        switch ext {
        case "jpg", "jpeg", "png", "gif", "heic", "webp":
            return "photo"
        case "mp4", "mov", "avi", "mkv":
            return "film"
        case "mp3", "wav", "aac", "flac":
            return "music.note"
        case "pdf":
            return "doc.richtext"
        case "txt", "md":
            return "doc.text"
        case "zip", "rar", "7z":
            return "archivebox"
        default:
            return "doc"
        }
    }
}

struct EditNameView: View {
    @Binding var name: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Edit File Name")
                .font(.headline)
            
            TextField("File name", text: $name)
                .textFieldStyle(.roundedBorder)
                .focused($isTextFieldFocused)
                .onSubmit {
                    if !name.isEmpty {
                        onSave()
                    }
                }
            
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save") {
                    onSave()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(width: 350)
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

struct FileDropDelegate: DropDelegate {
    let fileID: UUID
    @Binding var files: [RenameFile]
    @Binding var draggingFileID: UUID?

    func dropEntered(info: DropInfo) {
        guard let dragID = draggingFileID, dragID != fileID else { return }

        guard let fromIndex = files.firstIndex(where: { $0.id == dragID }),
              let toIndex = files.firstIndex(where: { $0.id == fileID }) else { return }

        if fromIndex != toIndex {
            withAnimation(.easeInOut(duration: 0.2)) {
                files.move(fromOffsets: IndexSet(integer: fromIndex),
                          toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingFileID = nil
        return true
    }
}

struct EndDropDelegate: DropDelegate {
    @Binding var files: [RenameFile]
    @Binding var draggingFileID: UUID?

    func dropEntered(info: DropInfo) {
        guard let dragID = draggingFileID else { return }
        guard let fromIndex = files.firstIndex(where: { $0.id == dragID }) else { return }

        let toIndex = files.count
        if fromIndex != toIndex - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                files.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex)
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingFileID = nil
        return true
    }
}
