//
//  KickMetadataTests.swift
//  KickMetadata
//
//  Created by David Sherlock on 2026.
//

import XCTest
@testable import KickMetadata

final class KickMetadataTests: XCTestCase {
    
    // MARK: - Clip ID Extraction
    
    func testExtractFromClipsPathUrl() throws {
        let id = try ClipID.extract(from: "https://kick.com/spreen/clips/clip_01J8RGZRKHXHXXKJEHGRM932A5")
        XCTAssertEqual(id, "clip_01J8RGZRKHXHXXKJEHGRM932A5")
    }
    
    func testExtractFromQueryParamUrl() throws {
        let id = try ClipID.extract(from: "https://kick.com/mxddy?clip=clip_01GYXVB5Y8PWAPWCWMSBCFB05X")
        XCTAssertEqual(id, "clip_01GYXVB5Y8PWAPWCWMSBCFB05X")
    }
    
    func testExtractFromQueryParamWithOtherParams() throws {
        let id = try ClipID.extract(from: "https://kick.com/destiny?other=x&clip=clip_01H9SKET879NE7N9RJRRDS98J3")
        XCTAssertEqual(id, "clip_01H9SKET879NE7N9RJRRDS98J3")
    }
    
    func testExtractFromQueryParamWithTrailingSlash() throws {
        let id = try ClipID.extract(from: "https://kick.com/channel/?clip=clip_01GYXVB5Y8PWAPWCWMSBCFB05X")
        XCTAssertEqual(id, "clip_01GYXVB5Y8PWAPWCWMSBCFB05X")
    }
    
    func testExtractFromRawClipId() throws {
        let id = try ClipID.extract(from: "clip_01GYXVB5Y8PWAPWCWMSBCFB05X")
        XCTAssertEqual(id, "clip_01GYXVB5Y8PWAPWCWMSBCFB05X")
    }
    
    func testExtractWithWhitespace() throws {
        let id = try ClipID.extract(from: "  clip_01GYXVB5Y8PWAPWCWMSBCFB05X  ")
        XCTAssertEqual(id, "clip_01GYXVB5Y8PWAPWCWMSBCFB05X")
    }
    
    func testExtractInvalidThrows() {
        XCTAssertThrowsError(try ClipID.extract(from: "not-a-clip-url")) { error in
            XCTAssertEqual(error as? KickMetadataError, .invalidClipId)
        }
    }
    
    func testExtractEmptyStringThrows() {
        XCTAssertThrowsError(try ClipID.extract(from: "")) { error in
            XCTAssertEqual(error as? KickMetadataError, .invalidClipId)
        }
    }
    
    func testExtractRegularKickUrlThrows() {
        XCTAssertThrowsError(try ClipID.extract(from: "https://kick.com/xqc")) { error in
            XCTAssertEqual(error as? KickMetadataError, .invalidClipId)
        }
    }
    
    // MARK: - Channel Extraction
    
    func testExtractChannelFromClipsPath() {
        let channel = ClipID.extractChannel(from: "https://kick.com/spreen/clips/clip_01J8RGZRKHXHXXKJEHGRM932A5")
        XCTAssertEqual(channel, "spreen")
    }
    
    func testExtractChannelFromQueryParam() {
        let channel = ClipID.extractChannel(from: "https://kick.com/mxddy?clip=clip_01GYXVB5Y8PWAPWCWMSBCFB05X")
        XCTAssertEqual(channel, "mxddy")
    }
    
    func testExtractChannelFromInvalidUrl() {
        let channel = ClipID.extractChannel(from: "https://example.com/test")
        XCTAssertNil(channel)
    }
    
    // MARK: - ClipMetadata Formatting
    
    func testFormattedDuration() {
        let clip = makeClip(duration: 35)
        XCTAssertEqual(clip.formattedDuration, "0:35")
    }
    
    func testFormattedDurationMinutes() {
        let clip = makeClip(duration: 125)
        XCTAssertEqual(clip.formattedDuration, "2:05")
    }
    
