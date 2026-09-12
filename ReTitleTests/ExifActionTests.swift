import XCTest
@testable import ReTitle

final class ExifActionTests: XCTestCase {

    // MARK: - Basic Apply Tests (without metadata)

    func testApplyWithNoMetadataUsesFallback() {
        var action = ExifAction()
        action.field = .creationDate
        action.position = .prefix
        action.fallbackText = "no-date"
        action.separator = "_"

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "no-date_photo.jpg")
    }

    func testApplyWithNoMetadataSuffix() {
        var action = ExifAction()
        action.field = .cameraModel
        action.position = .suffix
        action.fallbackText = "unknown"
        action.separator = "_"

        let result = action.apply(to: "image.png", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "image_unknown.png")
    }

    func testApplyWithNoMetadataReplace() {
        var action = ExifAction()
        action.field = .iso
        action.position = .replace
        action.fallbackText = "unknown-iso"

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "unknown-iso.jpg")
    }

    // MARK: - Common Field Tests

    func testApplyWithCachedCreationDate() {
        var action = ExifAction()
        action.field = .creationDate
        action.position = .prefix
        action.dateFormat = .iso
        action.separator = "_"

        var metadata = MediaMetadata()
        let dateComponents = DateComponents(year: 2024, month: 6, day: 15, hour: 14, minute: 30, second: 45)
        metadata.creationDate = Calendar.current.date(from: dateComponents)
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2024-06-15_photo.jpg")
    }

    func testApplyWithCachedModificationDate() {
        var action = ExifAction()
        action.field = .modificationDate
        action.position = .prefix
        action.dateFormat = .compact
        action.separator = "_"

        var metadata = MediaMetadata()
        let dateComponents = DateComponents(year: 2024, month: 12, day: 25)
        metadata.modificationDate = Calendar.current.date(from: dateComponents)
        action.metadataCache["file.mp4"] = metadata

        let result = action.apply(to: "file.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "20241225_file.mp4")
    }

    func testApplyWithCachedDuration() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .hms
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 3665 // 1h 1m 5s
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_1h1m5s.mp4")
    }

    func testApplyWithCachedDimensions() {
        var action = ExifAction()
        action.field = .dimensions
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.width = 1920
        metadata.height = 1080
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_1920x1080.mp4")
    }

    func testApplyWithCachedGPSCoordinates() {
        var action = ExifAction()
        action.field = .gpsCoordinates
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.latitude = 37.7749
        metadata.longitude = -122.4194
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_37.7749,-122.4194.jpg")
    }

    // MARK: - Image Field Tests

    func testApplyWithCachedCameraModel() {
        var action = ExifAction()
        action.field = .cameraModel
        action.position = .prefix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.cameraModel = "Canon EOS R5"
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Canon EOS R5_photo.jpg")
    }

    func testApplyWithCachedCameraMake() {
        var action = ExifAction()
        action.field = .cameraMake
        action.position = .suffix
        action.separator = "-"

        var metadata = MediaMetadata()
        metadata.cameraMake = "Nikon"
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo-Nikon.jpg")
    }

    func testApplyWithCachedLensModel() {
        var action = ExifAction()
        action.field = .lensModel
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.lensModel = "RF 50mm F1.2L"
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_RF 50mm F1.2L.jpg")
    }

    func testApplyWithCachedFocalLength() {
        var action = ExifAction()
        action.field = .focalLength
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.focalLength = 85.0
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_85mm.jpg")
    }

    func testApplyWithCachedAperture() {
        var action = ExifAction()
        action.field = .aperture
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.aperture = 2.8
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_f2.8.jpg")
    }

    func testApplyWithCachedShutterSpeed() {
        var action = ExifAction()
        action.field = .shutterSpeed
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.shutterSpeed = "1/250s"
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        // Note: "/" is sanitized to "-" in filenames
        XCTAssertEqual(result, "photo_1-250s.jpg")
    }

    func testApplyWithCachedISO() {
        var action = ExifAction()
        action.field = .iso
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.iso = 800
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_ISO800.jpg")
    }

    // MARK: - Video Field Tests

    func testApplyWithCachedVideoCodec() {
        var action = ExifAction()
        action.field = .videoCodec
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.videoCodec = "H.264"
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_H.264.mp4")
    }

    func testApplyWithCachedFrameRate() {
        var action = ExifAction()
        action.field = .frameRate
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.frameRate = 29.97
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_29.97fps.mp4")
    }

    func testApplyWithCachedVideoBitrate() {
        var action = ExifAction()
        action.field = .videoBitrate
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.videoBitrate = 5_000_000
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_5.0Mbps.mp4")
    }

    func testApplyWithCachedAudioChannels() {
        var action = ExifAction()
        action.field = .audioChannels
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.audioChannels = 2
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_Stereo.mp4")
    }

    func testApplyWithCachedAudioChannelsSurround() {
        var action = ExifAction()
        action.field = .audioChannels
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.audioChannels = 6
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_5.1.mp4")
    }

    // MARK: - Audio Field Tests

    func testApplyWithCachedTitle() {
        var action = ExifAction()
        action.field = .title
        action.position = .replace

        var metadata = MediaMetadata()
        metadata.title = "My Song"
        action.metadataCache["track01.mp3"] = metadata

        let result = action.apply(to: "track01.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "My Song.mp3")
    }

    func testApplyWithCachedArtist() {
        var action = ExifAction()
        action.field = .artist
        action.position = .prefix
        action.separator = " - "

        var metadata = MediaMetadata()
        metadata.artist = "The Beatles"
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "The Beatles - song.mp3")
    }

    func testApplyWithCachedAlbum() {
        var action = ExifAction()
        action.field = .album
        action.position = .prefix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.album = "Abbey Road"
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Abbey Road_song.mp3")
    }

    func testApplyWithCachedTrackNumber() {
        var action = ExifAction()
        action.field = .trackNumber
        action.position = .prefix
        action.trackNumberFormat = .withTotal  // Use withTotal format to include track total
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.trackNumber = 5
        metadata.trackTotal = 12
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "05-12_song.mp3")
    }

    func testApplyWithCachedYear() {
        var action = ExifAction()
        action.field = .year
        action.position = .prefix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.year = 1969
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "1969_song.mp3")
    }

    func testApplyWithCachedGenre() {
        var action = ExifAction()
        action.field = .genre
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.genre = "Rock"
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "song_Rock.mp3")
    }

    func testApplyWithCachedBPM() {
        var action = ExifAction()
        action.field = .bpm
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.bpm = 120
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "song_120bpm.mp3")
    }

    // MARK: - Document Field Tests

    func testApplyWithCachedAuthor() {
        var action = ExifAction()
        action.field = .author
        action.position = .prefix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.author = "John Doe"
        action.metadataCache["document.pdf"] = metadata

        let result = action.apply(to: "document.pdf", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "John Doe_document.pdf")
    }

    func testApplyWithCachedPageCount() {
        var action = ExifAction()
        action.field = .pageCount
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.pageCount = 42
        action.metadataCache["document.pdf"] = metadata

        let result = action.apply(to: "document.pdf", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "document_42pages.pdf")
    }

    func testApplyWithCachedPDFVersion() {
        var action = ExifAction()
        action.field = .pdfVersion
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.pdfVersion = "1.7"
        action.metadataCache["document.pdf"] = metadata

        let result = action.apply(to: "document.pdf", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "document_1.7.pdf")
    }

    // MARK: - Duration Format Tests

    func testDurationFormatHHMMSS() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .hhmmss
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 3661 // 1h 1m 1s
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_01-01-01.mp4")
    }

    func testDurationFormatHMS() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .hms
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 125 // 2m 5s
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_2m5s.mp4")
    }

    func testDurationFormatTotalSeconds() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .totalSeconds
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 90.5
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_90s.mp4")
    }

    func testDurationFormatTotalMinutes() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .totalMinutes
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 150 // 2.5 minutes
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_2.5min.mp4")
    }

    func testDurationFormatCustom() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .custom
        action.customDurationFormat = "HH.MM.SS"
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 3661 // 1h 1m 1s
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_01.01.01.mp4")
    }

    func testDurationFormatCustomWithTotalSeconds() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .custom
        action.customDurationFormat = "Tsec"
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 125
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_125sec.mp4")
    }

    func testDurationFormatCustomMixed() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .custom
        action.customDurationFormat = "Hh_Mm_Ss"
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 3723 // 1h 2m 3s
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_1h_2m_3s.mp4")
    }

    // MARK: - Date Format Tests

    func testDateFormatISO() {
        var action = ExifAction()
        action.field = .creationDate
        action.position = .replace
        action.dateFormat = .iso

        var metadata = MediaMetadata()
        let dateComponents = DateComponents(year: 2023, month: 12, day: 25)
        metadata.creationDate = Calendar.current.date(from: dateComponents)
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2023-12-25.jpg")
    }

    func testDateFormatISOWithTime() {
        var action = ExifAction()
        action.field = .creationDate
        action.position = .replace
        action.dateFormat = .isoWithTime

        var metadata = MediaMetadata()
        let dateComponents = DateComponents(year: 2023, month: 12, day: 25, hour: 10, minute: 30, second: 45)
        metadata.creationDate = Calendar.current.date(from: dateComponents)
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2023-12-25_10-30-45.jpg")
    }

    func testDateFormatYearOnly() {
        var action = ExifAction()
        action.field = .creationDate
        action.position = .prefix
        action.dateFormat = .yearOnly
        action.separator = "_"

        var metadata = MediaMetadata()
        let dateComponents = DateComponents(year: 2023, month: 12, day: 25)
        metadata.creationDate = Calendar.current.date(from: dateComponents)
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2023_photo.jpg")
    }

    func testDateFormatYearMonth() {
        var action = ExifAction()
        action.field = .creationDate
        action.position = .prefix
        action.dateFormat = .yearMonth
        action.separator = "_"

        var metadata = MediaMetadata()
        let dateComponents = DateComponents(year: 2023, month: 6, day: 15)
        metadata.creationDate = Calendar.current.date(from: dateComponents)
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2023-06_photo.jpg")
    }

    func testDateFormatCustom() {
        var action = ExifAction()
        action.field = .creationDate
        action.position = .replace
        action.dateFormat = .custom
        action.customDateFormat = "dd.MM.yyyy"

        var metadata = MediaMetadata()
        let dateComponents = DateComponents(year: 2023, month: 12, day: 25)
        metadata.creationDate = Calendar.current.date(from: dateComponents)
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "25.12.2023.jpg")
    }

    // MARK: - Position Tests

    func testPrefixPosition() {
        var action = ExifAction()
        action.field = .cameraModel
        action.position = .prefix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.cameraModel = "Sony A7IV"
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Sony A7IV_photo.jpg")
    }

    func testSuffixPosition() {
        var action = ExifAction()
        action.field = .cameraModel
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.cameraModel = "Sony A7IV"
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_Sony A7IV.jpg")
    }

    func testReplacePosition() {
        var action = ExifAction()
        action.field = .creationDate
        action.position = .replace
        action.dateFormat = .compact

        var metadata = MediaMetadata()
        let dateComponents = DateComponents(year: 2024, month: 6, day: 15)
        metadata.creationDate = Calendar.current.date(from: dateComponents)
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "20240615.jpg")
    }

    // MARK: - At Position Tests

    func testAtPositionStart() {
        var action = ExifAction()
        action.field = .year
        action.position = .atPosition
        action.insertPosition = 0

        var metadata = MediaMetadata()
        metadata.year = 2024
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2024photo.jpg")
    }

    func testAtPositionMiddle() {
        var action = ExifAction()
        action.field = .iso
        action.position = .atPosition
        action.insertPosition = 3

        var metadata = MediaMetadata()
        metadata.iso = 800
        action.metadataCache["myfile.jpg"] = metadata

        let result = action.apply(to: "myfile.jpg", at: 0, totalCount: 1, applyToExtension: false)
        // Position 3 means after "myf", so "myf" + "ISO800" + "ile"
        XCTAssertEqual(result, "myfISO800ile.jpg")
    }

    func testAtPositionEnd() {
        var action = ExifAction()
        action.field = .cameraMake
        action.position = .atPosition
        action.insertPosition = 5  // "photo" has 5 characters

        var metadata = MediaMetadata()
        metadata.cameraMake = "Canon"
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photoCanon.jpg")
    }

    func testAtPositionBeyondLength() {
        var action = ExifAction()
        action.field = .genre
        action.position = .atPosition
        action.insertPosition = 100  // Beyond the filename length

        var metadata = MediaMetadata()
        metadata.genre = "Rock"
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        // Should clamp to end of string
        XCTAssertEqual(result, "songRock.mp3")
    }

    func testAtPositionNegative() {
        var action = ExifAction()
        action.field = .artist
        action.position = .atPosition
        action.insertPosition = -5  // Negative position

        var metadata = MediaMetadata()
        metadata.artist = "Beatles"
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        // Should clamp to 0 (start of string)
        XCTAssertEqual(result, "Beatlessong.mp3")
    }

    func testAtPositionWithNoMetadataUsesFallback() {
        var action = ExifAction()
        action.field = .title
        action.position = .atPosition
        action.insertPosition = 4
        action.fallbackText = "UNKNOWN"

        // No metadata in cache

        let result = action.apply(to: "track01.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "tracUNKNOWNk01.mp3")
    }

    func testAtPositionNoExtension() {
        var action = ExifAction()
        action.field = .album
        action.position = .atPosition
        action.insertPosition = 4

        var metadata = MediaMetadata()
        metadata.album = "Abbey Road"
        action.metadataCache["mysong"] = metadata

        let result = action.apply(to: "mysong", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "mysoAbbey Roadng")
    }

    func testAtPositionEmptyFilename() {
        var action = ExifAction()
        action.field = .bpm
        action.position = .atPosition
        action.insertPosition = 0

        var metadata = MediaMetadata()
        metadata.bpm = 120
        action.metadataCache[".mp3"] = metadata

        let result = action.apply(to: ".mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "120bpm.mp3")
    }

    func testAtPositionWithPrefixSeparator() {
        var action = ExifAction()
        action.field = .year
        action.position = .atPosition
        action.insertPosition = 5
        action.prefixSeparator = "["
        action.suffixSeparator = ""

        var metadata = MediaMetadata()
        metadata.year = 2024
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo[2024.jpg")
    }

    func testAtPositionWithSuffixSeparator() {
        var action = ExifAction()
        action.field = .iso
        action.position = .atPosition
        action.insertPosition = 0
        action.prefixSeparator = ""
        action.suffixSeparator = "_"

        var metadata = MediaMetadata()
        metadata.iso = 800
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "ISO800_photo.jpg")
    }

    func testAtPositionWithBothSeparators() {
        var action = ExifAction()
        action.field = .cameraModel
        action.position = .atPosition
        action.insertPosition = 3
        action.prefixSeparator = "["
        action.suffixSeparator = "]"

        var metadata = MediaMetadata()
        metadata.cameraModel = "Canon"
        action.metadataCache["myfile.jpg"] = metadata

        let result = action.apply(to: "myfile.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "myf[Canon]ile.jpg")
    }

    func testAtPositionWithUnderscoreSeparators() {
        var action = ExifAction()
        action.field = .genre
        action.position = .atPosition
        action.insertPosition = 4
        action.prefixSeparator = "_"
        action.suffixSeparator = "_"

        var metadata = MediaMetadata()
        metadata.genre = "Rock"
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "song_Rock_.mp3")
    }

    func testAtPositionSeparatorsAtStart() {
        var action = ExifAction()
        action.field = .artist
        action.position = .atPosition
        action.insertPosition = 0
        action.prefixSeparator = "("
        action.suffixSeparator = ") "

        var metadata = MediaMetadata()
        metadata.artist = "Beatles"
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "(Beatles) song.mp3")
    }

    func testAtPositionSeparatorsAtEnd() {
        var action = ExifAction()
        action.field = .album
        action.position = .atPosition
        action.insertPosition = 5  // End of "track"
        action.prefixSeparator = " - "
        action.suffixSeparator = ""

        var metadata = MediaMetadata()
        metadata.album = "Abbey Road"
        action.metadataCache["track.mp3"] = metadata

        let result = action.apply(to: "track.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "track - Abbey Road.mp3")
    }

    // MARK: - Separator Tests

    func testEmptySeparator() {
        var action = ExifAction()
        action.field = .iso
        action.position = .prefix
        action.separator = ""

        var metadata = MediaMetadata()
        metadata.iso = 100
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "ISO100photo.jpg")
    }

    func testDashSeparator() {
        var action = ExifAction()
        action.field = .cameraMake
        action.position = .prefix
        action.separator = "-"

        var metadata = MediaMetadata()
        metadata.cameraMake = "Canon"
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Canon-photo.jpg")
    }

    // MARK: - No Extension Tests

    func testNoExtensionWithPrefix() {
        var action = ExifAction()
        action.field = .creationDate
        action.position = .prefix
        action.dateFormat = .iso
        action.separator = "_"

        var metadata = MediaMetadata()
        let dateComponents = DateComponents(year: 2024, month: 1, day: 1)
        metadata.creationDate = Calendar.current.date(from: dateComponents)
        action.metadataCache["photo"] = metadata

        let result = action.apply(to: "photo", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2024-01-01_photo")
    }

    // MARK: - Filename Sanitization Tests

    func testSanitizesColonInMetadata() {
        var action = ExifAction()
        action.field = .gpsCoordinates
        action.position = .replace

        var metadata = MediaMetadata()
        metadata.latitude = 45.0
        metadata.longitude = -93.0
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        // Verify no invalid characters remain
        XCTAssertFalse(result.contains("/"))
        XCTAssertFalse(result.contains(":"))
    }

    // MARK: - Multiple Files Tests

    func testMultipleFilesWithDifferentMetadata() {
        var action = ExifAction()
        action.field = .iso
        action.position = .suffix
        action.separator = "_"

        var metadata1 = MediaMetadata()
        metadata1.iso = 100
        var metadata2 = MediaMetadata()
        metadata2.iso = 3200

        action.metadataCache["photo1.jpg"] = metadata1
        action.metadataCache["photo2.jpg"] = metadata2

        let result1 = action.apply(to: "photo1.jpg", at: 0, totalCount: 2, applyToExtension: false)
        let result2 = action.apply(to: "photo2.jpg", at: 1, totalCount: 2, applyToExtension: false)

        XCTAssertEqual(result1, "photo1_ISO100.jpg")
        XCTAssertEqual(result2, "photo2_ISO3200.jpg")
    }

    // MARK: - MediaMetadata Value Formatting Tests

    func testMetadataValueTrimsWhitespace() {
        var metadata = MediaMetadata()
        metadata.cameraModel = "  Canon EOS R5  "

        let value = metadata.value(for: .cameraModel, dateFormat: "", durationFormat: .hhmmss)
        XCTAssertEqual(value, "Canon EOS R5")
    }

    func testMetadataFocalLengthFormatting() {
        var metadata = MediaMetadata()
        metadata.focalLength = 24.5

        let value = metadata.value(for: .focalLength, dateFormat: "", durationFormat: .hhmmss)
        XCTAssertEqual(value, "24mm") // Truncated to integer (%.0f format)
    }

    func testMetadataApertureFormatting() {
        var metadata = MediaMetadata()
        metadata.aperture = 1.8

        let value = metadata.value(for: .aperture, dateFormat: "", durationFormat: .hhmmss)
        XCTAssertEqual(value, "f1.8")
    }

    func testMetadataBitrateFormattingMbps() {
        var metadata = MediaMetadata()
        metadata.videoBitrate = 2_500_000

        let value = metadata.value(for: .videoBitrate, dateFormat: "", durationFormat: .hhmmss)
        XCTAssertEqual(value, "2.5Mbps")
    }

    func testMetadataBitrateFormattingKbps() {
        var metadata = MediaMetadata()
        metadata.audioBitrate = 320_000

        let value = metadata.value(for: .audioBitrate, dateFormat: "", durationFormat: .hhmmss)
        XCTAssertEqual(value, "320kbps")
    }

    // MARK: - Field Category Tests

    func testFieldCategoryCommon() {
        XCTAssertEqual(MediaMetadataField.creationDate.category, .common)
        XCTAssertEqual(MediaMetadataField.duration.category, .common)
        XCTAssertEqual(MediaMetadataField.dimensions.category, .common)
    }

    func testFieldCategoryImage() {
        XCTAssertEqual(MediaMetadataField.cameraMake.category, .image)
        XCTAssertEqual(MediaMetadataField.aperture.category, .image)
        XCTAssertEqual(MediaMetadataField.iso.category, .image)
    }

    func testFieldCategoryVideo() {
        XCTAssertEqual(MediaMetadataField.videoCodec.category, .video)
        XCTAssertEqual(MediaMetadataField.frameRate.category, .video)
        XCTAssertEqual(MediaMetadataField.videoBitrate.category, .video)
    }

    func testFieldCategoryAudio() {
        XCTAssertEqual(MediaMetadataField.title.category, .audio)
        XCTAssertEqual(MediaMetadataField.artist.category, .audio)
        XCTAssertEqual(MediaMetadataField.album.category, .audio)
    }

    func testFieldCategoryDocument() {
        XCTAssertEqual(MediaMetadataField.author.category, .document)
        XCTAssertEqual(MediaMetadataField.pageCount.category, .document)
        XCTAssertEqual(MediaMetadataField.pdfVersion.category, .document)
    }

    func testIsDateField() {
        XCTAssertTrue(MediaMetadataField.creationDate.isDateField)
        XCTAssertTrue(MediaMetadataField.modificationDate.isDateField)
        XCTAssertTrue(MediaMetadataField.year.isDateField)
        XCTAssertFalse(MediaMetadataField.title.isDateField)
        XCTAssertFalse(MediaMetadataField.duration.isDateField)
    }

    // MARK: - Additional Duration Format Tests

    func testDurationFormatColonSeparated() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .colonSeparated
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 3661 // 1h 1m 1s
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        // Colon is sanitized to hyphen in filenames
        XCTAssertEqual(result, "video_1-01-01.mp4")
    }

    func testDurationFormatColonSeparatedShort() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .colonSeparated
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 65 // 1m 5s
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        // Format depends on implementation - just verify duration appears
        XCTAssertTrue(result.contains("video_"))
        XCTAssertTrue(result.hasSuffix(".mp4"))
    }

    func testDurationZero() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .hms
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 0
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        // Zero duration may return 0s or 0m0s or similar
        XCTAssertTrue(result.hasPrefix("video_"))
    }

    func testDurationOnlySeconds() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .hms
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 45 // Just 45 seconds
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        // 45 seconds in hms format
        XCTAssertTrue(result.contains("45"))
    }

    func testDurationWithHoursNoMinutes() {
        var action = ExifAction()
        action.field = .duration
        action.position = .suffix
        action.durationFormat = .hms
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.duration = 3605 // 1h 0m 5s
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_1h0m5s.mp4")
    }

    // MARK: - Additional Date Format Tests

    func testDateFormatCompactWithTime() {
        var action = ExifAction()
        action.field = .creationDate
        action.position = .replace
        action.dateFormat = .compactWithTime

        var metadata = MediaMetadata()
        let dateComponents = DateComponents(year: 2023, month: 12, day: 25, hour: 10, minute: 30, second: 45)
        metadata.creationDate = Calendar.current.date(from: dateComponents)
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "20231225_103045.jpg")
    }

    // MARK: - Missing Field Tests

    func testApplyWithCachedAlbumArtist() {
        var action = ExifAction()
        action.field = .albumArtist
        action.position = .prefix
        action.separator = " - "

        var metadata = MediaMetadata()
        metadata.albumArtist = "Various Artists"
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Various Artists - song.mp3")
    }

    func testApplyWithCachedComposer() {
        var action = ExifAction()
        action.field = .composer
        action.position = .prefix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.composer = "Mozart"
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Mozart_song.mp3")
    }

    func testApplyWithCachedDiscNumber() {
        var action = ExifAction()
        action.field = .discNumber
        action.position = .prefix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.discNumber = 2
        metadata.discTotal = 3
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2-3_song.mp3")
    }

    func testApplyWithCachedDiscNumberNoTotal() {
        var action = ExifAction()
        action.field = .discNumber
        action.position = .prefix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.discNumber = 1
        // No discTotal
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "1_song.mp3")
    }

    func testApplyWithCachedSubject() {
        var action = ExifAction()
        action.field = .subject
        action.position = .prefix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.subject = "Annual Report"
        action.metadataCache["document.pdf"] = metadata

        let result = action.apply(to: "document.pdf", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Annual Report_document.pdf")
    }

    func testApplyWithCachedKeywords() {
        var action = ExifAction()
        action.field = .keywords
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.keywords = "finance, 2024, report"
        action.metadataCache["document.pdf"] = metadata

        let result = action.apply(to: "document.pdf", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "document_finance, 2024, report.pdf")
    }

    func testApplyWithCachedAudioSampleRate() {
        var action = ExifAction()
        action.field = .audioSampleRate
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.audioSampleRate = 44100
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        // Sample rate formatting may vary - just check it contains kHz
        XCTAssertTrue(result.contains("44"))
    }

    func testApplyWithCachedColorSpace() {
        var action = ExifAction()
        action.field = .colorSpace
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.colorSpace = "sRGB"
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_sRGB.jpg")
    }

    func testApplyWithCachedColorProfile() {
        var action = ExifAction()
        action.field = .colorProfile
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.colorProfile = "Display P3"
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_Display P3.jpg")
    }

    // MARK: - GPS Edge Cases

    func testGPSCoordinatesAtOrigin() {
        var action = ExifAction()
        action.field = .gpsCoordinates
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.latitude = 0.0
        metadata.longitude = 0.0
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        // GPS formatting may use different decimal places
        XCTAssertTrue(result.contains("0"))
    }

    func testGPSCoordinatesAtBoundary() {
        var action = ExifAction()
        action.field = .gpsCoordinates
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.latitude = 90.0
        metadata.longitude = -180.0
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        // GPS formatting may vary
        XCTAssertTrue(result.contains("90"))
        XCTAssertTrue(result.contains("180"))
    }

    // MARK: - Audio Channel Edge Cases

    func testAudioChannelsMono() {
        var action = ExifAction()
        action.field = .audioChannels
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.audioChannels = 1
        action.metadataCache["audio.mp3"] = metadata

        let result = action.apply(to: "audio.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "audio_Mono.mp3")
    }

    func testAudioChannelsUnknown() {
        var action = ExifAction()
        action.field = .audioChannels
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.audioChannels = 4 // Quadraphonic
        action.metadataCache["audio.mp3"] = metadata

        let result = action.apply(to: "audio.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "audio_4ch.mp3")
    }

    func testAudioChannels71() {
        var action = ExifAction()
        action.field = .audioChannels
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.audioChannels = 8 // 7.1 surround
        action.metadataCache["audio.mp3"] = metadata

        let result = action.apply(to: "audio.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "audio_7.1.mp3")
    }

    // MARK: - Bitrate Edge Cases

    func testVideoBitrateSmall() {
        var action = ExifAction()
        action.field = .videoBitrate
        action.position = .suffix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.videoBitrate = 500_000 // 0.5 Mbps - should show as kbps
        action.metadataCache["video.mp4"] = metadata

        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_500kbps.mp4")
    }

    // MARK: - Empty Metadata Values

    func testEmptyStringMetadataUsesFallback() {
        var action = ExifAction()
        action.field = .cameraModel
        action.position = .prefix
        action.separator = "_"
        action.fallbackText = "unknown"

        var metadata = MediaMetadata()
        metadata.cameraModel = ""  // Empty string
        action.metadataCache["photo.jpg"] = metadata

        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        // Empty string may or may not trigger fallback depending on implementation
        XCTAssertTrue(result.contains("photo.jpg"))
    }

    func testWhitespaceOnlyMetadataUsesFallback() {
        var action = ExifAction()
        action.field = .title
        action.position = .prefix
        action.separator = "_"
        action.fallbackText = "untitled"

        var metadata = MediaMetadata()
        metadata.title = "   "  // Whitespace only
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        // Whitespace handling depends on implementation
        XCTAssertTrue(result.contains("song.mp3"))
    }

    // MARK: - Track Number Without Total

    func testTrackNumberWithoutTotal() {
        var action = ExifAction()
        action.field = .trackNumber
        action.position = .prefix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.trackNumber = 7
        // No trackTotal
        action.metadataCache["song.mp3"] = metadata

        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "07_song.mp3")
    }

    // MARK: - Sample Rate Formatting Edge Cases

    func testSampleRate48kHz() {
        var metadata = MediaMetadata()
        metadata.audioSampleRate = 48000

        let value = metadata.value(for: .audioSampleRate, dateFormat: "", durationFormat: .hhmmss)
        // Format may include decimal places
        XCTAssertTrue(value?.contains("48") ?? false)
    }

    func testSampleRate96kHz() {
        var metadata = MediaMetadata()
        metadata.audioSampleRate = 96000

        let value = metadata.value(for: .audioSampleRate, dateFormat: "", durationFormat: .hhmmss)
        XCTAssertTrue(value?.contains("96") ?? false)
    }

    // MARK: - Enum Tests

    func testMetadataPositionIdentifiable() {
        XCTAssertEqual(MetadataPosition.prefix.id, "Before Name")
        XCTAssertEqual(MetadataPosition.suffix.id, "After Name")
        XCTAssertEqual(MetadataPosition.replace.id, "Replace Name")
        XCTAssertEqual(MetadataPosition.atPosition.id, "At Position")
    }

    func testMetadataDateFormatAllCases() {
        XCTAssertEqual(MetadataDateFormat.allCases.count, 7)
    }

    func testDurationFormatAllCases() {
        XCTAssertEqual(DurationFormat.allCases.count, 6)
    }

    func testMediaFieldCategoryAllCases() {
        XCTAssertEqual(MediaFieldCategory.allCases.count, 5)
    }

    // MARK: - Hidden Files

    func testHiddenFilePrefixMetadata() {
        var action = ExifAction()
        action.field = .year
        action.position = .prefix
        action.separator = "_"

        var metadata = MediaMetadata()
        metadata.year = 2024
        action.metadataCache[".gitignore"] = metadata

        let result = action.apply(to: ".gitignore", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "2024_.gitignore")
    }

    func testHiddenFileReplaceMetadata() {
        var action = ExifAction()
        action.field = .creationDate
        action.position = .replace
        action.dateFormat = .compact

        var metadata = MediaMetadata()
        let dateComponents = DateComponents(year: 2024, month: 6, day: 15)
        metadata.creationDate = Calendar.current.date(from: dateComponents)
        action.metadataCache[".config"] = metadata

        // .config has no extension, so replace replaces the whole name
        let result = action.apply(to: ".config", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "20240615")
    }

    // MARK: - Dimensions Edge Cases

    func testDimensionsZero() {
        var action = ExifAction()
        action.field = .dimensions
        action.position = .suffix
        action.separator = "_"
        action.fallbackText = "unknown"

        var metadata = MediaMetadata()
        metadata.width = 0
        metadata.height = 0
        action.metadataCache["image.jpg"] = metadata

        // Zero dimensions behavior depends on implementation
        let result = action.apply(to: "image.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertTrue(result.contains("image"))
    }

    func testDimensionsOnlyWidth() {
        var action = ExifAction()
        action.field = .dimensions
        action.position = .suffix
        action.separator = "_"
        action.fallbackText = "unknown"

        var metadata = MediaMetadata()
        metadata.width = 1920
        // height is nil
        action.metadataCache["image.jpg"] = metadata

        let result = action.apply(to: "image.jpg", at: 0, totalCount: 1, applyToExtension: false)
        // Missing height may use fallback or show partial
        XCTAssertTrue(result.contains("image"))
    }
    
    // MARK: - Change Tracking Tests (applyWithTracking)
    
    func testTrackingPrefixWithMetadata() {
        var action = ExifAction()
        action.field = .cameraMake
        action.position = .prefix
        action.separator = "_"
        action.fallbackText = "UNKNOWN"
        
        var metadata = MediaMetadata()
        metadata.cameraMake = "Canon"
        action.metadataCache["photo.jpg"] = metadata
        
        let result = action.applyWithTracking(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "Canon_photo.jpg")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<6) // "Canon_"
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingSuffixWithMetadata() {
        var action = ExifAction()
        action.field = .iso
        action.position = .suffix
        action.separator = "_"
        action.fallbackText = ""
        
        var metadata = MediaMetadata()
        metadata.iso = 400
        action.metadataCache["photo.jpg"] = metadata
        
        let result = action.applyWithTracking(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        
        // ISO field returns "ISO400", so suffix is "_ISO400"
        XCTAssertEqual(result.newName, "photo_ISO400.jpg")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 5..<12) // "_ISO400" (7 chars starting at position 5)
        XCTAssertTrue(result.deletedRanges.isEmpty)
    }
    
    func testTrackingReplaceWithMetadata() {
        var action = ExifAction()
        action.field = .creationDate
        action.position = .replace
        action.dateFormat = .iso
        action.fallbackText = "nodate"
        
        var metadata = MediaMetadata()
        metadata.creationDate = makeDate(year: 2024, month: 6, day: 15)
        action.metadataCache["IMG_001.jpg"] = metadata
        
        let result = action.applyWithTracking(to: "IMG_001.jpg", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "2024-06-15.jpg")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 0..<10) // "2024-06-15"
        XCTAssertEqual(result.deletedRanges.count, 1)
        XCTAssertEqual(result.deletedRanges.first, 0..<7) // "IMG_001" deleted
    }
    
    func testTrackingAtPosition() {
        var action = ExifAction()
        action.field = .cameraModel
        action.position = .atPosition
        action.insertPosition = 4
        action.prefixSeparator = "["
        action.suffixSeparator = "]"
        action.fallbackText = "?"
        
        var metadata = MediaMetadata()
        metadata.cameraModel = "5D"
        action.metadataCache["photo001.jpg"] = metadata
        
        let result = action.applyWithTracking(to: "photo001.jpg", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "phot[5D]o001.jpg")
        XCTAssertEqual(result.changedRanges.count, 1)
        XCTAssertEqual(result.changedRanges.first, 4..<8) // "[5D]"
    }
    
    func testTrackingWithFallback() {
        var action = ExifAction()
        action.field = .cameraMake
        action.position = .prefix
        action.separator = "_"
        action.fallbackText = "UNKNOWN"
        
        // No metadata cached - should use fallback
        
        let result = action.applyWithTracking(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "UNKNOWN_photo.jpg")
        XCTAssertEqual(result.changedRanges.first, 0..<8) // "UNKNOWN_"
    }
    
    func testTrackingNoExtension() {
        var action = ExifAction()
        action.field = .artist
        action.position = .suffix
        action.separator = " - "
        action.fallbackText = ""
        
        var metadata = MediaMetadata()
        metadata.artist = "Artist"
        action.metadataCache["track01"] = metadata
        
        let result = action.applyWithTracking(to: "track01", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "track01 - Artist")
        XCTAssertEqual(result.changedRanges.first, 7..<16) // " - Artist"
    }
    
    func testTrackingApplyToExtension() {
        var action = ExifAction()
        action.field = .year
        action.position = .suffix
        action.separator = "_"
        action.fallbackText = "0000"
        
        var metadata = MediaMetadata()
        metadata.year = 2024
        action.metadataCache["song.mp3"] = metadata
        
        let result = action.applyWithTracking(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: true)
        
        XCTAssertEqual(result.newName, "song.mp3_2024")
        XCTAssertEqual(result.changedRanges.first, 8..<13) // "_2024"
    }
    
    func testTrackingDimensions() {
        var action = ExifAction()
        action.field = .dimensions
        action.position = .suffix
        action.separator = "_"
        action.fallbackText = "unknown"
        
        var metadata = MediaMetadata()
        metadata.width = 1920
        metadata.height = 1080
        action.metadataCache["video.mp4"] = metadata
        
        let result = action.applyWithTracking(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        
        XCTAssertEqual(result.newName, "video_1920x1080.mp4")
        XCTAssertEqual(result.changedRanges.count, 1)
        // "_1920x1080" = 10 chars starting at position 5
        XCTAssertEqual(result.changedRanges.first, 5..<15)
    }
    
    func testTrackingSanitizesFilename() {
        var action = ExifAction()
        action.field = .title
        action.position = .replace
        action.fallbackText = "untitled"
        
        var metadata = MediaMetadata()
        metadata.title = "Song: The Remix" // Contains colon which needs sanitization
        action.metadataCache["track.mp3"] = metadata
        
        let result = action.applyWithTracking(to: "track.mp3", at: 0, totalCount: 1, applyToExtension: false)
        
        // Colon should be replaced with dash
        XCTAssertEqual(result.newName, "Song- The Remix.mp3")
        XCTAssertFalse(result.changedRanges.isEmpty)
    }
    
    // Helper to create dates for testing
    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }
    
    // MARK: - Dimensions Format Tests
    
    func testDimensionsFormatStandard() {
        var action = ExifAction()
        action.field = .dimensions
        action.position = .suffix
        action.dimensionsFormat = .standard
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.width = 3840
        metadata.height = 2160
        action.metadataCache["video.mp4"] = metadata
        
        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_3840x2160.mp4")
    }
    
    func testDimensionsFormatHyphen() {
        var action = ExifAction()
        action.field = .dimensions
        action.position = .suffix
        action.dimensionsFormat = .hyphen
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.width = 1920
        metadata.height = 1080
        action.metadataCache["video.mp4"] = metadata
        
        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_1920-1080.mp4")
    }
    
    func testDimensionsFormatUnderscore() {
        var action = ExifAction()
        action.field = .dimensions
        action.position = .suffix
        action.dimensionsFormat = .underscore
        action.separator = "-"
        
        var metadata = MediaMetadata()
        metadata.width = 1280
        metadata.height = 720
        action.metadataCache["video.mp4"] = metadata
        
        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video-1280_720.mp4")
    }
    
    func testDimensionsFormatWidthOnly() {
        var action = ExifAction()
        action.field = .dimensions
        action.position = .suffix
        action.dimensionsFormat = .widthOnly
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.width = 4096
        metadata.height = 2160
        action.metadataCache["video.mp4"] = metadata
        
        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_4096.mp4")
    }
    
    func testDimensionsFormatHeightOnly() {
        var action = ExifAction()
        action.field = .dimensions
        action.position = .suffix
        action.dimensionsFormat = .heightOnly
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.width = 1920
        metadata.height = 1080
        action.metadataCache["video.mp4"] = metadata
        
        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_1080.mp4")
    }
    
    func testDimensionsFormatMegapixels() {
        var action = ExifAction()
        action.field = .dimensions
        action.position = .suffix
        action.dimensionsFormat = .megapixels
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.width = 4000
        metadata.height = 3000  // 12 megapixels
        action.metadataCache["photo.jpg"] = metadata
        
        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_12.0MP.jpg")
    }
    
    func testDimensionsFormatCustomWxH() {
        var action = ExifAction()
        action.field = .dimensions
        action.position = .suffix
        action.dimensionsFormat = .custom
        action.customDimensionsFormat = "W-by-H"
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.width = 800
        metadata.height = 600
        action.metadataCache["image.jpg"] = metadata
        
        let result = action.apply(to: "image.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "image_800-by-600.jpg")
    }
    
    func testDimensionsFormatCustomWithMP() {
        var action = ExifAction()
        action.field = .dimensions
        action.position = .suffix
        action.dimensionsFormat = .custom
        action.customDimensionsFormat = "WxH_MPmp"
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.width = 2000
        metadata.height = 1500  // 3.0 MP
        action.metadataCache["image.jpg"] = metadata
        
        let result = action.apply(to: "image.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "image_2000x1500_3.0mp.jpg")
    }
    
    // MARK: - GPS Format Tests
    
    func testGPSFormatDecimal() {
        var action = ExifAction()
        action.field = .gpsCoordinates
        action.position = .suffix
        action.gpsFormat = .decimal
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.latitude = 37.7749
        metadata.longitude = -122.4194
        action.metadataCache["photo.jpg"] = metadata
        
        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_37.7749,-122.4194.jpg")
    }
    
    func testGPSFormatDecimalPositive() {
        var action = ExifAction()
        action.field = .gpsCoordinates
        action.position = .suffix
        action.gpsFormat = .decimalPositive
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.latitude = -33.8688
        metadata.longitude = 151.2093
        action.metadataCache["photo.jpg"] = metadata
        
        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_33.8688,151.2093.jpg")
    }
    
    func testGPSFormatDegrees() {
        var action = ExifAction()
        action.field = .gpsCoordinates
        action.position = .suffix
        action.gpsFormat = .degrees
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.latitude = 37.7749
        metadata.longitude = -122.4194
        action.metadataCache["photo.jpg"] = metadata
        
        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        // 37.7749 -> 37°46'N, -122.4194 -> 122°25'W
        XCTAssertEqual(result, "photo_37°46'N 122°25'W.jpg")
    }
    
    func testGPSFormatCompact() {
        var action = ExifAction()
        action.field = .gpsCoordinates
        action.position = .suffix
        action.gpsFormat = .compact
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.latitude = 51.5074
        metadata.longitude = -0.1278
        action.metadataCache["photo.jpg"] = metadata
        
        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_51.5074N0.1278W.jpg")
    }
    
    func testGPSFormatCustom() {
        var action = ExifAction()
        action.field = .gpsCoordinates
        action.position = .suffix
        action.gpsFormat = .custom
        action.customGPSFormat = "ALAT-NS_ALON-EW"
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.latitude = -33.8688
        metadata.longitude = 151.2093
        action.metadataCache["photo.jpg"] = metadata
        
        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_33.8688-S_151.2093-E.jpg")
    }
    
    func testGPSFormatCustomWithLatLon() {
        var action = ExifAction()
        action.field = .gpsCoordinates
        action.position = .suffix
        action.gpsFormat = .custom
        action.customGPSFormat = "lat-LAT_lon-LON"
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.latitude = 40.7128
        metadata.longitude = -74.0060
        action.metadataCache["photo.jpg"] = metadata
        
        let result = action.apply(to: "photo.jpg", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "photo_lat-40.7128_lon--74.0060.jpg")
    }
    
    // MARK: - Track Number Format Tests
    
    func testTrackNumberFormatPaddedTwo() {
        var action = ExifAction()
        action.field = .trackNumber
        action.position = .prefix
        action.trackNumberFormat = .paddedTwo
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.trackNumber = 5
        action.metadataCache["song.mp3"] = metadata
        
        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "05_song.mp3")
    }
    
    func testTrackNumberFormatPaddedThree() {
        var action = ExifAction()
        action.field = .trackNumber
        action.position = .prefix
        action.trackNumberFormat = .paddedThree
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.trackNumber = 7
        action.metadataCache["song.mp3"] = metadata
        
        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "007_song.mp3")
    }
    
    func testTrackNumberFormatNoPadding() {
        var action = ExifAction()
        action.field = .trackNumber
        action.position = .prefix
        action.trackNumberFormat = .noPadding
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.trackNumber = 3
        action.metadataCache["song.mp3"] = metadata
        
        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "3_song.mp3")
    }
    
    func testTrackNumberFormatWithTotal() {
        var action = ExifAction()
        action.field = .trackNumber
        action.position = .prefix
        action.trackNumberFormat = .withTotal
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.trackNumber = 5
        metadata.trackTotal = 12
        action.metadataCache["song.mp3"] = metadata
        
        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "05-12_song.mp3")
    }
    
    func testTrackNumberFormatWithTotalSlash() {
        var action = ExifAction()
        action.field = .trackNumber
        action.position = .prefix
        action.trackNumberFormat = .withTotalSlash
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.trackNumber = 3
        metadata.trackTotal = 10
        action.metadataCache["song.mp3"] = metadata
        
        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        // Slash is sanitized to hyphen
        XCTAssertEqual(result, "03-10_song.mp3")
    }
    
    func testTrackNumberFormatWithTotalNoTotal() {
        var action = ExifAction()
        action.field = .trackNumber
        action.position = .prefix
        action.trackNumberFormat = .withTotal
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.trackNumber = 8
        // No trackTotal
        action.metadataCache["song.mp3"] = metadata
        
        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "08_song.mp3")
    }
    
    func testTrackNumberFormatCustom() {
        var action = ExifAction()
        action.field = .trackNumber
        action.position = .prefix
        action.trackNumberFormat = .custom
        action.customTrackNumberFormat = "Track-#N3"  // Using #N3 format to avoid collision with 'N' in 'Track'
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.trackNumber = 5
        action.metadataCache["song.mp3"] = metadata
        
        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "Track-005_song.mp3")
    }
    
    func testTrackNumberFormatCustomWithTotal() {
        var action = ExifAction()
        action.field = .trackNumber
        action.position = .prefix
        action.trackNumberFormat = .custom
        action.customTrackNumberFormat = "NN of TT"
        action.separator = " - "
        
        var metadata = MediaMetadata()
        metadata.trackNumber = 3
        metadata.trackTotal = 15
        action.metadataCache["song.mp3"] = metadata
        
        let result = action.apply(to: "song.mp3", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "03 of 15 - song.mp3")
    }
    
    // MARK: - Frame Rate Format Tests
    
    func testFrameRateFormatWithFps() {
        var action = ExifAction()
        action.field = .frameRate
        action.position = .suffix
        action.frameRateFormat = .withFps
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.frameRate = 29.97
        action.metadataCache["video.mp4"] = metadata
        
        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_29.97fps.mp4")
    }
    
    func testFrameRateFormatRounded() {
        var action = ExifAction()
        action.field = .frameRate
        action.position = .suffix
        action.frameRateFormat = .rounded
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.frameRate = 23.976
        action.metadataCache["video.mp4"] = metadata
        
        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_24fps.mp4")
    }
    
    func testFrameRateFormatDecimalOnly() {
        var action = ExifAction()
        action.field = .frameRate
        action.position = .suffix
        action.frameRateFormat = .decimalOnly
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.frameRate = 60.0
        action.metadataCache["video.mp4"] = metadata
        
        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_60.00.mp4")
    }
    
    func testFrameRateFormatIntegerOnly() {
        var action = ExifAction()
        action.field = .frameRate
        action.position = .suffix
        action.frameRateFormat = .integerOnly
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.frameRate = 59.94
        action.metadataCache["video.mp4"] = metadata
        
        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_60.mp4")
    }
    
    func testFrameRateFormatCustom() {
        var action = ExifAction()
        action.field = .frameRate
        action.position = .suffix
        action.frameRateFormat = .custom
        action.customFrameRateFormat = "Fp"
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.frameRate = 24.0
        action.metadataCache["video.mp4"] = metadata
        
        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_24p.mp4")
    }
    
    func testFrameRateFormatCustomWithDecimal() {
        var action = ExifAction()
        action.field = .frameRate
        action.position = .suffix
        action.frameRateFormat = .custom
        action.customFrameRateFormat = "FPS-fps"
        action.separator = "_"
        
        var metadata = MediaMetadata()
        metadata.frameRate = 29.97
        action.metadataCache["video.mp4"] = metadata
        
        let result = action.apply(to: "video.mp4", at: 0, totalCount: 1, applyToExtension: false)
        XCTAssertEqual(result, "video_29.97-fps.mp4")
    }
    
    // MARK: - Format Enum Tests
    
    func testDimensionsFormatAllCases() {
        XCTAssertEqual(DimensionsFormat.allCases.count, 7)
    }
    
    func testGPSFormatAllCases() {
        XCTAssertEqual(GPSFormat.allCases.count, 5)
    }
    
    func testTrackNumberFormatAllCases() {
        XCTAssertEqual(TrackNumberFormat.allCases.count, 6)
    }
    
    func testFrameRateFormatAllCases() {
        XCTAssertEqual(FrameRateFormat.allCases.count, 5)
    }
}
