import Foundation

/// ONE fully-constructed example — plain Swift struct literals, no JSON,
/// no JSONDecoder involved. Pass straight into
/// RankingService.getRanking(forecastResponse:marineResponse:).
///
/// Same scenario as BusinessLogicFixtures.perfectSkiDay /
/// BusinessLogicFixturesJSON.perfectSkiDayForecast, so all three approaches
/// (direct DayForecast, JSON, this one) should agree.
///
/// Expected: Skiing = 1.0 (all 5 params ideal), Surfing = 0.0 (wave height
/// 0.15m < 0.3m, disqualifying), Outdoor = 0.0 (tempMax -5°C < 0°C,
/// disqualifying), Indoor = 1 - (0 + 1.0 + 0)/3 = 0.6667.
/// Ranking: Skiing, Indoor, then {Surfing, Outdoor} — still-open partial
/// zero-tie question from earlier applies here too.
enum SimpleResponseFixture {

    static let forecast = ForecastAPIResponse(
        latitude: 46.02,
        longitude: 7.75,
        elevation: 1608.0,
        generationtimeMs: 0.15,
        utcOffsetSeconds: 7200,
        timezone: "Europe/Zurich",
        timezoneAbbreviation: "CEST",
        daily: DailyForecast(
            time: ["2026-08-30"],
            temperature2mMax: [-5.0],
            temperature2mMin: [-9.0],
            precipitationSum: [0.0],
            precipitationProbabilityMax: nil,
            snowfallSum: [7.0],
            windspeed10mMax: [12.0],
            windgusts10mMax: [15.0],
            weathercode: [1],
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
            time: ["2026-08-30T06:00", "2026-08-30T12:00", "2026-08-30T18:00"],
            snowDepth: [0.54, 0.55, 0.55] // meters — reduces to 55.0cm at noon
        ),
        hourlyUnits: HourlyForecastUnits(
            time: "iso8601",
            snowDepth: "m"
        )
    )

    static let marine = OpenMeteoMarineResponse(
        latitude: 46.02,
        longitude: 7.75,
        generationtimeMs: 0.1,
        utcOffsetSeconds: 7200,
        timezone: "Europe/Zurich",
        daily: DailyMarine(
            time: ["2026-08-30"],
            waveHeightMax: [0.15],
            wavePeriodMax: [5.0],
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
//     forecastResponse: SimpleResponseFixture.forecast,
//     marineResponse: SimpleResponseFixture.marine
// )
// ranking[0].date == "2026-08-30"
