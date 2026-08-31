//
//  SupportTests.swift
//  KickMetadataTests
//
//  Created by David Sherlock on 2026.
//
//  The extracted rules pinned directly — no model constructed.
//

import XCTest
@testable import KickMetadata

final class SupportTests: XCTestCase {

    func testDurationFormatting() {
        XCTAssertEqual(Formatting.duration(seconds: 0), "0:00")
        XCTAssertEqual(Formatting.duration(seconds: 3599), "59:59")
        XCTAssertEqual(Formatting.duration(seconds: 3600), "1:00:00")
    }

    func testCountFormattingWithPinnedLocale() {
        XCTAssertEqual(Formatting.count(1234567, locale: Locale(identifier: "en_US")), "1,234,567")
    }

    func testClipIDFromMultiParameterQuery() throws {
        XCTAssertEqual(
            try ClipID.extract(from: "https://kick.com/channel?foo=1&clip=clip_01GYXVB5Y8PW"),
            "clip_01GYXVB5Y8PW"
        )
    }
}
