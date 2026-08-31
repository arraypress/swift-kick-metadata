//
//  ClipID.swift
//  KickMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Utility for extracting Kick clip IDs from various URL formats.
///
/// Supports both `/clips/` path and `?clip=` query parameter formats.
public enum ClipID {

    /// Regex patterns for extracting clip IDs from Kick URLs.
    ///
    /// Matches:
    /// - `kick.com/channel/clips/clip_ABC123`
    /// - `kick.com/channel?clip=clip_ABC123`
    /// - `kick.com/channel/?clip=clip_ABC123`
    /// - `kick.com/channel?other=x&clip=clip_ABC123`
    private static let patterns = [
        #"kick\.com/[\w-]+/clips/(clip_[\w-]+)"#,
        #"kick\.com/[\w-]+/?\?(?:[^#]*&)?clip=(clip_[\w-]+)"#,
    ]

    /// Extracts a clip ID from a URL string.
    ///
    /// Accepts:
    /// - `https://kick.com/channel/clips/clip_01GYXVB5Y8PWAPWCWMSBCFB05X`
    /// - `https://kick.com/channel?clip=clip_01GYXVB5Y8PWAPWCWMSBCFB05X`
    /// - Raw clip IDs starting with `clip_`
    ///
    /// - Parameter input: A Kick clip URL or raw clip ID.
    /// - Throws: ``KickMetadataError/invalidClipId`` if no valid ID can be extracted.
    /// - Returns: The clip ID string (e.g., `"clip_01GYXVB5Y8PWAPWCWMSBCFB05X"`).
    public static func extract(from input: String) throws -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)

        // Raw clip ID
        if trimmed.hasPrefix("clip_"), trimmed.count > 10 {
            let rawPattern = #"^clip_[\w-]+$"#
            if let regex = try? NSRegularExpression(pattern: rawPattern),
               regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) != nil {
                return trimmed
            }
        }

        // URL patterns
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(trimmed.startIndex..., in: trimmed)
                if let match = regex.firstMatch(in: trimmed, range: range),
                   let idRange = Range(match.range(at: 1), in: trimmed) {
                    return String(trimmed[idRange])
                }
            }
        }

        throw KickMetadataError.invalidClipId
    }

    /// Extracts the channel slug from a Kick clip URL.
    ///
    /// - Parameter input: A Kick clip URL.
    /// - Returns: The channel slug, or `nil` if not found.
    public static func extractChannel(from input: String) -> String? {
        let pattern = #"kick\.com/([\w-]+)(?:/clips/|\?)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        let range = NSRange(input.startIndex..., in: input)
        guard let match = regex.firstMatch(in: input, range: range),
              let channelRange = Range(match.range(at: 1), in: input) else { return nil }
        let candidate = String(input[channelRange])
        let reserved = ["video", "categories", "search", "auth"]
        return reserved.contains(candidate.lowercased()) ? nil : candidate
    }
    
}
