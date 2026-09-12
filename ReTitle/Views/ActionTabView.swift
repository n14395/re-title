import SwiftUI

struct ActionTabView: View {
    @Bindable var viewModel: RenameViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(ActionType.allCases) { actionType in
                    TabButton(
                        title: actionType.rawValue,
                        isSelected: viewModel.selectedActionType == actionType
                    ) {
                        viewModel.selectedActionType = actionType
                    }
                }
            }
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Action content - use ZStack to maintain consistent size across all tabs
            ZStack(alignment: .topLeading) {
                // Hidden views to reserve space for all tabs (disabled to prevent tab focus)
                CaseActionView(action: .constant(CaseAction()))
                    .opacity(0)
                    .disabled(true)
                    .accessibilityHidden(true)
                DateTimeActionView(action: .constant(DateTimeAction()))
                    .opacity(0)
                    .disabled(true)
                    .accessibilityHidden(true)
                ExifActionView(action: .constant(ExifAction()))
                    .opacity(0)
                    .disabled(true)
                    .accessibilityHidden(true)
                InsertActionView(action: .constant(InsertAction()))
                    .opacity(0)
                    .disabled(true)
                    .accessibilityHidden(true)
                NumberingActionView(action: .constant(NumberingAction()))
                    .opacity(0)
                    .disabled(true)
                    .accessibilityHidden(true)
                RemoveActionView(action: .constant(RemoveAction()))
                    .opacity(0)
                    .disabled(true)
                    .accessibilityHidden(true)
                SearchReplaceActionView(action: .constant(SearchReplaceAction()))
                    .opacity(0)
                    .disabled(true)
                    .accessibilityHidden(true)
                
                // Visible content
                actionContent
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    @ViewBuilder
    private var actionContent: some View {
        switch viewModel.selectedActionType {
        case .caseChange:
            CaseActionView(action: $viewModel.caseAction)
        case .dateTime:
            DateTimeActionView(action: $viewModel.dateTimeAction)
        case .exif:
            ExifActionView(action: $viewModel.exifAction)
        case .insert:
            InsertActionView(action: $viewModel.insertAction)
        case .numbering:
            NumberingActionView(action: $viewModel.numberingAction)
        case .remove:
            RemoveActionView(action: $viewModel.removeAction)
        case .searchReplace:
            SearchReplaceActionView(action: $viewModel.searchReplaceAction)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
                .foregroundStyle(isSelected ? Color.accentColor : .primary)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
