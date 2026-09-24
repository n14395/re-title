// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import SwiftUI

struct NumberingActionView: View {
    @Binding var action: NumberingAction

    private var positionOptions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Position")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("Position", selection: $action.position) {
                ForEach(NumberPosition.allCases) { position in
                    Text(position.rawValue).tag(position)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
        }
    }

    private var paddingOptions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Padding")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("Padding", selection: $action.padding) {
                ForEach(NumberPadding.allCases) { padding in
                    Text(padding.rawValue).tag(padding)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Numbering")
                .font(.headline)

            // Side by side when the window is wide enough, stacked at narrow widths —
            // together the two segmented pickers outgrow the window's minimum width.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 20) {
                    positionOptions
                    paddingOptions
                }

                VStack(alignment: .leading, spacing: 16) {
                    positionOptions
                    paddingOptions
                }
            }

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start Number")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("1", value: $action.startNumber, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Increment")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("1", value: $action.increment, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }

                if action.padding == .fixed {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fixed Width")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("3", value: $action.fixedWidth, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                    }
                }

                // Position index (only shown for "At Position")
                if action.position == .atPosition {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Insert At")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("0", value: $action.insertPosition, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)

                        Text("Character index")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Before")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("", text: $action.prefixSeparator)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("After")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("", text: $action.suffixSeparator)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                    }
                }

                // Separator (only for prefix/suffix positions)
                if action.position == .prefix || action.position == .suffix {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Separator")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("_", text: $action.separator)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                    }
                }
            }
        }
    }
}
