import Foundation

/// Expanded 12-day fixture for testing RankingService.
/// Covers hard disqualifiers, score boundaries, missing snow depth,
/// snow-depth tiers, surfing limits, and mixed ranking scenarios.
///
/// Expected ranking is documented above each day in the table below.
///
/// | Date       | Skiing | Surfing | Outdoor | Indoor | Expected Ranking |
/// |------------|--------|---------|---------|--------|------------------|
/// | 2026-10-01 | 0.0000 | 0.9167  | 1.0000  | 0.3611 | Outdoor > Surfing > Indoor > Skiing |
/// | 2026-10-02 | 0.0000 | 0.8333  | 0.8750  | 0.4306 | Outdoor > Surfing > Indoor > Skiing |
/// | 2026-10-03 | 0.0000 | 0.9167  | 0.0000  | 0.6944 | Surfing > Indoor > Outdoor > Skiing |
/// | 2026-10-04 | 0.7500 | 0.0000  | 0.0000  | 0.7500 | Skiing > Indoor > Outdoor > Surfing |
/// | 2026-10-05 | 0.0000 | 0.8333  | 0.0000  | 0.7222 | Surfing > Indoor > Outdoor > Skiing |
/// | 2026-10-06 | 0.0000 | 1.0000  | 0.0000  | 0.6667 | Surfing > Indoor > Outdoor > Skiing |
/// | 2026-10-07 | 0.9000 | 0.0000  | 0.0000  | 0.7000 | Skiing > Indoor > Outdoor > Surfing |
/// | 2026-10-08 | 0.8500 | 0.0000  | 0.0000  | 0.7167 | Skiing > Indoor > Outdoor > Surfing |
/// | 2026-10-09 | 0.7000 | 0.7500  | 0.0000  | 0.5167 | Surfing > Skiing > Indoor > Outdoor |
/// | 2026-10-10 | 0.0000 | 0.8333  | 0.8125  | 0.4514 | Surfing > Outdoor > Indoor > Skiing |
/// | 2026-10-11 | 0.8000 | 0.6667  | 0.0000  | 0.5111 | Skiing > Surfing > Indoor > Outdoor |
/// | 2026-10-12 | 0.6500 | 0.0000  | 0.0000  | 0.7833 | Indoor > Skiing > Outdoor > Surfing |

