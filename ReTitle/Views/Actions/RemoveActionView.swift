import SwiftUI

struct RemoveActionView: View {
    @Binding var action: RemoveAction

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Remove Characters")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Remove Mode")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Mode", selection: $action.mode) {
                    ForEach(RemoveMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
            }

            HStack(spacing: 20) {
                switch action.mode {
                case .firstN, .lastN:
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number of Characters")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("0", value: $action.count, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }

                case .range:
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start Position")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("0", value: $action.rangeStart, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("End Position")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("0", value: $action.rangeEnd, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }

                case .specific:
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Characters to Remove")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("e.g. -_@", text: $action.specificChars)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)
                    }
                }
            }
        }
    }
}
