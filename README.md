# Swift Kick Metadata

A Swift library for fetching metadata from Kick clips. No API key, developer account, or authentication required — uses Kick's public clip API.

## Features

- 🎯 **Simple API** — fetch clip metadata with a single async call
- 📊 **Rich metadata** — title, channel, creator, duration, views, likes, category, date
- 🎬 **Video URL** — HLS or MP4 link ready for playback or export
- 🖼️ **Thumbnail URL** — clip thumbnail image
- 🔗 **Stream context** — livestream ID, VOD ID, and VOD offset to link back to the full recording
- 🔒 **No API key required** — uses Kick's public API
- 🍎 **Cross-platform** — macOS, iOS, tvOS, watchOS
- ⚡ **Async/await** native — built for modern Swift concurrency
- 🛡️ **Typed error handling** — specific errors for every failure case
- 🔗 **Flexible input** — supports all Kick clip URL formats and raw clip IDs

## Requirements

- macOS 13.0+ / iOS 16.0+ / tvOS 16.0+ / watchOS 9.0+
- Swift 6.0+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-kick-metadata.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Choose version requirements

## Usage

### Fetch Clip Metadata

```swift
import KickMetadata

let clip = try await KickMetadata.fetch("https://kick.com/xqc/clips/clip_01GYXVB5Y8PWAPWCWMSBCFB05X")

print(clip.title)
print("\(clip.channel) — clipped by \(clip.creatorName ?? "Unknown")")
print("Duration: \(clip.formattedDuration)")
print("Views: \(clip.formattedViewCount ?? "N/A")")
print("Likes: \(clip.formattedLikeCount ?? "N/A")")
print("Category: \(clip.category ?? "N/A")")
print("Date: \(clip.formattedDate ?? "N/A")")
print("Mature: \(clip.isMature)")
```

### Video URL

Kick clips are typically served as HLS playlists (`.m3u8`). `AVPlayer` handles these natively for playback. To download as an MP4 file, use `AVAssetExportSession`:

```swift
import AVFoundation

let clip = try await KickMetadata.fetch("https://kick.com/channel/clips/clip_ABC123")

if let url = clip.videoFileUrl {
    if clip.isHLS {
        // Export HLS to MP4 for download/processing
        let asset = AVURLAsset(url: url)
        let export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        export.outputURL = destinationUrl
        export.outputFileType = .mp4
        await export.export()
    } else {
        // Direct MP4 — download directly
        let (data, _) = try await URLSession.shared.data(from: url)
    }
}
```

### Stream Context

Clips include metadata linking back to the original stream recording:

```swift
let clip = try await KickMetadata.fetch("https://kick.com/channel/clips/clip_ABC123")

// Which stream was this clipped from?
print("Livestream ID: \(clip.livestreamId ?? "N/A")")

// Link to the full VOD
if let vodUrl = clip.vodUrl {
    print("Full VOD: \(vodUrl)")
}

// Exact offset into the VOD
if let offset = clip.vodStartsAt {
    print("Starts at: \(offset) seconds into the VOD")
}

// When the clipped moment actually happened in the stream
if let startedAt = clip.startedAt {
    print("Stream time: \(startedAt)")
}
```

### URL Formats

All common Kick clip URL formats are supported:

```swift
// Clips path
let clip = try await KickMetadata.fetch("https://kick.com/channel/clips/clip_ABC123")

// Query parameter
let clip = try await KickMetadata.fetch("https://kick.com/channel?clip=clip_ABC123")

// With other query params
let clip = try await KickMetadata.fetch("https://kick.com/channel?other=x&clip=clip_ABC123")

// Raw clip ID
let clip = try await KickMetadata.fetch("clip_01GYXVB5Y8PWAPWCWMSBCFB05X")
```

### Error Handling

```swift
do {
    let clip = try await KickMetadata.fetch(url)
    print(clip.title)
} catch KickMetadataError.clipNotFound {
    print("Clip doesn't exist or was deleted")
} catch KickMetadataError.rateLimited {
    print("Too many requests — try again later")
} catch KickMetadataError.invalidClipId {
    print("Couldn't extract a clip ID from the URL")
} catch {
    print("Error: \(error.localizedDescription)")
}
```

