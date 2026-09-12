import SwiftUI

struct InsertActionView: View {
    @Binding var action: InsertAction

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insert / Overwrite Text")
                .font(.headline)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mode")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Picker("Mode", selection: $action.mode) {
                        ForEach(InsertMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Position")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Picker("Position", selection: $action.position) {
                        ForEach(InsertPosition.allCases) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }
            }

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Text to Insert")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("Enter text", text: $action.text)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                }

                if action.position == .position {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Position Index")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("0", value: $action.positionIndex, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                    }
                }

                if action.mode == .overwrite {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Characters to Replace")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("0", value: $action.overwriteLength, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                    }
                }
            }
        }
    }
}
