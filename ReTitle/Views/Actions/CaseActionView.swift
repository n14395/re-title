import SwiftUI

struct CaseActionView: View {
    @Binding var action: CaseAction

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Change Case")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(CaseType.allCases) { caseType in
                    Button {
                        action.caseType = caseType
                    } label: {
                        Text(caseType.rawValue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(action.caseType == caseType ? Color.accentColor : Color.secondary.opacity(0.2))
                            .foregroundStyle(action.caseType == caseType ? .white : .primary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
