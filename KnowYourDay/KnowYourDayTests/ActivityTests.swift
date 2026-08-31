//
//  ActivityTests.swift
//  KnowYourDayTests
//
//
//  Created by Sakshi Singh on 30/08/26.
//

import XCTest
@testable import KnowYourDay

final class ActivityTests: XCTestCase {

    func test_rawValues_matchRankingServicesActivityNamesExactly() {
        XCTAssertEqual(Activity.skiing.rawValue, "Skiing")
        XCTAssertEqual(Activity.surfing.rawValue, "Surfing")
        XCTAssertEqual(Activity.outdoor.rawValue, "Outdoor")
        XCTAssertEqual(Activity.indoor.rawValue, "Indoor")
    }

    func test_rankedActivities_mapsKnownNames_preservingOrder() {
        let ranking = DayRanking(date: "2026-01-01", ranking: ["Surfing", "Skiing", "Outdoor", "Indoor"])
        XCTAssertEqual(ranking.rankedActivities, [.surfing, .skiing, .outdoor, .indoor])
    }

    func test_topActivity_isTheFirstEntryInRanking() {
        let ranking = DayRanking(date: "2026-01-01", ranking: ["Indoor", "Outdoor", "Skiing", "Surfing"])
        XCTAssertEqual(ranking.topActivity, .indoor)
    }

    func test_topActivity_isNil_whenRankingIsEmpty() {
        let ranking = DayRanking(date: "2026-01-01", ranking: [])
        XCTAssertNil(ranking.topActivity)
    }

    func test_rankedActivities_silentlyDropsAnyUnrecognizedName() {
        // Documents existing (defensive) behavior: compactMap means a typo'd
        // or unexpected name doesn't crash, it just vanishes from the list.
        let ranking = DayRanking(date: "2026-01-01", ranking: ["Surfing", "Unknown", "Indoor"])
        XCTAssertEqual(ranking.rankedActivities, [.surfing, .indoor])
    }

    func test_displayName_expandsOutdoorAndIndoor_toFullSightseeingLabels() {
        XCTAssertEqual(Activity.outdoor.displayName, "Outdoor Sightseeing")
        XCTAssertEqual(Activity.indoor.displayName, "Indoor Sightseeing")
        XCTAssertEqual(Activity.skiing.displayName, "Skiing")
        XCTAssertEqual(Activity.surfing.displayName, "Surfing")
    }
}
