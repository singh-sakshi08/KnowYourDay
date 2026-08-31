import Foundation

/// A full 7-day week, built the same Decodable-free way as
/// SimpleResponseFixture — plain struct literals, no JSON, no JSONDecoder.
/// Pass straight into RankingService.getRanking(forecastResponse:marineResponse:)
/// to validate the whole per-day loop against real, varied conditions —
/// including hard stops, nonzero ties, and zero ties, deliberately spread
/// across the week so no single day exercises everything at once.
///
/// Every expected score below was cross-checked against a standalone
/// reimplementation of the finalized scoring rules (not read off by hand),
/// so treat these as your ground truth for what getRanking() should return.
///
/// | Date       | Skiing | Surfing | Outdoor | Indoor | Ranking (rank 1 → 4)                  |
/// |------------|--------|---------|---------|--------|----------------------------------------|
/// | 2026-08-30 | 0.0    | 0.9167  | 1.0     | 0.3611 | Outdoor, Surfing, Indoor, Skiing        |
/// | 2026-08-31 | 0.0    | 0.75    | 0.5625  | 0.5625 | Surfing, Outdoor, Indoor, Skiing (tie*) |
/// | 2026-09-01 | 0.0    | 0.0     | 0.0     | 1.0    | Indoor, Outdoor, Skiing, Surfing (tie†) |
/// | 2026-09-02 | 0.95   | 0.9167  | 0.0     | 0.3778 | Skiing, Surfing, Indoor, Outdoor        |
/// | 2026-09-03 | 0.0    | 0.75    | 0.0     | 0.75   | Surfing, Indoor, Outdoor, Skiing (tie*,†)|
/// | 2026-09-04 | 0.95   | 0.8333  | 0.0     | 0.4056 | Skiing, Surfing, Indoor, Outdoor        |
/// | 2026-09-05 | 0.0    | 0.6667  | 0.6875  | 0.5486 | Outdoor, Surfing, Indoor, Skiing        |
///
/// (*) nonzero tie broken via the Skiing>Surfing>Outdoor>Indoor chain.
/// (†) zero tie broken via the Indoor>Outdoor>Skiing>Surfing chain.
/// 09-01 and 09-05 look similar (Outdoor/Skiing/Surfing structurally
/// disqualified) but for different combinations of reasons — worth stepping
/// through both if a test on one passes and the other doesn't.
enum SevenDayResponseFixture {

    static let forecast = ForecastAPIResponse(
        latitude: 46.02,
        longitude: 7.75,
        elevation: 1608.0,
        generationtimeMs: 0.18,
        utcOffsetSeconds: 7200,
        timezone: "Europe/Zurich",
        timezoneAbbreviation: "CEST",
        daily: DailyForecast(
            time: [
                "2026-08-30", "2026-08-31", "2026-09-01", "2026-09-02",
                "2026-09-03", "2026-09-04", "2026-09-05"
            ],
            temperature2mMax: [24.0, 17.0, 19.0, -4.0, 41.0, -2.0, 16.0],
            temperature2mMin: [18.0, 12.0, 15.0, -9.0, 28.0, -6.0, 10.0],
            precipitationSum: [0.0, 3.5, 22.0, 0.0, 0.0, 2.0, 1.0],
            precipitationProbabilityMax: nil,
            snowfallSum: [0.0, 0.0, 0.0, 0.0, 0.0, 10.0, 0.0],
            windspeed10mMax: [12.0, 18.0, 30.0, 14.0, 14.0, 9.0, 30.0],
            windgusts10mMax: [15.0, 26.0, 65.0, 18.0, 17.0, 11.0, 45.0],
            weathercode: [1, 61, 95, 0, 0, 71, 3],
            uvIndexMax: nil
        ),
        dailyUnits: DailyForecastUnits(
            time: "iso8601",
            temperature2mMax: "°C",
            temperature2mMin: "°C",
            precipitationSum: "mm",
            precipitationProbabilityMax: nil,
            snowfallSum: "cm",
            windspeed10mMax: "km/h",
            windgusts10mMax: "km/h",
            weathercode: "wmo code",
            uvIndexMax: nil
        ),
        hourly: HourlyForecast(
            // One noon reading per day — enough for dailySnowDepthsCm(atHour: 12)
            // to reduce correctly. Real responses return 168 hourly entries;
            // trimmed here since only the noon value is ever read.
            time: [
                "2026-08-30T12:00", "2026-08-31T12:00", "2026-09-01T12:00",
                "2026-09-02T12:00", "2026-09-03T12:00", "2026-09-04T12:00",
                "2026-09-05T12:00"
            ],
            snowDepth: [0.0, 0.0, 0.0, 0.35, 0.0, 0.48, 0.0] // meters
        ),
        hourlyUnits: HourlyForecastUnits(
            time: "iso8601",
            snowDepth: "m"
        )
    )

    static let marine = OpenMeteoMarineResponse(
        latitude: 46.02,
        longitude: 7.75,
        generationtimeMs: 0.12,
        utcOffsetSeconds: 7200,
        timezone: "Europe/Zurich",
        daily: DailyMarine(
            time: [
                "2026-08-30", "2026-08-31", "2026-09-01", "2026-09-02",
                "2026-09-03", "2026-09-04", "2026-09-05"
            ],
            waveHeightMax: [1.2, 0.8, 3.6, 1.9, 0.9, 2.2, 1.6],
            wavePeriodMax: [11.0, 7.5, 9.0, 10.5, 8.0, 8.0, 6.5],
            swellWaveHeightMax: nil,
            swellWavePeriodMax: nil
        ),
        dailyUnits: DailyMarineUnits(
            time: "iso8601",
            waveHeightMax: "m",
            wavePeriodMax: "s",
            swellWaveHeightMax: nil,
            swellWavePeriodMax: nil
        )
    )
}

// Usage:
// let ranking = RankingSerivce().getRanking(
//     forecastResponse: SevenDayResponseFixture.forecast,
//     marineResponse: SevenDayResponseFixture.marine
// )
// ranking.count == 7
// ranking[2].ranking == ["Indoor", "Outdoor", "Skiing", "Surfing"] // 2026-09-01
