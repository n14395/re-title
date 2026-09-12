import Foundation
import ImageIO
import AVFoundation
import CoreLocation
import PDFKit

// MARK: - Media Field Categories

/// Categories of metadata fields organized by media type
enum MediaFieldCategory: String, CaseIterable, Identifiable {
    case common = "Common"
    case image = "Image"
    case video = "Video"
    case audio = "Audio"
    case document = "Document"

    var id: String { rawValue }
}

/// Represents different metadata fields that can be used for renaming
enum MediaMetadataField: String, CaseIterable, Identifiable {
    // Common fields (available across multiple media types)
    case creationDate = "Creation Date"
    case modificationDate = "Modification Date"
    case duration = "Duration"
    case dimensions = "Dimensions"
    case gpsCoordinates = "GPS Coordinates"

    // Image-specific fields
    case cameraMake = "Camera Make"
    case cameraModel = "Camera Model"
    case lensModel = "Lens Model"
    case focalLength = "Focal Length"
    case aperture = "Aperture"
    case shutterSpeed = "Shutter Speed"
    case iso = "ISO"
    case colorSpace = "Color Space"
    case colorProfile = "Color Profile"

    // Video-specific fields
    case videoCodec = "Video Codec"
    case frameRate = "Frame Rate"
    case videoBitrate = "Video Bitrate"
    case audioCodec = "Audio Codec"
    case audioBitrate = "Audio Bitrate"
    case audioSampleRate = "Audio Sample Rate"
    case audioChannels = "Audio Channels"

    // Audio-specific fields (for music files)
    case title = "Title"
    case artist = "Artist"
    case albumArtist = "Album Artist"
    case album = "Album"
    case composer = "Composer"
    case genre = "Genre"
    case year = "Year"
    case trackNumber = "Track Number"
    case discNumber = "Disc Number"
    case bpm = "BPM"

    // Document-specific fields
    case author = "Author"
    case subject = "Subject"
    case keywords = "Keywords"
    case creator = "Creator App"
    case pageCount = "Page Count"
    case pdfVersion = "PDF Version"

    var id: String { rawValue }

    /// The category this field belongs to
    var category: MediaFieldCategory {
        switch self {
        case .creationDate, .modificationDate, .duration, .dimensions, .gpsCoordinates:
            return .common
        case .cameraMake, .cameraModel, .lensModel, .focalLength, .aperture, .shutterSpeed, .iso, .colorSpace, .colorProfile:
            return .image
        case .videoCodec, .frameRate, .videoBitrate, .audioCodec, .audioBitrate, .audioSampleRate, .audioChannels:
            return .video
        case .title, .artist, .albumArtist, .album, .composer, .genre, .year, .trackNumber, .discNumber, .bpm:
            return .audio
        case .author, .subject, .keywords, .creator, .pageCount, .pdfVersion:
            return .document
        }
    }

    /// Fields organized by category for picker display
    static var fieldsByCategory: [(category: MediaFieldCategory, fields: [MediaMetadataField])] {
        MediaFieldCategory.allCases.map { category in
            (category, allCases.filter { $0.category == category })
        }
    }

    /// Whether this field represents a date (for format options)
    var isDateField: Bool {
        switch self {
        case .creationDate, .modificationDate, .year:
            return true
        default:
            return false
        }
    }
}

/// Position where the metadata should be inserted
enum MetadataPosition: String, CaseIterable, Identifiable {
    case prefix = "Before Name"
    case suffix = "After Name"
    case atPosition = "At Position"
    case replace = "Replace Name"

    var id: String { rawValue }
}

/// Date format options for date fields
enum MetadataDateFormat: String, CaseIterable, Identifiable {
    case iso = "yyyy-MM-dd"
    case isoWithTime = "yyyy-MM-dd_HH-mm-ss"
    case compact = "yyyyMMdd"
    case compactWithTime = "yyyyMMdd_HHmmss"
    case yearOnly = "yyyy"
    case yearMonth = "yyyy-MM"
    case custom = "Custom"

    var id: String { rawValue }

    var formatString: String {
        switch self {
        case .iso: return "yyyy-MM-dd"
        case .isoWithTime: return "yyyy-MM-dd_HH-mm-ss"
        case .compact: return "yyyyMMdd"
        case .compactWithTime: return "yyyyMMdd_HHmmss"
        case .yearOnly: return "yyyy"
        case .yearMonth: return "yyyy-MM"
        case .custom: return ""
        }
    }
}

/// Duration format options
enum DurationFormat: String, CaseIterable, Identifiable {
    case colonSeparated = "H:MM:SS"
    case hhmmss = "HH-MM-SS"
    case hms = "HhMmSs"
    case totalSeconds = "Total Seconds"
    case totalMinutes = "Total Minutes"
    case custom = "Custom"

    var id: String { rawValue }
    
    /// The format pattern for this duration format
    var formatPattern: String {
        switch self {
        case .colonSeparated: return "H:MM:SS"
        case .hhmmss: return "HH-MM-SS"
        case .hms: return "HhMmSs"
        case .totalSeconds: return "Xs"
        case .totalMinutes: return "X.Xmin"
        case .custom: return ""
        }
    }
}

/// Dimensions format options
enum DimensionsFormat: String, CaseIterable, Identifiable {
    case standard = "1920x1080"
    case hyphen = "1920-1080"
    case underscore = "1920_1080"
    case widthOnly = "Width Only"
    case heightOnly = "Height Only"
    case megapixels = "Megapixels"
    case custom = "Custom"
    
    var id: String { rawValue }
}

