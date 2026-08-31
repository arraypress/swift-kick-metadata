//
//  Formatting.swift
//  KickMetadata
//
//  Created by David Sherlock on 2026.
//
//  Durations, counts and dates as the strings a caller shows. Pure
//  functions, so each rule is pinned by a test that constructs no model;
//  the models delegate here instead of formatting themselves.
//

import Foundation

/// Presentation formatting for derived, human-readable strings.
enum Formatting {

    /// Seconds as `"M:SS"`, growing to `"H:MM:SS"` past an hour.
    static func duration(seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }

    /// A count with locale-appropriate grouping separators.
    static func count(_ value: Int, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// A date in the short readable form the fetchers all use.
    static func date(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}
