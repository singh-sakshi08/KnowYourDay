//
//  RankingServiceTests.swift
//  KnowYourDayTests
//
//  Created by Sakshi Singh on 30/08/26.
//

import XCTest
@testable import KnowYourDay

final class RankingServiceTests: XCTestCase {

    private var rankingService: RankingSerivce!

    override func setUp() {
        super.setUp()
        rankingService = RankingSerivce()
    }

    override func tearDown() {
        rankingService = nil
        super.tearDown()
    }

    // MARK: - Full pipeline, against the fixture's hand-computed table

    /// From ExpandedRankingFixture's own header comment.
    private let expectedRankings: [String: [String]] = [
        "2026-10-01": ["Outdoor", "Surfing", "Indoor", "Skiing"],
        "2026-10-02": ["Outdoor", "Surfing", "Indoor", "Skiing"],
        "2026-10-03": ["Surfing", "Indoor", "Outdoor", "Skiing"],
        "2026-10-04": ["Skiing", "Indoor", "Outdoor", "Surfing"],
        "2026-10-05": ["Surfing", "Indoor", "Outdoor", "Skiing"],
        "2026-10-06": ["Surfing", "Indoor", "Outdoor", "Skiing"],
        "2026-10-07": ["Skiing", "Indoor", "Outdoor", "Surfing"],
        "2026-10-08": ["Skiing", "Indoor", "Outdoor", "Surfing"],
        "2026-10-09": ["Surfing", "Skiing", "Indoor", "Outdoor"],
        "2026-10-10": ["Surfing", "Outdoor", "Indoor", "Skiing"],
        "2026-10-11": ["Skiing", "Surfing", "Indoor", "Outdoor"],
        "2026-10-12": ["Indoor", "Skiing", "Outdoor", "Surfing"]
    ]

    func test_getRanking_matchesHandComputedExpectations_forEveryFixtureDay() {
        let results = rankingService.getRanking(
            forecastResponse: ExpandedRankingFixture.forecast,
            marineResponse: ExpandedRankingFixture.marine
        )

        XCTAssertEqual(results.count, 12, "Fixture provides 12 days; getRanking should return one DayRanking per day.")

        for dayRanking in results {
            guard let expected = expectedRankings[dayRanking.date] else {
                XCTFail("Unexpected date in results: \(dayRanking.date)")
                continue
            }
            XCTAssertEqual(dayRanking.ranking, expected, "Ranking mismatch on \(dayRanking.date)")
        }
    }

    func test_getRanking_withoutHourlySnowDepth_stillDisqualifiesSkiing() {
        let results = rankingService.getRanking(
            forecastResponse: ExpandedRankingFixture.forecastWithoutHourlySnowDepth,
            marineResponse: ExpandedRankingFixture.marine
        )

        XCTAssertEqual(results.count, 12)
        for dayRanking in results {
            XCTAssertFalse(dayRanking.ranking.isEmpty)
            // Skiing disqualified everywhere means it only ever wins a
            // zero-tie (per zeroTiePriority, Skiing outranks only Surfing),
            // so it should never appear ranked #1 across this fixture.
            XCTAssertNotEqual(dayRanking.ranking.first, "Skiing", "Day \(dayRanking.date): skiing should be disqualified with no hourly snow_depth data at all.")
        }
    }

    // MARK: - findSkiingScore isolated checks

    func test_findSkiingScore_returnsZero_whenTempMaxAboveFiveDegrees() {
        let day = makeDay(temperatureMax: 6, temperatureMin: -2, snowfallSum: 3, windspeedMax: 10, weathercode: 1, snowDepthCm: 20)
        XCTAssertEqual(rankingService.findSkiingScore(day), 0.0)
    }

    func test_findSkiingScore_returnsZero_whenTempMinBelowNegativeTwenty() {
        let day = makeDay(temperatureMax: -15, temperatureMin: -25, snowfallSum: 3, windspeedMax: 10, weathercode: 1, snowDepthCm: 20)
        XCTAssertEqual(rankingService.findSkiingScore(day), 0.0)
    }

    func test_findSkiingScore_returnsZero_whenWindAboveSixty() {
        let day = makeDay(temperatureMax: -5, temperatureMin: -10, snowfallSum: 3, windspeedMax: 65, weathercode: 1, snowDepthCm: 20)
        XCTAssertEqual(rankingService.findSkiingScore(day), 0.0)
    }

