//
//  ClipMetadata+Derived.swift
//  KickMetadata
//
//  Created by David Sherlock on 2026.
//
//  The clip's derived facts — URLs assembled from its parts, counts and
//  times as display strings. Formatting rules delegate into Support; the
//  one-line derivations are stated here in full.
//

import Foundation

extension ClipMetadata {

    /// The video URL as a typed `URL`.
    public var videoFileUrl: URL? {
        videoUrl.flatMap { URL(string: $0) }
    }

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
        Formatting.duration(seconds: Int(duration))
    }

    /// The view count formatted with locale-appropriate grouping separators.
    public var formattedViewCount: String? {
        viewCount.map { Formatting.count($0) }
    }

    /// The like count formatted with locale-appropriate grouping separators.
    public var formattedLikeCount: String? {
        likeCount.map { Formatting.count($0) }
    }

    /// The creation date formatted as a readable string.
    public var formattedDate: String? {
        createdAt.map { Formatting.date($0) }
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
}