    func testFormattedDurationHours() {
        let clip = makeClip(duration: 3661)
        XCTAssertEqual(clip.formattedDuration, "1:01:01")
    }
    
    func testFormattedViewCount() {
        let clip = makeClip(viewCount: 15420)
        XCTAssertNotNil(clip.formattedViewCount)
        XCTAssertTrue(clip.formattedViewCount!.contains("15"))
    }
    
    func testFormattedViewCountNil() {
        let clip = makeClip(viewCount: nil)
        XCTAssertNil(clip.formattedViewCount)
    }
    
    func testFormattedLikeCount() {
        let clip = makeClip(likeCount: 250)
        XCTAssertNotNil(clip.formattedLikeCount)
    }
    
    func testFormattedLikeCountNil() {
        let clip = makeClip(likeCount: nil)
        XCTAssertNil(clip.formattedLikeCount)
    }
    
    func testFormattedDate() {
        let clip = makeClip(createdAt: Date(timeIntervalSince1970: 1682481453))
        XCTAssertNotNil(clip.formattedDate)
    }
    
    func testFormattedDateNil() {
        let clip = makeClip(createdAt: nil)
        XCTAssertNil(clip.formattedDate)
    }
    
    // MARK: - Computed URLs
    
    func testUrl() {
        let clip = makeClip()
        XCTAssertEqual(clip.url, "https://kick.com/testchannel/clips/clip_TEST123")
    }
    
    func testChannelUrl() {
        let clip = makeClip()
        XCTAssertEqual(clip.channelUrl, "https://kick.com/testchannel")
    }
    
    func testVodUrl() {
        let clip = makeClip(vodId: "abc-123-def")
        XCTAssertEqual(clip.vodUrl, "https://kick.com/testchannel/videos/abc-123-def")
    }
    
    func testVodUrlNil() {
        let clip = makeClip(vodId: nil)
        XCTAssertNil(clip.vodUrl)
    }
    
    // MARK: - Flags
    
    func testAgeLimitMature() {
        let clip = makeClip(isMature: true)
        XCTAssertEqual(clip.ageLimit, 18)
    }
    
    func testAgeLimitNotMature() {
        let clip = makeClip(isMature: false)
        XCTAssertEqual(clip.ageLimit, 0)
    }
    
    func testIsHLS() {
        let clip = makeClip(videoUrl: "https://clips.kick.com/clip/playlist.m3u8")
        XCTAssertTrue(clip.isHLS)
    }
    
    func testIsNotHLS() {
        let clip = makeClip(videoUrl: "https://clips.kick.com/clip.mp4")
        XCTAssertFalse(clip.isHLS)
    }
    
    func testVideoFileUrl() {
        let clip = makeClip(videoUrl: "https://clips.kick.com/clip.mp4")
        XCTAssertNotNil(clip.videoFileUrl)
        XCTAssertEqual(clip.videoFileUrl?.absoluteString, "https://clips.kick.com/clip.mp4")
    }
    
    func testVideoFileUrlNil() {
        let clip = makeClip(videoUrl: nil)
        XCTAssertNil(clip.videoFileUrl)
    }
    
    // MARK: - Error Descriptions
    
