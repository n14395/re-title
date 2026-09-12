import SwiftUI

/// First-launch onboarding view explaining folder permissions
struct OnboardingView: View {
    /// Callback when onboarding is complete
    var onComplete: () -> Void
    
    @State private var isRequestingAccess = false
    
    var body: some View {
        VStack(spacing: 24) {
            // App icon or illustration
            Image(systemName: "folder.badge.gearshape")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
                .padding(.top, 20)
            
            Text("Welcome to ReTitle")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Explanation text
            VStack(alignment: .leading, spacing: 16) {
                explanationRow(
                    icon: "lock.shield",
                    title: "Sandbox Security",
                    description: "macOS protects your files by requiring apps to request permission before accessing folders."
                )
                
                explanationRow(
                    icon: "folder",
                    title: "Folder Access Needed",
                    description: "To rename files anywhere on your Mac, ReTitle needs access to a parent folder containing those files."
                )
                
                explanationRow(
                    icon: "checkmark.seal",
                    title: "One-Time Setup",
                    description: "Grant access to your home folder or a parent folder containing files you want to rename. This is saved securely and only needs to be done once."
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button {
                    requestFolderAccess()
                } label: {
                    HStack {
                        Image(systemName: "folder.badge.plus")
                        Text("Grant Folder Access")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isRequestingAccess)
                
                Button("Skip for Now") {
                    completeOnboarding()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .frame(width: 500, height: 520)
    }
    
    private func explanationRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func requestFolderAccess() {
        isRequestingAccess = true
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select a folder to grant ReTitle access.\nChoose a parent folder that contains files you want to rename."
        panel.prompt = "Grant Access"
        
        // Start at the user's home directory (standard macOS convention)
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        
        if panel.runModal() == .OK, let url = panel.url {
            // Store the bookmark for persistent access
            _ = FolderAccessManager.shared.storeAccessBookmark(for: url)
        }
        
        isRequestingAccess = false
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        FolderAccessManager.shared.markOnboardingComplete()
        onComplete()
    }
}

#Preview {
    OnboardingView {
        print("Onboarding complete")
    }
}