/// GPS coordinate format options
enum GPSFormat: String, CaseIterable, Identifiable {
    case decimal = "37.7749,-122.4194"
    case decimalPositive = "37.7749,122.4194"
    case degrees = "37°46'N 122°25'W"
    case compact = "37.7749N122.4194W"
    case custom = "Custom"
    
    var id: String { rawValue }
}

/// Track number format options
enum TrackNumberFormat: String, CaseIterable, Identifiable {
    case paddedTwo = "01"
    case paddedThree = "001"
    case noPadding = "1"
    case withTotal = "01-12"
    case withTotalSlash = "01/12"
    case custom = "Custom"
    
    var id: String { rawValue }
}

/// Frame rate format options
enum FrameRateFormat: String, CaseIterable, Identifiable {
    case withFps = "29.97fps"
    case rounded = "30fps"
    case decimalOnly = "29.97"
    case integerOnly = "30"
    case custom = "Custom"
    
    var id: String { rawValue }
}

// MARK: - Media Metadata Container

/// Stores extracted metadata for any media file type
struct MediaMetadata {
    // Common fields
    var creationDate: Date?
    var modificationDate: Date?
    var duration: TimeInterval?
    var width: Int?
    var height: Int?
    var latitude: Double?
    var longitude: Double?

    // Image fields
    var cameraMake: String?
    var cameraModel: String?
    var lensModel: String?
    var focalLength: Double?
    var aperture: Double?
    var shutterSpeed: String?
    var iso: Int?
    var colorSpace: String?
    var colorProfile: String?

    // Video fields
    var videoCodec: String?
    var frameRate: Double?
    var videoBitrate: Int?
    var audioCodec: String?
    var audioBitrate: Int?
    var audioSampleRate: Double?
    var audioChannels: Int?

    // Audio fields
    var title: String?
    var artist: String?
    var albumArtist: String?
    var album: String?
    var composer: String?
    var genre: String?
    var year: Int?
    var trackNumber: Int?
    var trackTotal: Int?
    var discNumber: Int?
    var discTotal: Int?
    var bpm: Int?

    // Document fields
    var author: String?
    var subject: String?
    var keywords: String?
    var creator: String?
    var pageCount: Int?
    var pdfVersion: String?

    // MARK: - Extraction Methods
    
    private static let imageExtensions = ["jpg", "jpeg", "heic", "heif", "png", "tiff", "tif", "gif", "bmp", "webp", "raw", "cr2", "cr3", "nef", "arw", "dng", "orf", "rw2"]
    private static let videoExtensions = ["mp4", "m4v", "mov", "avi", "mkv", "wmv", "flv", "webm", "mpeg", "mpg", "3gp", "mts", "m2ts"]
    private static let audioExtensions = ["mp3", "m4a", "aac", "flac", "wav", "aiff", "aif", "ogg", "wma", "alac", "ape", "opus"]

    /// Main extraction method that determines file type and delegates appropriately
    /// Note: For video/audio files, use extractAsync() instead to avoid blocking the main thread
    static func extract(from url: URL) -> MediaMetadata? {
        let pathExtension = url.pathExtension.lowercased()

        // Image formats
        if imageExtensions.contains(pathExtension) {
            return extractImageMetadata(from: url)
        }

        // Video/Audio formats - return file system metadata only (use extractAsync for full metadata)
        if videoExtensions.contains(pathExtension) || audioExtensions.contains(pathExtension) {
            return extractFileSystemMetadata(from: url)
        }

        // PDF
        if pathExtension == "pdf" {
            return extractPDFMetadata(from: url)
        }

        // Fallback: try file system dates
        return extractFileSystemMetadata(from: url)
    }
    
    /// Async extraction method for use from background threads
    static func extractAsync(from url: URL) async -> MediaMetadata? {
        let pathExtension = url.pathExtension.lowercased()

        // Image formats - these are fast, no need for special handling
        if imageExtensions.contains(pathExtension) {
            return extractImageMetadata(from: url)
        }

        // Video formats - use async AVAsset loading
        if videoExtensions.contains(pathExtension) {
            return await extractAVMetadataAsync(from: url, isVideo: true)
        }

        // Audio formats - use async AVAsset loading
        if audioExtensions.contains(pathExtension) {
            return await extractAVMetadataAsync(from: url, isVideo: false)
        }

        // PDF
        if pathExtension == "pdf" {
            return extractPDFMetadata(from: url)
        }

        // Fallback: try file system dates
        return extractFileSystemMetadata(from: url)
    }

