# Swift Kick Metadata

Fetch metadata for Kick clips without authentication. `KickMetadata` queries Kick's public clip API and returns title, channel, creator, video URL, duration, engagement counts, category, stream context, and thumbnail. No API key, developer account, or login required.

## Features

- 🎯 **No authentication** — uses Kick's public clip API; no API key or login
- 🔗 **Flexible input** — accepts `/clips/`, `?clip=` query-string URLs, or a raw clip ID
- 🎬 **Direct video URL** — exposes `videoFileUrl` plus an `isHLS` flag (HLS vs MP4)
- 📺 **Channel & creator** — channel name, username, ids, profile pictures, and the clip's creator
- 📊 **Engagement metrics** — view and like counts with human-readable formatted variants
- ⏱️ **Duration & timing** — duration plus `createdAt` / `startedAt` dates and formatted helpers
- 🗂️ **Category context** — category, slug, and parent category
- 🔁 **VOD linkback** — `vodUrl` and `vodStartsAt` to jump back to the source stream at the clip offset
- 🔞 **Maturity flags** — `isMature`, `ageLimit`, and `privacy`
- 🔗 **Derived URLs** — computed `url` and `channelUrl`
- 🧱 **Typed errors** — descriptive `KickMetadataError` cases
- ⚡ **Async/await** — a single `async throws` entry point with zero dependencies

## Requirements

- macOS 13.0+ / iOS 16.0+ / tvOS 16.0+ / watchOS 9.0+
- Swift 6.0+
- Xcode 26.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-kick-metadata.git", from: "1.0.0")
]
```

## Usage

### Fetching clip metadata

```swift
import KickMetadata

let clip = try await KickMetadata.fetch("https://kick.com/xqc/clips/clip_01GYXVB5Y8PWAPWCWMSBCFB05X")

print(clip.title)
print("\(clip.channel) — clipped by \(clip.creatorName ?? "Unknown")")
print("Views: \(clip.formattedViewCount ?? "N/A")")
print("Duration: \(clip.formattedDuration)")
```

### Downloading the clip

```swift
let clip = try await KickMetadata.fetch("clip_01GYXVB5Y8PWAPWCWMSBCFB05X")

if let url = clip.videoFileUrl {
    print("Video: \(url)")
    print("Format: \(clip.isHLS ? "HLS" : "MP4")")
}
```

### Linking back to the VOD

```swift
let clip = try await KickMetadata.fetch(url)

if let vodUrl = clip.vodUrl, let offset = clip.vodStartsAt {
    print("VOD: \(vodUrl) at \(offset)s")
}
```

### Error handling

```swift
do {
    let clip = try await KickMetadata.fetch(url)
    print(clip.title)
} catch let error as KickMetadataError {
    switch error {
    case .invalidUrl, .invalidClipId:
        print("Could not parse the input")
    case .clipNotFound:
        print("Clip not found")
    case .rateLimited:
        print("Rate limited — try again later")
    case .networkError(let message), .parsingError(let message):
        print("Failed: \(message)")
    }
}
```

## How It Works

`KickMetadata.fetch` extracts the clip ID from the input (URL or raw ID), then calls Kick's public clip API and maps the response into a fully-populated `ClipMetadata` value.

## Models

| Model | Description |
|-------|-------------|
| `ClipMetadata` | Title, channel, creator, video/thumbnail URLs, duration, view/like counts, category, stream context, dates, maturity flags, and computed `url` / `channelUrl` / `vodUrl` / `videoFileUrl` / `formatted*` / `isHLS` helpers |
| `KickMetadataError` | Typed errors (`invalidUrl`, `invalidClipId`, `clipNotFound`, `rateLimited`, `networkError`, `parsingError`) with `LocalizedError` descriptions |

## Use Cases

- Building download tools for Kick clips
- Embedding clip previews with creator and view-count context
- Aggregating and archiving clip metadata
- Linking clips back to their source VOD at the right offset

## Testing

```bash
swift test
```

Tests cover clip-ID extraction, URL parsing, and model decoding.

## License

MIT License — see LICENSE file for details.

## Author

Created by David Sherlock ([ArrayPress](https://github.com/arraypress)) in 2026.