    func testAllErrorsHaveDescriptions() {
        let errors: [KickMetadataError] = [
            .invalidUrl,
            .invalidClipId,
            .clipNotFound,
            .rateLimited,
            .networkError("timeout"),
            .parsingError("bad json"),
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
    
    func testErrorEquatable() {
        XCTAssertEqual(KickMetadataError.invalidUrl, .invalidUrl)
        XCTAssertEqual(KickMetadataError.clipNotFound, .clipNotFound)
        XCTAssertNotEqual(KickMetadataError.invalidUrl, .clipNotFound)
    }
    
    // MARK: - Integration Tests (require network)
    
    func testFetchClip() async throws {
        let clip = try await KickMetadata.fetch("https://kick.com/xqc/clips/clip_01KT86AY6TFA1JMTT3M02AZ4YW")
        
        XCTAssertEqual(clip.id, "clip_01KT86AY6TFA1JMTT3M02AZ4YW")
        XCTAssertFalse(clip.title.isEmpty)
        XCTAssertEqual(clip.channel, "xqc")
        XCTAssertNotNil(clip.videoUrl)
        XCTAssertNotNil(clip.videoFileUrl)
        XCTAssertGreaterThan(clip.duration, 0)
    }
    
    func testFetchClipAllFields() async throws {
        let clip = try await KickMetadata.fetch("https://kick.com/xqc/clips/clip_01KT86AY6TFA1JMTT3M02AZ4YW")
        
        // Channel
        XCTAssertNotNil(clip.channelId)
        XCTAssertNotNil(clip.channelUsername)
        XCTAssertNotNil(clip.channelProfilePicture)
        
        // Creator
        XCTAssertNotNil(clip.creatorName)
        XCTAssertNotNil(clip.creatorId)
        
        // Category
        XCTAssertNotNil(clip.category)
        XCTAssertNotNil(clip.categorySlug)
        XCTAssertNotNil(clip.parentCategory)
        
        // Timestamps
        XCTAssertNotNil(clip.createdAt)
        XCTAssertNotNil(clip.startedAt)
        
        // Engagement
        XCTAssertNotNil(clip.viewCount)
        XCTAssertGreaterThan(clip.viewCount ?? 0, 0)
        XCTAssertNotNil(clip.likeCount)
        
        // Stream context
        XCTAssertNotNil(clip.livestreamId)
        XCTAssertNotNil(clip.vodId)
        XCTAssertNotNil(clip.vodStartsAt)
        XCTAssertNotNil(clip.vodUrl)
        
        // Flags — maturity varies by clip; assert the derived age limit is consistent
        XCTAssertEqual(clip.ageLimit, clip.isMature ? 18 : 0)
        XCTAssertNotNil(clip.privacy)
        
        // Thumbnail
        XCTAssertNotNil(clip.thumbnailUrl)
    }
    
    func testFetchClipFromQueryParam() async throws {
        let clip = try await KickMetadata.fetch("https://kick.com/xqc?clip=clip_01KT86AY6TFA1JMTT3M02AZ4YW")
        
        XCTAssertEqual(clip.id, "clip_01KT86AY6TFA1JMTT3M02AZ4YW")
        XCTAssertFalse(clip.title.isEmpty)
    }
    
    func testFetchClipFromRawId() async throws {
        let clip = try await KickMetadata.fetch("clip_01KT86AY6TFA1JMTT3M02AZ4YW")
        
        XCTAssertEqual(clip.id, "clip_01KT86AY6TFA1JMTT3M02AZ4YW")
        XCTAssertFalse(clip.title.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeClip(
        duration: Double = 35,
        viewCount: Int? = 100,
        likeCount: Int? = 10,
        createdAt: Date? = Date(),
        isMature: Bool = false,
        videoUrl: String? = "https://clips.kick.com/clip.mp4",
        vodId: String? = "abc-123-def"
    ) -> ClipMetadata {
        ClipMetadata(
            id: "clip_TEST123",
            title: "Test Clip",
            channel: "testchannel",
            channelId: "12345",
            channelUsername: "TestChannel",
            channelProfilePicture: "https://files.kick.com/pic.webp",
            creatorName: "testcreator",
            creatorId: "67890",
            creatorProfilePicture: nil,
            videoUrl: videoUrl,
            thumbnailUrl: "https://clips.kick.com/thumb.jpg",
            duration: duration,
            category: "Just Chatting",
            categorySlug: "just-chatting",
            parentCategory: "irl",
            createdAt: createdAt,
            startedAt: nil,
            viewCount: viewCount,
            likeCount: likeCount,
            livestreamId: "99999",
            vodId: vodId,
            vodStartsAt: 3600,
            isMature: isMature,
            privacy: "CLIP_PRIVACY_PUBLIC"
        )
    }
    
}
