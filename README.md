<p align="center">
  <img src="ReTitle/Assets.xcassets/AppIcon.appiconset/AppIcon128x128.png" alt="ReTitle icon" width="128">
</p>

<h1 align="center">ReTitle</h1>

<p align="center"><b>Rename hundreds of files at once. Preview every change before you commit.</b></p>

<p align="center">
  <a href="https://apps.apple.com/app/retitle/id6757639275">Mac App Store</a> ·
  <a href="https://n14395.com/retitle">Website</a> ·
  <a href="https://n14395.com/support.html">Support</a> ·
  <a href="https://n14395.com/privacy.html">Privacy</a>
</p>

ReTitle is a powerful yet intuitive batch file renaming tool for macOS. Whether you're organizing photos, managing music libraries, or tidying up documents, ReTitle makes renaming multiple files fast and effortless — with a live preview so you always know exactly what will happen before clicking Apply.

![Search & Replace in ReTitle, showing the live before/after preview](Screenshots/Screenshot%202.png)

## Features

### Preview before you apply

Every change is shown in real time. Modified text is highlighted in blue, and potential naming conflicts appear in red, so nothing is a surprise.

### Seven rename actions

| Action | What it does |
|---|---|
| **Replace** | Find and replace text, with full regular expression support |
| **Insert** | Add text at the beginning, end, or any position within the filename |
| **Remove** | Strip characters from the start, end, a range, or remove specific characters |
| **Case** | Convert to UPPERCASE, lowercase, Title Case, or Sentence case |
| **Number** | Add sequential numbering with configurable start, increment, padding, and separator |
| **Date/Time** | Insert timestamps in your preferred format |
| **Metadata** | Rename files using EXIF data, ID3 tags, or document properties |

![Sequential numbering applied to a batch of photos](Screenshots/Screenshot%203.png)

### Comprehensive metadata support

Extract and apply metadata directly from your files:

- **Photos** — camera make/model, lens, focal length, aperture, shutter speed, ISO, dimensions, GPS coordinates
- **Music** — title, artist, album, track number, genre, year, BPM
- **Video** — codec, frame rate, resolution, duration
- **Documents** — author, page count, keywords, PDF version

![Renaming images using their pixel dimensions from metadata](Screenshots/Screenshot%205.png)

### Flexible workflow

- Drag and drop files or add them with the file picker
- Chain multiple rename operations together
- Optionally move renamed files to a new destination folder
- Rename file extensions too, with a single toggle
- Right-click any file to edit its name or reveal it in Finder
- Undo and redo any rename with ⌘Z and ⌘⇧Z

### Private by design

Files are renamed locally — nothing leaves your Mac. No telemetry, no account, no network calls.

## Requirements

- macOS 26.2 or later

## Building from source

Open `ReTitle.xcodeproj` in Xcode (26.2 or later) and build the **ReTitle** scheme, or use the build script:

```sh
./build.sh                 # build the production build/ReTitle.app
./build.sh --dmg           # …and package it into build/ReTitle.dmg
./build.sh --sign          # …Developer ID sign the .app and .dmg, notarize and staple
./build.sh --publish vN.N  # tag, push and cut a GitHub release from build/ReTitle.dmg
```

Unit tests live in `ReTitleTests` and can be run from Xcode (⌘U) or with:

```sh
xcodebuild test -project ReTitle.xcodeproj -scheme ReTitle
```

## Architecture

ReTitle is built with SwiftUI using the `@Observable` macro. Each rename action implements a common `RenameAction` protocol, so transformations are applied uniformly and previewed live by `RenameViewModel`. Metadata extraction uses ImageIO for photos, AVFoundation for audio/video, and PDFKit for documents. The app is sandboxed, with access limited to files you explicitly select.