    /// Extract metadata from image files using ImageIO
    private static func extractImageMetadata(from url: URL) -> MediaMetadata? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return extractFileSystemMetadata(from: url)
        }

        var metadata = MediaMetadata()

        // Extract EXIF dictionary
        if let exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            // Date taken
            if let dateString = exif[kCGImagePropertyExifDateTimeOriginal as String] as? String {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                metadata.creationDate = formatter.date(from: dateString)
            }

            // Lens model
            metadata.lensModel = exif[kCGImagePropertyExifLensModel as String] as? String

            // Focal length
            metadata.focalLength = exif[kCGImagePropertyExifFocalLength as String] as? Double

            // Aperture (F-number)
            metadata.aperture = exif[kCGImagePropertyExifFNumber as String] as? Double

            // Shutter speed (exposure time)
            if let exposureTime = exif[kCGImagePropertyExifExposureTime as String] as? Double {
                if exposureTime >= 1 {
                    metadata.shutterSpeed = String(format: "%.1fs", exposureTime)
                } else {
                    let denominator = Int(round(1.0 / exposureTime))
                    metadata.shutterSpeed = "1/\(denominator)s"
                }
            }

            // ISO
            if let isoArray = exif[kCGImagePropertyExifISOSpeedRatings as String] as? [Int],
               let iso = isoArray.first {
                metadata.iso = iso
            }

            // Dimensions from EXIF
            metadata.width = exif[kCGImagePropertyExifPixelXDimension as String] as? Int
            metadata.height = exif[kCGImagePropertyExifPixelYDimension as String] as? Int

            // Color space
            if let colorSpace = exif[kCGImagePropertyExifColorSpace as String] as? Int {
                metadata.colorSpace = colorSpace == 1 ? "sRGB" : "Adobe RGB"
            }
        }

        // Extract TIFF dictionary (camera make/model)
        if let tiff = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
            metadata.cameraMake = tiff[kCGImagePropertyTIFFMake as String] as? String
            metadata.cameraModel = tiff[kCGImagePropertyTIFFModel as String] as? String
        }

        // Extract GPS dictionary
        if let gps = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            if let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double,
               let latRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String {
                metadata.latitude = latRef == "S" ? -lat : lat
            }
            if let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double,
               let lonRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String {
                metadata.longitude = lonRef == "W" ? -lon : lon
            }
        }

        // Color profile from main properties
        if let profileName = properties[kCGImagePropertyProfileName as String] as? String {
            metadata.colorProfile = profileName
        }

        // Fallback dimensions from image properties
        if metadata.width == nil {
            metadata.width = properties[kCGImagePropertyPixelWidth as String] as? Int
        }
        if metadata.height == nil {
            metadata.height = properties[kCGImagePropertyPixelHeight as String] as? Int
        }

        // Add file system dates as fallback
        addFileSystemDates(to: &metadata, from: url)

        return metadata
    }

    /// Async version of extractAVMetadata that properly loads asset properties
    private static func extractAVMetadataAsync(from url: URL, isVideo: Bool) async -> MediaMetadata? {
        let asset = AVURLAsset(url: url)
        var metadata = MediaMetadata()
        
        do {
            // Load properties asynchronously
            let (duration, creationDate, commonMetadata, allMetadata) = try await asset.load(
                .duration,
                .creationDate,
                .commonMetadata,
                .metadata
            )
            
            // Duration
            if duration.isValid && !duration.isIndefinite {
                metadata.duration = CMTimeGetSeconds(duration)
            }
            
            // Creation date from asset
            if let creationDateItem = creationDate {
                metadata.creationDate = try? await creationDateItem.load(.dateValue)
            }
            
            // Extract common metadata
            for item in commonMetadata {
                guard let key = item.commonKey?.rawValue else { continue }
                
                switch key {
                case AVMetadataKey.commonKeyTitle.rawValue:
                    metadata.title = try? await item.load(.stringValue)
                case AVMetadataKey.commonKeyArtist.rawValue:
                    metadata.artist = try? await item.load(.stringValue)
                case AVMetadataKey.commonKeyAlbumName.rawValue:
                    metadata.album = try? await item.load(.stringValue)
                case AVMetadataKey.commonKeyAuthor.rawValue:
                    metadata.author = try? await item.load(.stringValue)
                case AVMetadataKey.commonKeyCreator.rawValue:
                    metadata.creator = try? await item.load(.stringValue)
                case AVMetadataKey.commonKeySubject.rawValue:
                    metadata.subject = try? await item.load(.stringValue)
                case AVMetadataKey.commonKeyCreationDate.rawValue:
                    if metadata.creationDate == nil, let dateString = try? await item.load(.stringValue) {
                        metadata.creationDate = parseDate(from: dateString)
                    }
                case AVMetadataKey.commonKeyLocation.rawValue:
                    if let location = try? await item.load(.stringValue) {
                        parseGPSFromString(location, into: &metadata)
                    }
                default:
                    break
                }
            }
            
            // Extract format-specific metadata
            await extractFormatSpecificMetadataAsync(from: allMetadata, into: &metadata)
            
            // Load tracks asynchronously
            if isVideo {
                let videoTracks = try? await asset.loadTracks(withMediaType: .video)
                if let videoTrack = videoTracks?.first {
                    let (naturalSize, preferredTransform, nominalFrameRate, estimatedDataRate, formatDescriptions) = try await videoTrack.load(
                        .naturalSize,
                        .preferredTransform,
                        .nominalFrameRate,
                        .estimatedDataRate,
                        .formatDescriptions
                    )
                    
                    // Handle rotated videos
                    if preferredTransform.a == 0 && preferredTransform.d == 0 {
                        metadata.width = Int(abs(naturalSize.height))
                        metadata.height = Int(abs(naturalSize.width))
                    } else {
                        metadata.width = Int(abs(naturalSize.width))
                        metadata.height = Int(abs(naturalSize.height))
                    }
                    metadata.frameRate = Double(nominalFrameRate)
                    metadata.videoBitrate = Int(estimatedDataRate)
                    
                    if let formatDescription = formatDescriptions.first {
                        let codec = CMFormatDescriptionGetMediaSubType(formatDescription)
                        metadata.videoCodec = fourCCToString(codec)
                    }
                }
            }
            
            // Audio track information
            let audioTracks = try? await asset.loadTracks(withMediaType: .audio)
            if let audioTrack = audioTracks?.first {
                let (estimatedDataRate, formatDescriptions) = try await audioTrack.load(
                    .estimatedDataRate,
                    .formatDescriptions
                )
                
                metadata.audioBitrate = Int(estimatedDataRate)
                
                if let formatDescription = formatDescriptions.first {
                    let codec = CMFormatDescriptionGetMediaSubType(formatDescription)
                    metadata.audioCodec = fourCCToString(codec)
                    
                    if let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription)?.pointee {
                        metadata.audioSampleRate = asbd.mSampleRate
                        metadata.audioChannels = Int(asbd.mChannelsPerFrame)
                    }
                }
            }
            
        } catch {
            // Fall back to file system metadata on error
            addFileSystemDates(to: &metadata, from: url)
        }
        
        // Add file system dates as fallback
        addFileSystemDates(to: &metadata, from: url)
        
        return metadata
    }
    
    /// Async version of format-specific metadata extraction
    private static func extractFormatSpecificMetadataAsync(from allMetadata: [AVMetadataItem], into metadata: inout MediaMetadata) async {
        // ID3 metadata for MP3
        let id3Metadata = AVMetadataItem.metadataItems(from: allMetadata, filteredByIdentifier: .id3MetadataAlbumTitle)
        if let albumItem = id3Metadata.first {
            metadata.album = try? await albumItem.load(.stringValue)
        }
        
        // iTunes metadata
        let itunesMetadata = allMetadata.filter { item in
            item.keySpace == .iTunes || item.keySpace == .id3
        }
        
        for item in itunesMetadata {
            if let key = item.key as? String {
                switch key {
                case "com.apple.iTunes.albumartist", "TPE2":
                    metadata.albumArtist = try? await item.load(.stringValue)
                case "com.apple.iTunes.composer", "TCOM":
                    metadata.composer = try? await item.load(.stringValue)
                case "gnre", "TCON":
                    metadata.genre = try? await item.load(.stringValue)
                case "trkn":
                    if let data = try? await item.load(.dataValue) {
                        if data.count >= 4 {
                            metadata.trackNumber = Int(data[3])
                            if data.count >= 6 {
                                metadata.trackTotal = Int(data[5])
                            }
                        }
                    } else if let value = try? await item.load(.value) as? String {
                        let parts = value.split(separator: "/")
                        if let first = parts.first, let num = Int(first) {
                            metadata.trackNumber = num
                        }
                    }
                case "disk":
                    if let data = try? await item.load(.dataValue), data.count >= 4 {
                        metadata.discNumber = Int(data[3])
                        if data.count >= 6 {
                            metadata.discTotal = Int(data[5])
                        }
                    }
                case "tmpo":
                    if let bpmValue = try? await item.load(.value) {
                        if let bpm = bpmValue as? Int {
                            metadata.bpm = bpm
                        } else if let bpmString = bpmValue as? String, let bpm = Int(bpmString) {
                            metadata.bpm = bpm
                        }
                    }
                case "TYER", "TDRC", "\u{00A9}day":
                    if let yearString = try? await item.load(.stringValue) {
                        let yearPart = String(yearString.prefix(4))
                        metadata.year = Int(yearPart)
                    }
                default:
                    break
                }
            }
        }
    }

    /// Extract metadata from PDF files
    private static func extractPDFMetadata(from url: URL) -> MediaMetadata? {
        guard let pdfDocument = PDFDocument(url: url) else {
            return extractFileSystemMetadata(from: url)
        }

        var metadata = MediaMetadata()

        // Page count
        metadata.pageCount = pdfDocument.pageCount

        // Get page dimensions from first page
        if let firstPage = pdfDocument.page(at: 0) {
            let bounds = firstPage.bounds(for: .mediaBox)
            metadata.width = Int(bounds.width)
            metadata.height = Int(bounds.height)
        }

        // Document attributes
        if let attributes = pdfDocument.documentAttributes {
            metadata.title = attributes[PDFDocumentAttribute.titleAttribute] as? String
            metadata.author = attributes[PDFDocumentAttribute.authorAttribute] as? String
            metadata.subject = attributes[PDFDocumentAttribute.subjectAttribute] as? String
            metadata.creator = attributes[PDFDocumentAttribute.creatorAttribute] as? String

            if let keywords = attributes[PDFDocumentAttribute.keywordsAttribute] as? [String] {
                metadata.keywords = keywords.joined(separator: ", ")
            } else if let keywords = attributes[PDFDocumentAttribute.keywordsAttribute] as? String {
                metadata.keywords = keywords
            }

            if let creationDate = attributes[PDFDocumentAttribute.creationDateAttribute] as? Date {
                metadata.creationDate = creationDate
            }
            if let modDate = attributes[PDFDocumentAttribute.modificationDateAttribute] as? Date {
                metadata.modificationDate = modDate
            }
        }

        // PDF version
        metadata.pdfVersion = "\(pdfDocument.majorVersion).\(pdfDocument.minorVersion)"

        // Add file system dates as fallback
        addFileSystemDates(to: &metadata, from: url)

        return metadata
    }

    /// Extract basic file system metadata (fallback)
    private static func extractFileSystemMetadata(from url: URL) -> MediaMetadata? {
        var metadata = MediaMetadata()
        addFileSystemDates(to: &metadata, from: url)
        return metadata.creationDate != nil ? metadata : nil
    }

    /// Add file system dates to metadata
    private static func addFileSystemDates(to metadata: inout MediaMetadata, from url: URL) {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if metadata.creationDate == nil {
                metadata.creationDate = attributes[.creationDate] as? Date
            }
            if metadata.modificationDate == nil {
                metadata.modificationDate = attributes[.modificationDate] as? Date
            }
        } catch {
            // Ignore file system errors
        }
    }

    /// Parse various date formats
    private static func parseDate(from string: String) -> Date? {
        let formatters: [DateFormatter] = {
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ssZ",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd HH:mm:ss",
                "yyyy:MM:dd HH:mm:ss",
                "yyyy-MM-dd",
                "yyyy"
            ]
            return formats.map { format in
                let formatter = DateFormatter()
                formatter.dateFormat = format
                return formatter
            }
        }()

        for formatter in formatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }

    /// Parse GPS coordinates from string
    private static func parseGPSFromString(_ string: String, into metadata: inout MediaMetadata) {
        // Format: "+37.7749-122.4194/" or "37.7749,-122.4194"
        let cleaned = string.replacingOccurrences(of: "/", with: "")
        let pattern = "([+-]?\\d+\\.\\d+)[,\\s]*([+-]?\\d+\\.\\d+)"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned)) {
            if let latRange = Range(match.range(at: 1), in: cleaned),
               let lonRange = Range(match.range(at: 2), in: cleaned) {
                metadata.latitude = Double(cleaned[latRange])
                metadata.longitude = Double(cleaned[lonRange])
            }
        }
    }

    /// Convert FourCC code to string
    private static func fourCCToString(_ code: FourCharCode) -> String {
        let bytes = [
            UInt8((code >> 24) & 0xFF),
            UInt8((code >> 16) & 0xFF),
            UInt8((code >> 8) & 0xFF),
            UInt8(code & 0xFF)
        ]
        if let str = String(bytes: bytes, encoding: .ascii)?.trimmingCharacters(in: .whitespaces) {
            // Map common codec codes to readable names
            switch str {
            case "avc1", "avc2", "avc3", "avc4": return "H.264"
            case "hvc1", "hev1": return "H.265"
            case "mp4v": return "MPEG-4"
            case "ap4h", "ap4x": return "ProRes 4444"
            case "apch": return "ProRes 422 HQ"
            case "apcn": return "ProRes 422"
            case "apcs": return "ProRes 422 LT"
            case "apco": return "ProRes 422 Proxy"
            case "aac ": return "AAC"
            case "mp4a": return "AAC"
            case "alac": return "ALAC"
            case "lpcm": return "LPCM"
            case ".mp3": return "MP3"
            default: return str
            }
        }
        return "Unknown"
    }

    // MARK: - Value Formatting
    
    /// Format options container for metadata value formatting
    struct FormatOptions {
        var dateFormat: String = "yyyy-MM-dd_HH-mm-ss"
        var durationFormat: DurationFormat = .colonSeparated
        var customDurationFormat: String = ""
        var dimensionsFormat: DimensionsFormat = .standard
        var customDimensionsFormat: String = ""
        var gpsFormat: GPSFormat = .decimal
        var customGPSFormat: String = ""
        var trackNumberFormat: TrackNumberFormat = .paddedTwo
        var customTrackNumberFormat: String = ""
        var frameRateFormat: FrameRateFormat = .withFps
        var customFrameRateFormat: String = ""
    }

    /// Gets the formatted value for a specific metadata field
    func value(for field: MediaMetadataField, dateFormat: String, durationFormat: DurationFormat, customDurationFormat: String = "") -> String? {
        let options = FormatOptions(
            dateFormat: dateFormat,
            durationFormat: durationFormat,
            customDurationFormat: customDurationFormat
        )
        return value(for: field, options: options)
    }
    
    /// Gets the formatted value for a specific metadata field with full format options
    func value(for field: MediaMetadataField, options: FormatOptions) -> String? {
        switch field {
        // Common fields
        case .creationDate:
            return formatDate(creationDate, format: options.dateFormat)
        case .modificationDate:
            return formatDate(modificationDate, format: options.dateFormat)
        case .duration:
            return formatDuration(duration, format: options.durationFormat, customFormat: options.customDurationFormat)
        case .dimensions:
            return formatDimensions(width: width, height: height, format: options.dimensionsFormat, customFormat: options.customDimensionsFormat)
        case .gpsCoordinates:
            return formatGPS(latitude: latitude, longitude: longitude, format: options.gpsFormat, customFormat: options.customGPSFormat)

        // Image fields
        case .cameraMake:
            return cameraMake?.trimmingCharacters(in: .whitespaces)
        case .cameraModel:
            return cameraModel?.trimmingCharacters(in: .whitespaces)
        case .lensModel:
            return lensModel?.trimmingCharacters(in: .whitespaces)
        case .focalLength:
            guard let focal = focalLength else { return nil }
            return String(format: "%.0fmm", focal)
        case .aperture:
            guard let f = aperture else { return nil }
            return String(format: "f%.1f", f)
        case .shutterSpeed:
            return shutterSpeed
        case .iso:
            guard let iso = iso else { return nil }
            return "ISO\(iso)"
        case .colorSpace:
            return colorSpace
        case .colorProfile:
            return colorProfile

        // Video fields
        case .videoCodec:
            return videoCodec
        case .frameRate:
            return formatFrameRate(frameRate, format: options.frameRateFormat, customFormat: options.customFrameRateFormat)
        case .videoBitrate:
            return formatBitrate(videoBitrate)
        case .audioCodec:
            return audioCodec
        case .audioBitrate:
            return formatBitrate(audioBitrate)
        case .audioSampleRate:
            guard let rate = audioSampleRate else { return nil }
            return String(format: "%.0fHz", rate)
        case .audioChannels:
            guard let channels = audioChannels else { return nil }
            switch channels {
            case 1: return "Mono"
            case 2: return "Stereo"
            case 6: return "5.1"
            case 8: return "7.1"
            default: return "\(channels)ch"
            }

        // Audio fields
        case .title:
            return title?.trimmingCharacters(in: .whitespaces)
        case .artist:
            return artist?.trimmingCharacters(in: .whitespaces)
        case .albumArtist:
            return albumArtist?.trimmingCharacters(in: .whitespaces)
        case .album:
            return album?.trimmingCharacters(in: .whitespaces)
        case .composer:
            return composer?.trimmingCharacters(in: .whitespaces)
        case .genre:
            return genre?.trimmingCharacters(in: .whitespaces)
        case .year:
            guard let year = year else { return nil }
            return "\(year)"
        case .trackNumber:
            return formatTrackNumber(trackNumber, total: trackTotal, format: options.trackNumberFormat, customFormat: options.customTrackNumberFormat)
        case .discNumber:
            guard let disc = discNumber else { return nil }
            if let total = discTotal {
                return "\(disc)-\(total)"
            }
            return "\(disc)"
        case .bpm:
            guard let bpm = bpm else { return nil }
            return "\(bpm)bpm"

        // Document fields
        case .author:
            return author?.trimmingCharacters(in: .whitespaces)
        case .subject:
            return subject?.trimmingCharacters(in: .whitespaces)
        case .keywords:
            return keywords?.trimmingCharacters(in: .whitespaces)
        case .creator:
            return creator?.trimmingCharacters(in: .whitespaces)
        case .pageCount:
            guard let pages = pageCount else { return nil }
            return "\(pages)pages"
        case .pdfVersion:
            return pdfVersion
        }
    }

    private func formatDate(_ date: Date?, format: String) -> String? {
        guard let date = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval?, format: DurationFormat, customFormat: String = "") -> String? {
        guard let duration = duration, duration > 0 else { return nil }
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        switch format {
        case .colonSeparated:
            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            }
            return String(format: "%d:%02d", minutes, seconds)
        case .hhmmss:
            if hours > 0 {
                return String(format: "%02d-%02d-%02d", hours, minutes, seconds)
            }
            return String(format: "%02d-%02d", minutes, seconds)
        case .hms:
            if hours > 0 {
                return "\(hours)h\(minutes)m\(seconds)s"
            }
            return "\(minutes)m\(seconds)s"
        case .totalSeconds:
            return "\(Int(duration))s"
        case .totalMinutes:
            return String(format: "%.1fmin", duration / 60)
        case .custom:
            return formatDurationCustom(hours: hours, minutes: minutes, seconds: seconds, totalSeconds: Int(duration), format: customFormat)
        }
    }
    
    /// Formats duration using a custom format string
    /// Format codes: HH=hours(padded), H=hours, MM=minutes(padded), M=minutes, SS=seconds(padded), S=seconds, T=total seconds
    private func formatDurationCustom(hours: Int, minutes: Int, seconds: Int, totalSeconds: Int, format: String) -> String {
        var result = format
        
        // Replace padded versions first (longer patterns)
        result = result.replacingOccurrences(of: "HH", with: String(format: "%02d", hours))
        result = result.replacingOccurrences(of: "MM", with: String(format: "%02d", minutes))
        result = result.replacingOccurrences(of: "SS", with: String(format: "%02d", seconds))
        
        // Then replace non-padded versions
        result = result.replacingOccurrences(of: "H", with: "\(hours)")
        result = result.replacingOccurrences(of: "M", with: "\(minutes)")
        result = result.replacingOccurrences(of: "S", with: "\(seconds)")
        result = result.replacingOccurrences(of: "T", with: "\(totalSeconds)")
        
        return result
    }

    private func formatBitrate(_ bitrate: Int?) -> String? {
        guard let bitrate = bitrate, bitrate > 0 else { return nil }
        if bitrate >= 1_000_000 {
            return String(format: "%.1fMbps", Double(bitrate) / 1_000_000)
        } else if bitrate >= 1000 {
            return "\(bitrate / 1000)kbps"
        }
        return "\(bitrate)bps"
    }
    
    /// Formats dimensions using the specified format
    /// Format codes for custom: W=width, H=height, MP=megapixels
    private func formatDimensions(width: Int?, height: Int?, format: DimensionsFormat, customFormat: String) -> String? {
        guard let w = width, let h = height else { return nil }
        
        switch format {
        case .standard:
            return "\(w)x\(h)"
        case .hyphen:
            return "\(w)-\(h)"
        case .underscore:
            return "\(w)_\(h)"
        case .widthOnly:
            return "\(w)"
        case .heightOnly:
            return "\(h)"
        case .megapixels:
            let mp = Double(w * h) / 1_000_000.0
            return String(format: "%.1fMP", mp)
        case .custom:
            return formatDimensionsCustom(width: w, height: h, format: customFormat)
        }
    }
    
    /// Formats dimensions using a custom format string
    /// Format codes: W=width, H=height, MP=megapixels (1 decimal)
    private func formatDimensionsCustom(width: Int, height: Int, format: String) -> String {
        var result = format
        let megapixels = Double(width * height) / 1_000_000.0
        
        // Replace MP first (longer pattern)
        result = result.replacingOccurrences(of: "MP", with: String(format: "%.1f", megapixels))
        result = result.replacingOccurrences(of: "W", with: "\(width)")
        result = result.replacingOccurrences(of: "H", with: "\(height)")
        
        return result
    }
    
    /// Formats GPS coordinates using the specified format
    /// Format codes for custom: LAT=latitude, LON=longitude, NS=N/S, EW=E/W
    private func formatGPS(latitude: Double?, longitude: Double?, format: GPSFormat, customFormat: String) -> String? {
        guard let lat = latitude, let lon = longitude else { return nil }
        
        switch format {
        case .decimal:
            return String(format: "%.4f,%.4f", lat, lon)
        case .decimalPositive:
            return String(format: "%.4f,%.4f", abs(lat), abs(lon))
        case .degrees:
            let latDir = lat >= 0 ? "N" : "S"
            let lonDir = lon >= 0 ? "E" : "W"
            let (latDeg, latMin) = decimalToDegrees(abs(lat))
            let (lonDeg, lonMin) = decimalToDegrees(abs(lon))
            return String(format: "%d°%d'%@ %d°%d'%@", latDeg, latMin, latDir, lonDeg, lonMin, lonDir)
        case .compact:
            let latDir = lat >= 0 ? "N" : "S"
            let lonDir = lon >= 0 ? "E" : "W"
            return String(format: "%.4f%@%.4f%@", abs(lat), latDir, abs(lon), lonDir)
        case .custom:
            return formatGPSCustom(latitude: lat, longitude: lon, format: customFormat)
        }
    }
    
    /// Converts decimal degrees to degrees and minutes
    private func decimalToDegrees(_ decimal: Double) -> (degrees: Int, minutes: Int) {
        let degrees = Int(decimal)
        let minutes = Int((decimal - Double(degrees)) * 60)
        return (degrees, minutes)
    }
    
    /// Formats GPS using a custom format string
    /// Format codes: LAT=latitude, LON=longitude, ALAT=abs latitude, ALON=abs longitude, NS=N/S, EW=E/W
    private func formatGPSCustom(latitude: Double, longitude: Double, format: String) -> String {
        var result = format
        let latDir = latitude >= 0 ? "N" : "S"
        let lonDir = longitude >= 0 ? "E" : "W"
        
        // Replace longer patterns first
        result = result.replacingOccurrences(of: "ALAT", with: String(format: "%.4f", abs(latitude)))
        result = result.replacingOccurrences(of: "ALON", with: String(format: "%.4f", abs(longitude)))
        result = result.replacingOccurrences(of: "LAT", with: String(format: "%.4f", latitude))
        result = result.replacingOccurrences(of: "LON", with: String(format: "%.4f", longitude))
        result = result.replacingOccurrences(of: "NS", with: latDir)
        result = result.replacingOccurrences(of: "EW", with: lonDir)
        
        return result
    }
    
    /// Formats track number using the specified format
    /// Format codes for custom: N=track, NN=track(padded 2), NNN=track(padded 3), T=total, TT=total(padded 2)
    private func formatTrackNumber(_ track: Int?, total: Int?, format: TrackNumberFormat, customFormat: String) -> String? {
        guard let track = track else { return nil }
        
        switch format {
        case .paddedTwo:
            return String(format: "%02d", track)
        case .paddedThree:
            return String(format: "%03d", track)
        case .noPadding:
            return "\(track)"
        case .withTotal:
            if let total = total {
                return String(format: "%02d-%02d", track, total)
            }
            return String(format: "%02d", track)
        case .withTotalSlash:
            if let total = total {
                return String(format: "%02d/%02d", track, total)
            }
            return String(format: "%02d", track)
        case .custom:
            return formatTrackNumberCustom(track: track, total: total, format: customFormat)
        }
    }
    
    /// Formats track number using a custom format string
    /// Format codes: #N3=track(padded 3), #N2=track(padded 2), #N=track, #T3=total(padded 3), #T2=total(padded 2), #T=total
    /// Legacy codes (for simpler formats): NNN=track(padded 3), NN=track(padded 2), TTT=total(padded 3), TT=total(padded 2)
    private func formatTrackNumberCustom(track: Int, total: Int?, format: String) -> String {
        var result = format
        
        // Replace newer #-prefixed patterns first (more explicit, no collision risk)
        result = result.replacingOccurrences(of: "#N3", with: String(format: "%03d", track))
        result = result.replacingOccurrences(of: "#N2", with: String(format: "%02d", track))
        result = result.replacingOccurrences(of: "#N", with: "\(track)")
        
        if let total = total {
            result = result.replacingOccurrences(of: "#T3", with: String(format: "%03d", total))
            result = result.replacingOccurrences(of: "#T2", with: String(format: "%02d", total))
            result = result.replacingOccurrences(of: "#T", with: "\(total)")
        } else {
            result = result.replacingOccurrences(of: "#T3", with: "")
            result = result.replacingOccurrences(of: "#T2", with: "")
            result = result.replacingOccurrences(of: "#T", with: "")
        }
        
        // Replace legacy patterns (only if not already using # format)
        // These only work safely when the format doesn't contain other N/T letters
        result = result.replacingOccurrences(of: "NNN", with: String(format: "%03d", track))
        result = result.replacingOccurrences(of: "NN", with: String(format: "%02d", track))
        
        if let total = total {
            result = result.replacingOccurrences(of: "TTT", with: String(format: "%03d", total))
            result = result.replacingOccurrences(of: "TT", with: String(format: "%02d", total))
        } else {
            result = result.replacingOccurrences(of: "TTT", with: "")
            result = result.replacingOccurrences(of: "TT", with: "")
        }
        
        // Note: Single N and T patterns are intentionally NOT supported for legacy format
        // to avoid collisions with regular text containing those letters.
        // Use #N and #T for single-digit track/total numbers.
        
        return result
    }
    
    /// Formats frame rate using the specified format
    /// Format codes for custom: FPS=frame rate (2 decimals), F=integer frame rate
    private func formatFrameRate(_ frameRate: Double?, format: FrameRateFormat, customFormat: String) -> String? {
        guard let fps = frameRate else { return nil }
        
        switch format {
        case .withFps:
            return String(format: "%.2ffps", fps)
        case .rounded:
            return String(format: "%dfps", Int(fps.rounded()))
        case .decimalOnly:
            return String(format: "%.2f", fps)
        case .integerOnly:
            return "\(Int(fps.rounded()))"
        case .custom:
            return formatFrameRateCustom(fps: fps, format: customFormat)
        }
    }
    
    /// Formats frame rate using a custom format string
    /// Format codes: FPS=frame rate (2 decimals), F=integer frame rate
    private func formatFrameRateCustom(fps: Double, format: String) -> String {
        var result = format
        
        // Replace longer patterns first
        result = result.replacingOccurrences(of: "FPS", with: String(format: "%.2f", fps))
        result = result.replacingOccurrences(of: "F", with: "\(Int(fps.rounded()))")
        
        return result
    }
}

