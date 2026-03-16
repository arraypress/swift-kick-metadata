//
//  ClipMetadata.swift
//  KickMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Metadata about a Kick clip.
///
/// Fetched from Kick's public clip API without authentication.
///
/// ```swift
/// let clip = try await KickMetadata.fetch("https://kick.com/channel/clips/clip_ABC123")
/// print(clip.title)
/// print("\(clip.channel) — clipped by \(clip.creatorName ?? "Unknown")")
/// print("Views: \(clip.formattedViewCount)")
/// print("Duration: \(clip.formattedDuration)")
///
/// if let url = clip.videoFileUrl {
///     print("Download: \(url)")
/// }
/// ```
public struct ClipMetadata: Sendable {

    /// The clip ID (e.g., `"clip_01GYXVB5Y8PWAPWCWMSBCFB05X"`).
    public let id: String

    /// The clip title.
    public let title: String

    // MARK: - Channel

    /// The channel slug (e.g., `"xqc"`).
    public let channel: String

    /// The channel's numeric ID.
    public let channelId: String?

    /// The channel owner's display username.
    ///
    /// May differ from ``channel`` (slug) in capitalisation or formatting.
    public let channelUsername: String?

    /// The channel owner's profile picture URL.
    public let channelProfilePicture: String?

    // MARK: - Creator

    /// The username of the person who created/clipped this.
    public let creatorName: String?

    /// The creator's numeric user ID.
    public let creatorId: String?

    /// The creator's profile picture URL.
    public let creatorProfilePicture: String?

    // MARK: - Video

    /// The direct video URL (MP4 or M3U8).
    ///
    /// Kick clips are typically served as HLS playlists (`.m3u8`). To download
    /// as a playable MP4 file, use `AVAssetExportSession`:
    ///
    /// ```swift
    /// let asset = AVURLAsset(url: clip.videoFileUrl!)
    /// let export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
    /// export.outputURL = destinationUrl
    /// export.outputFileType = .mp4
    /// await export.export()
    /// ```
    ///
    /// For playback, `AVPlayer` handles M3U8 URLs natively.
    public let videoUrl: String?

    /// The video URL as a typed `URL`.
    public var videoFileUrl: URL? {
        videoUrl.flatMap { URL(string: $0) }
    }

    /// The thumbnail image URL.
    public let thumbnailUrl: String?

    /// The clip duration in seconds.
    public let duration: Double

    // MARK: - Category

    /// The category/game name (e.g., `"Slots & Casino"`, `"Just Chatting"`).
    public let category: String?

    /// The category slug (e.g., `"slots"`, `"just-chatting"`).
    public let categorySlug: String?

    /// The parent category (e.g., `"gambling"`, `"irl"`).
    public let parentCategory: String?

    // MARK: - Timestamps

    /// When the clip was created.
    public let createdAt: Date?

    /// When the clipped moment started in the original stream.
    ///
    /// This is the actual stream timestamp, not when the clip was created.
    public let startedAt: Date?

    // MARK: - Engagement

    /// Number of views.
    public let viewCount: Int?

    /// Number of likes.
    public let likeCount: Int?

    // MARK: - Stream Context

    /// The livestream ID this clip was taken from.
    ///
    /// Can be used to identify which stream session the clip belongs to.
    public let livestreamId: String?

    /// The VOD ID for the full recording of the stream.
    ///
    /// Can be used to construct a VOD URL:
    /// `https://kick.com/{channel}/videos/{vodId}`
    public let vodId: String?

    /// The offset in seconds into the VOD where this clip starts.
    ///
    /// Combined with ``vodId``, this lets you link to the exact moment
    /// in the full stream recording.
    public let vodStartsAt: Int?

    // MARK: - Flags

    /// Whether the clip is from a mature/18+ stream.
    public let isMature: Bool

    /// The clip's privacy setting (e.g., `"CLIP_PRIVACY_PUBLIC"`).
    public let privacy: String?

    // MARK: - Computed Properties

    /// The full clip URL on Kick.
    public var url: String {
        "https://kick.com/\(channel)/clips/\(id)"
    }

    /// The channel's profile URL on Kick.
    public var channelUrl: String {
        "https://kick.com/\(channel)"
    }

    /// The full VOD URL, if available.
    ///
    /// Links to the full stream recording this clip was taken from.
    public var vodUrl: String? {
        guard let vodId = vodId, !channel.isEmpty else { return nil }
        return "https://kick.com/\(channel)/videos/\(vodId)"
    }

    /// The duration formatted as `"M:SS"` or `"H:MM:SS"`.
    public var formattedDuration: String {
        let total = Int(duration)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }

    /// The view count formatted with locale-appropriate grouping separators.
    public var formattedViewCount: String? {
        guard let count = viewCount else { return nil }
        return Self.formatNumber(count)
    }

    /// The like count formatted with locale-appropriate grouping separators.
    public var formattedLikeCount: String? {
        guard let count = likeCount else { return nil }
        return Self.formatNumber(count)
    }

    /// The creation date formatted as a readable string.
    public var formattedDate: String? {
        guard let date = createdAt else { return nil }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    /// The age limit (18 if mature, 0 otherwise).
    public var ageLimit: Int {
        isMature ? 18 : 0
    }

    /// Whether the video URL points to an M3U8 playlist (vs direct MP4).
    ///
    /// When `true`, use `AVPlayer` for playback or `AVAssetExportSession`
    /// to download as MP4.
    public var isHLS: Bool {
        videoUrl?.hasSuffix(".m3u8") == true
    }

    /// Formats a number with locale-appropriate grouping separators.
    private static func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
}