## Models

### `ClipMetadata`

The main result struct containing all clip data.

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Clip ID (e.g., `"clip_ABC123"`) |
| `title` | `String` | Clip title |
| `channel` | `String` | Channel slug |
| `channelId` | `String?` | Channel's numeric ID |
| `channelUsername` | `String?` | Channel owner's display username |
| `channelProfilePicture` | `String?` | Channel owner's profile picture URL |
| `creatorName` | `String?` | Who created/clipped this |
| `creatorId` | `String?` | Creator's numeric ID |
| `creatorProfilePicture` | `String?` | Creator's profile picture URL |
| `videoUrl` | `String?` | Direct video URL (MP4 or M3U8) |
| `videoFileUrl` | `URL?` | Typed video URL |
| `thumbnailUrl` | `String?` | Thumbnail image URL |
| `duration` | `Double` | Duration in seconds |
| `formattedDuration` | `String` | Duration as `"M:SS"` or `"H:MM:SS"` |
| `category` | `String?` | Game/category name |
| `categorySlug` | `String?` | Category slug |
| `parentCategory` | `String?` | Parent category (e.g., `"gambling"`) |
| `createdAt` | `Date?` | When the clip was created |
| `formattedDate` | `String?` | Readable date string |
| `startedAt` | `Date?` | When the clipped moment started in the stream |
| `viewCount` | `Int?` | Number of views |
| `formattedViewCount` | `String?` | Views with grouping separators |
| `likeCount` | `Int?` | Number of likes |
| `formattedLikeCount` | `String?` | Likes with grouping separators |
| `livestreamId` | `String?` | ID of the stream this was clipped from |
| `vodId` | `String?` | VOD ID for the full stream recording |
| `vodStartsAt` | `Int?` | Offset in seconds into the VOD |
| `vodUrl` | `String?` | Full VOD URL on Kick |
| `isMature` | `Bool` | Whether from 18+ stream |
| `ageLimit` | `Int` | 18 if mature, 0 otherwise |
| `privacy` | `String?` | Privacy setting (e.g., `"CLIP_PRIVACY_PUBLIC"`) |
| `url` | `String` | Full clip URL on Kick |
| `channelUrl` | `String` | Channel profile URL |
| `isHLS` | `Bool` | Whether video is M3U8 vs MP4 |

## How It Works

The library makes a single API call:

1. **Extract clip ID** — from the URL path (`/clips/clip_ABC`) or query parameter (`?clip=clip_ABC`)
2. **Call Kick's clip API** — `GET https://kick.com/api/v2/clips/{clip_id}/play`
3. **Parse the response** — the clip object is nested under a `"clip"` key and contains all metadata including video URL, channel/creator info, category, engagement counts, and stream context

No authentication, no tokens, no session setup. One request, one response.

## Video Format Note

Kick clips are served as HLS playlists (`.m3u8`), not direct MP4 files. This means:

- **Playback**: `AVPlayer` handles M3U8 natively — just pass the URL
- **Download**: Use `AVAssetExportSession` to export as MP4
- **Transcription**: `AVAsset` (used by `SFSpeechRecognizer`) accepts M3U8 URLs directly
- **OCR**: `VideoProcessor` (used by Vision framework) accepts `AVAsset` which handles M3U8

Apple's AV frameworks handle HLS transparently, so in practice the format rarely matters.

## Limitations

- **Clips only** — This library handles clips, not VODs or live streams. VODs require M3U8 playlist handling and clips are the shareable unit on Kick.
- **HLS format** — Video URLs are M3U8 playlists, not direct MP4 files. See the video format note above.
- **Rate limiting** — Kick may rate-limit requests from IPs making too many calls.
- **API stability** — This is an unofficial API endpoint that Kick may change at any time. Updates will be provided as needed.

## Testing

```bash
swift test
```

The test suite includes unit tests for clip ID extraction, URL format handling, formatting, computed properties, and stream context fields, plus integration tests that hit Kick's live API and verify all fields are populated.

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License — see LICENSE file for details.

## Author

Created by David Sherlock ([ArrayPress](https://github.com/arraypress)) in 2026.