// MARK: - Type Aliases for Backward Compatibility

typealias ExifField = MediaMetadataField
typealias ExifPosition = MetadataPosition
typealias ExifDateFormat = MetadataDateFormat
typealias ExifMetadata = MediaMetadata

// MARK: - Exif Action (Rename Action Implementation)

struct ExifAction: RenameAction {
    var field: MediaMetadataField = .creationDate
    var position: MetadataPosition = .prefix
    var insertPosition: Int = 0
    var dateFormat: MetadataDateFormat = .isoWithTime
    var customDateFormat: String = "yyyy-MM-dd_HH-mm-ss"
    var durationFormat: DurationFormat = .colonSeparated
    var customDurationFormat: String = "HH-MM-SS"
    var dimensionsFormat: DimensionsFormat = .standard
    var customDimensionsFormat: String = "WxH"
    var gpsFormat: GPSFormat = .decimal
    var customGPSFormat: String = "LAT,LON"
    var trackNumberFormat: TrackNumberFormat = .paddedTwo
    var customTrackNumberFormat: String = "NN"
    var frameRateFormat: FrameRateFormat = .withFps
    var customFrameRateFormat: String = "FPSfps"
    var separator: String = "_"
    var prefixSeparator: String = ""
    var suffixSeparator: String = ""
    var fallbackText: String = "unknown"

