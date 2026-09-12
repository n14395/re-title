import SwiftUI

struct SearchReplaceActionView: View {
    @Binding var action: SearchReplaceAction

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search & Replace")
                .font(.headline)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Search For")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("Search text", text: $action.searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Replace With")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("Replacement text", text: $action.replaceText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                }
            }

            HStack(spacing: 20) {
                Toggle("Use Regular Expression", isOn: $action.useRegex)
                Toggle("Case Sensitive", isOn: $action.caseSensitive)
                Toggle("Replace All Occurrences", isOn: $action.replaceAll)
            }
        }
    }
}
