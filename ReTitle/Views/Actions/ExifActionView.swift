// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import SwiftUI

struct ExifActionView: View {
    @Binding var action: ExifAction

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Media Metadata")
                .font(.headline)

            HStack(spacing: 20) {
                // Metadata field picker organized by category
                VStack(alignment: .leading, spacing: 8) {
                    Text("Metadata Field")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Picker("Field", selection: $action.field) {
                        ForEach(MediaMetadataField.fieldsByCategory, id: \.category) { group in
                            Section(header: Text(group.category.rawValue)) {
                                ForEach(group.fields) { field in
                                    Text(field.rawValue).tag(field)
                                }
                            }
                        }
                    }
                    .labelsHidden()
                    .frame(width: 180)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Position")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Picker("Position", selection: $action.position) {
                        ForEach(MetadataPosition.allCases) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }
            }

            // Date format options (only shown for date fields)
            if action.field.isDateField {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date Format")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Picker("Date Format", selection: $action.dateFormat) {
                            ForEach(MetadataDateFormat.allCases) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 180)
                    }

                    if action.dateFormat == .custom {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Format")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            TextField("yyyy-MM-dd_HH-mm-ss", text: $action.customDateFormat)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 180)
                        }
                    }
                }
            }

            // Duration format options (only shown for duration field)
            if action.field == .duration {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration Format")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Picker("Duration Format", selection: $action.durationFormat) {
                            ForEach(DurationFormat.allCases) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 180)
                    }

                    if action.durationFormat == .custom {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Format")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            TextField("HH-MM-SS", text: $action.customDurationFormat)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 180)
                        }
                    }
                }
            }
            
            // Dimensions format options (only shown for dimensions field)
            if action.field == .dimensions {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dimensions Format")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Picker("Dimensions Format", selection: $action.dimensionsFormat) {
                            ForEach(DimensionsFormat.allCases) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 180)
                    }

                    if action.dimensionsFormat == .custom {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Format")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            TextField("WxH", text: $action.customDimensionsFormat)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 180)
                        }
                    }
                }
            }
            
            // GPS format options (only shown for GPS field)
            if action.field == .gpsCoordinates {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("GPS Format")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Picker("GPS Format", selection: $action.gpsFormat) {
                            ForEach(GPSFormat.allCases) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 180)
                    }

                    if action.gpsFormat == .custom {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Format")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            TextField("LAT,LON", text: $action.customGPSFormat)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 180)
                        }
                    }
                }
            }
            
            // Track number format options (only shown for track number field)
            if action.field == .trackNumber {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Track Format")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Picker("Track Format", selection: $action.trackNumberFormat) {
                            ForEach(TrackNumberFormat.allCases) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 180)
                    }

                    if action.trackNumberFormat == .custom {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Format")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            TextField("NN", text: $action.customTrackNumberFormat)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 180)
                        }
                    }
                }
            }
            
            // Frame rate format options (only shown for frame rate field)
            if action.field == .frameRate {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Frame Rate Format")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Picker("Frame Rate Format", selection: $action.frameRateFormat) {
                            ForEach(FrameRateFormat.allCases) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 180)
                    }

                    if action.frameRateFormat == .custom {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Format")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            TextField("FPSfps", text: $action.customFrameRateFormat)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 180)
                        }
                    }
                }
            }

            HStack(spacing: 20) {
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

                        Text("Before metadata")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("After")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("", text: $action.suffixSeparator)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)

                        Text("After metadata")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                // Separator (not shown for replace or atPosition)
                if action.position != .replace && action.position != .atPosition {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Separator")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("_", text: $action.separator)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Fallback Text")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("unknown", text: $action.fallbackText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)

                    Text("Used when metadata is missing")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            // Category-specific help text
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    switch action.field.category {
                    case .common:
                        EmptyView()
                    case .image:
                        Text("Image fields: JPEG, HEIC, TIFF, PNG, RAW formats")
                    case .video:
                        Text("Video fields: MP4, MOV, MKV, AVI formats")
                    case .audio:
                        Text("Audio fields: MP3, M4A, FLAC, WAV formats")
                    case .document:
                        Text("Document fields: PDF files")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                if action.field.isDateField && action.dateFormat == .custom {
                    Text("Format codes: yyyy=year, MM=month, dd=day, HH=hour, mm=minute, ss=second")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if action.field == .duration && action.durationFormat == .custom {
                    Text("Format codes: HH=hours(padded), H=hours, MM=minutes(padded), M=minutes, SS=seconds(padded), S=seconds, T=total seconds")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if action.field == .dimensions && action.dimensionsFormat == .custom {
                    Text("Format codes: W=width, H=height, MP=megapixels")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if action.field == .gpsCoordinates && action.gpsFormat == .custom {
                    Text("Format codes: LAT=latitude, LON=longitude, ALAT=abs latitude, ALON=abs longitude, NS=N/S, EW=E/W")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if action.field == .trackNumber && action.trackNumberFormat == .custom {
                    Text("Format codes: #N3=track(padded 3), #N2=track(padded 2), #N=track, #T3/#T2/#T=total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if action.field == .frameRate && action.frameRateFormat == .custom {
                    Text("Format codes: FPS=frame rate (2 decimals), F=integer frame rate")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)
        }
    }
}