    /// Cache of extracted metadata, keyed by original filename
    /// This is populated by the ViewModel before preview/apply
    var metadataCache: [String: MediaMetadata] = [:]

    private var effectiveDateFormat: String {
        if dateFormat == .custom {
            return customDateFormat.isEmpty ? "yyyy-MM-dd" : customDateFormat
        }
        return dateFormat.formatString
    }
    
    private var effectiveDurationFormat: String {
        if durationFormat == .custom {
            return customDurationFormat.isEmpty ? "HH-MM-SS" : customDurationFormat
        }
        return ""
    }
    
    /// Builds format options from current action settings
    private var formatOptions: MediaMetadata.FormatOptions {
        MediaMetadata.FormatOptions(
            dateFormat: effectiveDateFormat,
            durationFormat: durationFormat,
            customDurationFormat: effectiveDurationFormat,
            dimensionsFormat: dimensionsFormat,
            customDimensionsFormat: customDimensionsFormat,
            gpsFormat: gpsFormat,
            customGPSFormat: customGPSFormat,
            trackNumberFormat: trackNumberFormat,
            customTrackNumberFormat: customTrackNumberFormat,
            frameRateFormat: frameRateFormat,
            customFrameRateFormat: customFrameRateFormat
        )
    }

    func applyWithTracking(to filename: String, at index: Int, totalCount: Int, applyToExtension: Bool) -> RenamePreviewResult {
        let url = URL(fileURLWithPath: filename)
        let ext = url.pathExtension
        
        // If applyToExtension is true, work on full filename; otherwise just the name
        let workingName: String
        if applyToExtension || ext.isEmpty {
            workingName = url.lastPathComponent
        } else {
            workingName = url.deletingPathExtension().lastPathComponent
        }

        // Look up metadata from cache
        let metadata = metadataCache[filename]
        let metadataValue = metadata?.value(for: field, options: formatOptions) ?? fallbackText

        let newName: String
        var changedRange: Range<Int>
        var deletedRange: Range<Int>?
        
        switch position {
        case .prefix:
            let inserted = "\(metadataValue)\(separator)"
            newName = "\(inserted)\(workingName)"
            changedRange = 0..<inserted.count
            
        case .suffix:
            let inserted = "\(separator)\(metadataValue)"
            newName = "\(workingName)\(inserted)"
            changedRange = workingName.count..<(workingName.count + inserted.count)
            
        case .atPosition:
            let result = insertAtPositionWithTracking(metadataValue, into: workingName)
            newName = result.newName
            changedRange = result.changedRange
            
        case .replace:
            newName = metadataValue
            changedRange = 0..<metadataValue.count
            deletedRange = 0..<workingName.count
        }

        // Sanitize the filename (remove invalid characters)
        let sanitized = sanitizeFilename(newName)
        
        // Adjust changed range if sanitization changed the length
        if sanitized.count != newName.count {
            // Recalculate - just highlight the whole sanitized portion for simplicity
            changedRange = 0..<min(changedRange.upperBound, sanitized.count)
        }

        // If we worked on full filename, return as-is; otherwise reattach extension
        let finalName: String
        if applyToExtension || ext.isEmpty {
            finalName = sanitized
        } else {
            finalName = "\(sanitized).\(ext)"
        }
        
        return RenamePreviewResult(newName: finalName, changedRange: changedRange, deletedRange: deletedRange)
    }

    /// Inserts the metadata value at the specified position in the name with tracking
    private func insertAtPositionWithTracking(_ value: String, into name: String) -> (newName: String, changedRange: Range<Int>) {
        // Clamp position to valid range
        let pos = max(0, min(insertPosition, name.count))

        // Build the insertion string with prefix and suffix separators
        let insertionString = "\(prefixSeparator)\(value)\(suffixSeparator)"

        let index = name.index(name.startIndex, offsetBy: pos)
        var result = name
        result.insert(contentsOf: insertionString, at: index)
        
        return (result, pos..<(pos + insertionString.count))
    }

    /// Removes or replaces characters that are invalid in filenames
    private func sanitizeFilename(_ name: String) -> String {
        // Characters not allowed in macOS filenames
        let invalidCharacters = CharacterSet(charactersIn: "/:")

        return name.components(separatedBy: invalidCharacters).joined(separator: "-")
    }
}
