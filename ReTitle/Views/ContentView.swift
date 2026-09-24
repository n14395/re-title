// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import SwiftUI
import StoreKit

struct ContentView: View {
    /// View model passed from AppDelegate (shared across the app for Services integration)
    @Bindable var viewModel: RenameViewModel
    @Binding var showOnboarding: Bool
    @State private var showingResults = false
    @State private var renameResults: [RenameResult] = []
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Button("Add Files") {
                    viewModel.openFilePicker()
                }

                Button("Clear") {
                    viewModel.clearFiles()
                }
                .disabled(viewModel.files.isEmpty)

                Spacer()
                
                Toggle("Rename file extension", isOn: $viewModel.applyToExtension)
                    .toggleStyle(.checkbox)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Move to:")
                        .foregroundStyle(.secondary)
                    
                    Button(viewModel.destinationFolderName) {
                        viewModel.selectDestinationFolder()
                    }
                    
                    if viewModel.destinationFolder != nil {
                        Button {
                            viewModel.clearDestinationFolder()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()

                Button("Apply") {
                    renameResults = viewModel.applyRenames()
                    showingResults = true
                }
                .disabled(viewModel.files.isEmpty || viewModel.hasDuplicateNewNames)
                .tint(viewModel.files.isEmpty || viewModel.hasDuplicateNewNames ? .gray : .accentColor)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .fixedSize(horizontal: false, vertical: true)

            Divider()

            // File list
            FileListView(viewModel: viewModel)
                .frame(minHeight: 100)
                .layoutPriority(-1)

            Divider()

            // Action tabs (fixed size)
            ActionTabView(viewModel: viewModel)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(minWidth: 800, minHeight: 500)
        .focusedSceneValue(\.renameViewModel, viewModel)
        .focusedSceneValue(\.selectedFileIDs, $viewModel.selectedFileIDs)
        .focusedSceneValue(\.showOnboarding, $showOnboarding)
        .alert("Rename Results", isPresented: $showingResults) {
            Button("OK") {
                showingResults = false
                // Natural resting state: results dismissed after a rename completed.
                ReviewPrompt.requestIfAppropriate(requestReview)
            }
        } message: {
            let successCount = renameResults.filter { $0.success }.count
            let failCount = renameResults.filter { !$0.success }.count
            let errors = renameResults.filter { !$0.success }.compactMap { $0.error }.joined(separator: "\n")
            if renameResults.isEmpty {
                Text("No files needed to be renamed.")
            } else if errors.isEmpty {
                Text("\(successCount) file\(successCount == 1 ? "" : "s") renamed successfully.")
            } else {
                Text("\(successCount) file\(successCount == 1 ? "" : "s") renamed successfully.\n\(failCount) file\(failCount == 1 ? "" : "s") failed.\n\nErrors:\n\(errors)")
            }
        }
    }
}

#Preview {
    @Previewable @State var showOnboarding = false
    ContentView(viewModel: RenameViewModel(), showOnboarding: $showOnboarding)
}
