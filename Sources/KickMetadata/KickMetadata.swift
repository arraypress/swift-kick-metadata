//
//  KickMetadata.swift
//  KickMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Fetch metadata from Kick clips without authentication.
///
/// Uses Kick's public clip API (`kick.com/api/v2/clips/{id}/play`) to fetch
/// clip metadata including title, channel, creator, video URL, duration,
/// thumbnail, view/like counts, category, and stream context. No API key
/// or login required.
///
/// ## Quick Start
///
/// ```swift
/// import KickMetadata
///
/// let clip = try await KickMetadata.fetch("https://kick.com/xqc/clips/clip_01GYXVB5Y8PWAPWCWMSBCFB05X")
///
/// print(clip.title)
/// print("\(clip.channel) — clipped by \(clip.creatorName ?? "Unknown")")
/// print("Views: \(clip.formattedViewCount ?? "N/A")")
/// print("Duration: \(clip.formattedDuration)")
///
/// if let url = clip.videoFileUrl {
///     print("Video: \(url)")
///     print("Format: \(clip.isHLS ? "HLS" : "MP4")")
/// }
///
/// // Link back to the full VOD at the clip's offset
/// if let vodUrl = clip.vodUrl, let offset = clip.vodStartsAt {
///     print("VOD: \(vodUrl) at \(offset)s")
/// }
/// ```
///
/// ## Supported URL Formats
///
/// - `https://kick.com/channel/clips/clip_ABC123`
/// - `https://kick.com/channel?clip=clip_ABC123`
/// - `https://kick.com/channel/?clip=clip_ABC123`
/// - `https://kick.com/channel?other=x&clip=clip_ABC123`
/// - Raw clip IDs (e.g., `"clip_01GYXVB5Y8PWAPWCWMSBCFB05X"`)
public enum KickMetadata {

    // MARK: - Configuration

    /// The base URL for Kick's public API.
    private static let apiBase = "https://kick.com/api"

    /// The User-Agent header sent with all requests.
    private static let userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36"

    // MARK: - Public API

    /// Fetches metadata for a Kick clip.
    ///
    /// Queries Kick's public clip API and returns comprehensive metadata
    /// including title, channel, creator, video URL, duration, engagement
    /// counts, category, stream context, and thumbnail.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let clip = try await KickMetadata.fetch("https://kick.com/xqc/clips/clip_ABC123")
    ///
    /// print(clip.title)
    /// print(clip.formattedDuration)
    /// print(clip.formattedViewCount ?? "N/A")
    ///
    /// // Direct video URL
    /// if let url = clip.videoFileUrl {
    ///     print("Video: \(url)")
    /// }
    /// ```
    ///
    /// - Parameter input: A Kick clip URL or raw clip ID.
    /// - Throws: ``KickMetadataError`` if the metadata cannot be retrieved.
    /// - Returns: A ``ClipMetadata`` with all available fields populated.
    public static func fetch(_ input: String) async throws -> ClipMetadata {
        let clipId = try ClipID.extract(from: input)
        let clip = try await fetchClipAPI(clipId: clipId)
        return clip
    }

    // MARK: - API

    /// Fetches clip data from Kick's public clip API.
    private static func fetchClipAPI(clipId: String) async throws -> ClipMetadata {
        guard let url = URL(string: "\(apiBase)/v2/clips/\(clipId)/play") else {
            throw KickMetadataError.parsingError("Invalid API URL")
        }

        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 404 { throw KickMetadataError.clipNotFound }
            if httpResponse.statusCode == 429 { throw KickMetadataError.rateLimited }
            if httpResponse.statusCode != 200 {
                throw KickMetadataError.networkError("HTTP \(httpResponse.statusCode)")
            }
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let clip = json["clip"] as? [String: Any] else {
            throw KickMetadataError.clipNotFound
        }

        return parseClip(clip, clipId: clipId)
    }

    // MARK: - Parsing

    /// Parses a clip JSON dictionary into a ``ClipMetadata`` struct.
    private static func parseClip(_ clip: [String: Any], clipId: String) -> ClipMetadata {
        let channel = clip["channel"] as? [String: Any]
        let creator = clip["creator"] as? [String: Any]
        let category = clip["category"] as? [String: Any]
        let vod = clip["vod"] as? [String: Any]

        // Channel ID — may be Int or String
        let channelId: String? = {
            if let id = channel?["id"] as? Int { return String(id) }
            if let id = channel?["id"] as? String { return id }
            return nil
        }()

        // Creator ID — may be Int or String
        let creatorId: String? = {
            if let id = creator?["id"] as? Int { return String(id) }
            if let id = creator?["id"] as? String { return id }
            return nil
        }()

        // Livestream ID — may be Int or String
        let livestreamId: String? = {
            if let id = clip["livestream_id"] as? String { return id }
            if let id = clip["livestream_id"] as? Int { return String(id) }
            return nil
        }()

        // Duration — may be Int or Double
        let duration: Double = {
            if let d = clip["duration"] as? Double { return d }
            if let d = clip["duration"] as? Int { return Double(d) }
            return 0
        }()

        // VOD starts at — may be Int or Double
        let vodStartsAt: Int? = {
            if let v = clip["vod_starts_at"] as? Int { return v }
            if let v = clip["vod_starts_at"] as? Double { return Int(v) }
            return nil
        }()

        return ClipMetadata(
            id: clipId,
            title: clip["title"] as? String ?? "",
            channel: channel?["slug"] as? String ?? "",
            channelId: channelId,
            channelUsername: channel?["username"] as? String,
            channelProfilePicture: channel?["profile_picture"] as? String,
            creatorName: creator?["username"] as? String,
            creatorId: creatorId,
            creatorProfilePicture: creator?["profile_picture"] as? String,
            videoUrl: clip["clip_url"] as? String,
            thumbnailUrl: clip["thumbnail_url"] as? String,
            duration: duration,
            category: category?["name"] as? String,
            categorySlug: category?["slug"] as? String,
            parentCategory: category?["parent_category"] as? String,
            createdAt: parseDate(clip["created_at"] as? String),
            startedAt: parseDate(clip["started_at"] as? String),
            viewCount: clip["views"] as? Int ?? clip["view_count"] as? Int,
            likeCount: clip["likes"] as? Int ?? clip["likes_count"] as? Int,
            livestreamId: livestreamId,
            vodId: vod?["id"] as? String,
            vodStartsAt: vodStartsAt,
            isMature: clip["is_mature"] as? Bool ?? false,
            privacy: clip["privacy"] as? String
        )
    }

    // MARK: - Helpers

    /// Parses an ISO 8601 date string, handling both fractional and standard formats.
    private static func parseDate(_ dateStr: String?) -> Date? {
        guard let dateStr = dateStr else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateStr) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dateStr)
    }
    
}