    func test_findSkiingScore_returnsZero_onThunderstormWeatherCode() {
        for code in [95, 96, 99] {
            let day = makeDay(temperatureMax: -5, temperatureMin: -10, snowfallSum: 3, windspeedMax: 10, weathercode: code, snowDepthCm: 20)
            XCTAssertEqual(rankingService.findSkiingScore(day), 0.0, "weathercode \(code) should disqualify skiing.")
        }
    }

    func test_findSkiingScore_returnsZero_whenSnowDepthDataIsMissingEntirely() {
        // This is the `snowDepth.map { $0 < 1.0 } ?? true` branch
        // (RankingService.swift:81) — nil snow depth disqualifies, same as
        // confirmed no-snow-on-ground.
        let day = makeDay(temperatureMax: -5, temperatureMin: -10, snowfallSum: 3, windspeedMax: 10, weathercode: 1, snowDepthCm: nil)
        XCTAssertEqual(rankingService.findSkiingScore(day), 0.0, "Missing snow_depth data should disqualify skiing outright, not just skip a scored band.")
    }

    func test_findSkiingScore_isIdeal_underPerfectConditions() {
        // tempMax in [-10,-1], wind < 20, code in {0,1,2}, snowfall >= 5,
        // snowDepth >= 30 -> every band should hit 1.0, average 1.0.
        let day = makeDay(temperatureMax: -5, temperatureMin: -10, snowfallSum: 6, windspeedMax: 10, weathercode: 0, snowDepthCm: 35)
        XCTAssertEqual(rankingService.findSkiingScore(day), 1.0, accuracy: 0.0001)
    }

    // MARK: - findSurfingScore isolated checks

    func test_findSurfingScore_returnsZero_whenMarineDataIsNil() {
        let day = makeDay(temperatureMax: 20, temperatureMin: 15, windspeedMax: 10, weathercode: 1)
        XCTAssertEqual(rankingService.findSurfingScore(day, nil), 0.0, "No marine data for a date (e.g. a landlocked city) must score surfing 0, not crash.")
    }

    func test_findSurfingScore_returnsZero_whenWaveHeightBelowMinimum() {
        let day = makeDay(temperatureMax: 20, temperatureMin: 15, windspeedMax: 10, weathercode: 1)
        let marine = DayMarine(date: day.date, waveHeightMax: 0.2, wavePeriodMax: 10, swellWaveHeightMax: nil, swellWavePeriodMax: nil)
        XCTAssertEqual(rankingService.findSurfingScore(day, marine), 0.0)
    }

    func test_findSurfingScore_returnsZero_whenWaveHeightAboveMaximum() {
        let day = makeDay(temperatureMax: 20, temperatureMin: 15, windspeedMax: 10, weathercode: 1)
        let marine = DayMarine(date: day.date, waveHeightMax: 4.5, wavePeriodMax: 10, swellWaveHeightMax: nil, swellWavePeriodMax: nil)
        XCTAssertEqual(rankingService.findSurfingScore(day, marine), 0.0)
    }

    func test_findSurfingScore_fallsBackToSwellFields_whenPrimaryFieldsAreNil() {
        let day = makeDay(temperatureMax: 20, temperatureMin: 15, windspeedMax: 10, weathercode: 1)
        let marine = DayMarine(date: day.date, waveHeightMax: nil, wavePeriodMax: nil, swellWaveHeightMax: 1.5, swellWavePeriodMax: 11)
        XCTAssertGreaterThan(rankingService.findSurfingScore(day, marine), 0.0, "Should fall back to swell_wave_height_max/swell_wave_period_max when the primary fields are nil.")
    }

    // MARK: - findOutdoorScore isolated checks

    func test_findOutdoorScore_returnsZero_whenPrecipitationAboveTenMm() {
        let day = makeDay(temperatureMax: 20, temperatureMin: 10, precipitationSum: 12, windspeedMax: 10, weathercode: 1)
        XCTAssertEqual(rankingService.findOutdoorScore(day), 0.0)
    }

    func test_findOutdoorScore_returnsZero_whenTempMinBelowZero() {
        let day = makeDay(temperatureMax: 20, temperatureMin: -1, precipitationSum: 0, windspeedMax: 10, weathercode: 1)
        XCTAssertEqual(rankingService.findOutdoorScore(day), 0.0)
    }

    func test_findOutdoorScore_isIdeal_underPerfectConditions() {
        let day = makeDay(temperatureMax: 20, temperatureMin: 15, precipitationSum: 0, windspeedMax: 10, weathercode: 0)
        XCTAssertEqual(rankingService.findOutdoorScore(day), 1.0, accuracy: 0.0001)
    }

