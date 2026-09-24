// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import SwiftUI

struct DateTimeActionView: View {
    @Binding var action: DateTimeAction

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insert Date/Time")
                .font(.headline)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Source")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Picker("Source", selection: $action.source) {
                        ForEach(DateTimeSource.allCases) { source in
                            Text(source.rawValue).tag(source)
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
                        ForEach(DateTimePosition.allCases) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }
            }

            HStack(spacing: 20) {
                if action.source == .currentDate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date Format")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("yyyy-MM-dd", text: $action.format)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)
                        
                        Text("yyyy=year  MM=month  dd=day  HH=hour  mm=min  ss=sec")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Text")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("Enter text", text: $action.customText)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)
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