enum ExpandedRankingFixture {

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
                "2026-10-01", "2026-10-02", "2026-10-03", "2026-10-04",
                "2026-10-05", "2026-10-06", "2026-10-07", "2026-10-08",
                "2026-10-09", "2026-10-10", "2026-10-11", "2026-10-12"
            ],

            // 01: ideal outdoor
            // 02: skiing too warm (> 5)
            // 03: skiing too cold (< -20)
            // 04: skiing wind > 60 via gust
            // 05: severe weather code 96
            // 06: valid ski weather but missing snow depth
            // 07: 20 cm snow depth; surfing wave < 0.3
            // 08: 40 cm snow depth; surfing wave > 4
            // 09: 5 cm snow depth; surfing period < 6
            // 10: strong outdoor + surfing combination
            // 11: exact 1 cm snow-depth boundary; wave exactly 0.3; period exactly 6
            // 12: several exact upper boundaries: tempMax 5, tempMin -20,
            //     wind 60, precipitation 10, wave 4.0, snow depth 30 cm

            temperature2mMax: [
                22.0, 8.0, -22.0, -2.0,
                -3.0, -4.0, -1.0, 2.0,
                0.0, 28.0, -1.0, 5.0
            ],

            temperature2mMin: [
                15.0, 2.0, -25.0, -8.0,
                -9.0, -10.0, -6.0, -3.0,
                -4.0, 20.0, -6.0, -20.0
            ],

            precipitationSum: [
                0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 10.0
            ],

            precipitationProbabilityMax: nil,

            snowfallSum: [
                0.0, 0.0, 0.0, 2.0,
                4.0, 0.0, 5.0, 0.0,
                0.0, 0.0, 0.0, 5.0
            ],

            windspeed10mMax: [
                10.0, 15.0, 10.0, 45.0,
                10.0, 10.0, 10.0, 10.0,
                10.0, 18.0, 10.0, 60.0
            ],

            windgusts10mMax: [
                12.0, 18.0, 12.0, 55.0,
                15.0, 12.0, 12.0, 12.0,
                12.0, 25.0, 12.0, 60.0
            ],

            weathercode: [
                1, 3, 0, 0,
                96, 0, 3, 71,
                3, 2, 0, 71
            ],

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
            time: [
                "2026-10-01T12:00", "2026-10-02T12:00", "2026-10-03T12:00",
                "2026-10-04T12:00", "2026-10-05T12:00", "2026-10-06T12:00",
                "2026-10-07T12:00", "2026-10-08T12:00", "2026-10-09T12:00",
                "2026-10-10T12:00", "2026-10-11T12:00", "2026-10-12T12:00"
            ],

            // Meters. dailySnowDepthsCm() converts these to centimeters.
            //
            // 0.00 m = no snow
            // 0.30 m = 30 cm
            // 0.40 m = 40 cm
            // 0.25 m = 25 cm
            // 0.35 m = 35 cm
            // 0.00 m = no snow
            // 0.20 m = 20 cm
            // 0.40 m = 40 cm
            // 0.05 m = 5 cm
            // 0.00 m = no snow
            // 0.01 m = exactly 1 cm
            // 0.30 m = exactly 30 cm

            snowDepth: [
                0.00, 0.30, 0.40, 0.25,
                0.35, 0.00, 0.20, 0.40,
                0.05, 0.00, 0.01, 0.30
            ]
        ),

        hourlyUnits: HourlyForecastUnits(
            time: "iso8601",
            snowDepth: "m"
        )
    )

    /// Separate response specifically testing the `snowDepth == nil` path.
    /// Because HourlyForecast.snowDepth is `[Double]?`, this represents a response
    /// where hourly snow-depth data was not requested/returned at all.
    static let forecastWithoutHourlySnowDepth = ForecastAPIResponse(
        latitude: forecast.latitude,
        longitude: forecast.longitude,
        elevation: forecast.elevation,
        generationtimeMs: forecast.generationtimeMs,
        utcOffsetSeconds: forecast.utcOffsetSeconds,
        timezone: forecast.timezone,
        timezoneAbbreviation: forecast.timezoneAbbreviation,
        daily: forecast.daily,
        dailyUnits: forecast.dailyUnits,
        hourly: nil,
        hourlyUnits: nil
    )

    static let marine = OpenMeteoMarineResponse(
        latitude: 46.02,
        longitude: 7.75,
        generationtimeMs: 0.12,
        utcOffsetSeconds: 7200,
        timezone: "Europe/Zurich",

        daily: DailyMarine(
            time: [
                "2026-10-01", "2026-10-02", "2026-10-03", "2026-10-04",
                "2026-10-05", "2026-10-06", "2026-10-07", "2026-10-08",
                "2026-10-09", "2026-10-10", "2026-10-11", "2026-10-12"
            ],

            waveHeightMax: [
                1.5, 1.2, 1.2, 1.5,
                1.5, 1.5, 0.2, 4.5,
                1.8, 2.0, 0.3, 4.0
            ],

            wavePeriodMax: [
                10.0, 8.0, 9.0, 9.0,
                10.0, 11.0, 8.0, 11.0,
                5.5, 10.0, 6.0, 10.0
            ],

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

struct ExpandedRankingProvider: RankingProviding {

    func rankings(for city: SearchedCity) async throws -> [DayRanking] {
        RankingSerivce().getRanking(
            forecastResponse: ExpandedRankingFixture.forecast,
            marineResponse: ExpandedRankingFixture.marine
        )
    }
}


/*
 Usage:

 let ranking = RankingSerivce().getRanking(
     forecastResponse: ExpandedRankingFixture.forecast,
     marineResponse: ExpandedRankingFixture.marine
 )

 print(ranking)

 Important:
 Your RankingService must pass hourly into asDays():

 let days = forecastResponse.daily.asDays(
     hourly: forecastResponse.hourly
 )
*/