    // MARK: - findIndoorScore

    func test_findIndoorScore_isInverseAverageOfOtherThreeScores() {
        XCTAssertEqual(rankingService.findIndoorScore(sumOfScores: 3.0), 0.0, accuracy: 0.0001)
        XCTAssertEqual(rankingService.findIndoorScore(sumOfScores: 0.0), 1.0, accuracy: 0.0001)
        XCTAssertEqual(rankingService.findIndoorScore(sumOfScores: 1.5), 0.5, accuracy: 0.0001)
    }

    // MARK: - Zero-tie ordering (Skiing vs Surfing specifically)

    /// This test builds a minimal single-day scenario that isolates exactly that:
    /// Skiing disqualified (too warm, no snow), Surfing disqualified (no
    /// marine data at all for the date), Outdoor and Indoor both clearly
    /// nonzero so they can't interfere with the tie.
    func test_getRanking_zeroTie_surfingOutranksSkiing() {
        let forecast = ForecastAPIResponse(
            latitude: 0, longitude: 0, elevation: nil, generationtimeMs: 0,
            utcOffsetSeconds: 0, timezone: "UTC", timezoneAbbreviation: "UTC",
            daily: DailyForecast(
                time: ["2026-06-01"],
                temperature2mMax: [20], temperature2mMin: [15],
                precipitationSum: [0], precipitationProbabilityMax: nil,
                snowfallSum: nil, windspeed10mMax: [10], windgusts10mMax: nil,
                weathercode: [0], uvIndexMax: nil
            ),
            dailyUnits: DailyForecastUnits(
                time: "iso8601", temperature2mMax: "°C", temperature2mMin: "°C",
                precipitationSum: "mm", precipitationProbabilityMax: nil,
                snowfallSum: nil, windspeed10mMax: "km/h", windgusts10mMax: nil,
                weathercode: "wmo code", uvIndexMax: nil
            ),
            hourly: nil,   // no snow_depth data at all -> skiing disqualified this way too
            hourlyUnits: nil
        )

        // Empty 'time' array -> no marine data for any date -> surfing scores 0.
        let marineWithNoData = OpenMeteoMarineResponse(
            latitude: 0, longitude: 0, generationtimeMs: 0, utcOffsetSeconds: 0, timezone: "UTC",
            daily: DailyMarine(time: [], waveHeightMax: nil, wavePeriodMax: nil, swellWaveHeightMax: nil, swellWavePeriodMax: nil),
            dailyUnits: DailyMarineUnits(time: "iso8601", waveHeightMax: nil, wavePeriodMax: nil, swellWaveHeightMax: nil, swellWavePeriodMax: nil)
        )

        let result = rankingService.getRanking(forecastResponse: forecast, marineResponse: marineWithNoData)

        XCTAssertEqual(result.count, 1)
        let ranking = result[0].ranking

        XCTAssertEqual(ranking.first, "Outdoor", "Ideal outdoor conditions (20°C, no rain, calm, clear) should score highest.")
        XCTAssertEqual(ranking.last, "Skiing", "Per zeroTiePriority, Surfing should outrank Skiing when both are disqualified to 0.")

        let surfingIndex = ranking.firstIndex(of: "Surfing")!
        let skiingIndex = ranking.firstIndex(of: "Skiing")!
        XCTAssertLessThan(surfingIndex, skiingIndex, "Surfing must rank above Skiing in a zero-score tie.")
    }

    // MARK: - Helpers

    private func makeDay(
        date: String = "2026-01-01",
        temperatureMax: Double,
        temperatureMin: Double,
        precipitationSum: Double? = nil,
        snowfallSum: Double? = nil,
        windspeedMax: Double,
        windgustsMax: Double? = nil,
        weathercode: Int,
        uvIndexMax: Double? = nil,
        snowDepthCm: Double? = nil
    ) -> DayForecast {
        DayForecast(
            date: date,
            temperatureMax: temperatureMax,
            temperatureMin: temperatureMin,
            precipitationSum: precipitationSum,
            precipitationProbabilityMax: nil,
            snowfallSum: snowfallSum,
            windspeedMax: windspeedMax,
            windgustsMax: windgustsMax,
            weathercode: weathercode,
            uvIndexMax: uvIndexMax,
            snowDepthCm: snowDepthCm
        )
    }
}
