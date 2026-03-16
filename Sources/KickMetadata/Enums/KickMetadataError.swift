//
//  KickMetadataError.swift
//  KickMetadata
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// Errors that can occur when fetching Kick clip metadata.
///
/// ```swift
/// do {
///     let clip = try await KickMetadata.fetch(url)
/// } catch KickMetadataError.clipNotFound {
///     print("Clip doesn't exist or was deleted")
/// } catch KickMetadataError.rateLimited {
///     print("Too many requests — try again later")
/// } catch {
///     print(error.localizedDescription)
/// }
/// ```
public enum KickMetadataError: Error, LocalizedError, Equatable, Sendable {
    
    /// The provided URL is not a valid Kick clip URL.
    case invalidUrl
    
    /// Could not extract a clip ID from the URL.
    case invalidClipId
    
    /// The clip was not found (deleted or unavailable).
    case clipNotFound
    
    /// Kick is rate-limiting requests from this IP.
    case rateLimited
    
    /// A network request failed.
    case networkError(String)
    
    /// Failed to parse response data.
    case parsingError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "Invalid Kick URL. Provide a clip URL like https://kick.com/channel/clips/clip_ABC123"
        case .invalidClipId:
            return "Could not extract a clip ID from the URL."
        case .clipNotFound:
            return "Clip not found. It may have been deleted."
        case .rateLimited:
            return "Kick is rate-limiting requests. Try again later."
        case .networkError(let message):
            return "Network error: \(message)"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        }
    }
    
}
