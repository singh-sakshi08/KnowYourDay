//
//  ForecastAPIResponse.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import Foundation
import UIKit
// MARK: - Forecast API

struct ForecastAPIResponse: Codable {
    let latitude: Double
    let longitude: Double
    let elevation: Double?
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String

    let daily: DailyForecast
    let dailyUnits: DailyForecastUnits

    /// Present only if `&hourly=` was included in the request (e.g. `&hourly=snow_depth`).
    let hourly: HourlyForecast?
    let hourlyUnits: HourlyForecastUnits?

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, elevation
        case generationtimeMs = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case daily
        case dailyUnits = "daily_units"
        case hourly
        case hourlyUnits = "hourly_units"
    }
}

struct DailyForecast: Codable {
    let time: [String]

    let temperature2mMax: [Double]
    let temperature2mMin: [Double]

    let precipitationSum: [Double]?
    let precipitationProbabilityMax: [Double]?

    let snowfallSum: [Double]?

    let windspeed10mMax: [Double]
    let windgusts10mMax: [Double]?

    let weathercode: [Int]

    let uvIndexMax: [Double]?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationSum = "precipitation_sum"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case snowfallSum = "snowfall_sum"
        case windspeed10mMax = "windspeed_10m_max"
        case windgusts10mMax = "windgusts_10m_max"
        case weathercode
        case uvIndexMax = "uv_index_max"
    }
}

/// Units for each field in `DailyForecast`, e.g. "°C", "km/h", "mm", "cm".
/// Useful for labeling UI without hardcoding unit strings.
struct DailyForecastUnits: Codable {
    let time: String
    let temperature2mMax: String
    let temperature2mMin: String
    let precipitationSum: String?
    let precipitationProbabilityMax: String?
    let snowfallSum: String?
    let windspeed10mMax: String
    let windgusts10mMax: String?
    let weathercode: String
    let uvIndexMax: String?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationSum = "precipitation_sum"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case snowfallSum = "snowfall_sum"
        case windspeed10mMax = "windspeed_10m_max"
        case windgusts10mMax = "windgusts_10m_max"
        case weathercode
        case uvIndexMax = "uv_index_max"
    }
}

/// Hourly data. Only holds the field(s) actually requested via `&hourly=`.
/// snow_depth is the field the Skiing disqualifier needs — it isn't available
/// as a daily aggregate, only hourly, and Open-Meteo returns it in **meters**.
struct HourlyForecast: Codable {
    let time: [String]
    let snowDepth: [Double]?

    enum CodingKeys: String, CodingKey {
        case time
        case snowDepth = "snow_depth"
    }
}

struct HourlyForecastUnits: Codable {
    let time: String
    let snowDepth: String?

    enum CodingKeys: String, CodingKey {
        case time
        case snowDepth = "snow_depth"
    }
}

// MARK: - Marine API

struct OpenMeteoMarineResponse: Codable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String

    let daily: DailyMarine
    let dailyUnits: DailyMarineUnits

    enum CodingKeys: String, CodingKey {
        case latitude, longitude
        case generationtimeMs = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case daily
        case dailyUnits = "daily_units"
    }
}

/// Wave fields used for the surfing score.
struct DailyMarine: Codable {
    let time: [String]

    let waveHeightMax: [Double]?
    let wavePeriodMax: [Double]?

    // Optional higher-precision alternatives mentioned in the reference sheet.
    let swellWaveHeightMax: [Double]?
    let swellWavePeriodMax: [Double]?

    enum CodingKeys: String, CodingKey {
        case time
        case waveHeightMax = "wave_height_max"
        case wavePeriodMax = "wave_period_max"
        case swellWaveHeightMax = "swell_wave_height_max"
        case swellWavePeriodMax = "swell_wave_period_max"
    }
}

struct DailyMarineUnits: Codable {
    let time: String
    let waveHeightMax: String?
    let wavePeriodMax: String?
    let swellWaveHeightMax: String?
    let swellWavePeriodMax: String?

    enum CodingKeys: String, CodingKey {
        case time
        case waveHeightMax = "wave_height_max"
        case wavePeriodMax = "wave_period_max"
        case swellWaveHeightMax = "swell_wave_height_max"
        case swellWavePeriodMax = "swell_wave_period_max"
    }
}

// MARK: - Per-day convenience models

/// A single day of forecast data, zipped from the parallel `DailyForecast` arrays.
/// Build these once after decoding so your scoring layer works with one struct
/// per day instead of juggling indices into arrays.
struct DayForecast: Identifiable {
    var id: String { date }

    let date: String
    let temperatureMax: Double
    let temperatureMin: Double
    let precipitationSum: Double?
    let precipitationProbabilityMax: Double?
    let snowfallSum: Double?
    let windspeedMax: Double
    let windgustsMax: Double?
    let weathercode: Int
    let uvIndexMax: Double?
    let snowDepthCm: Double?
}

extension DailyForecast {
    /// Converts the parallel arrays into one `DayForecast` per index.
    /// Pass the same-request HourlyForecast (if snow_depth was requested) to
    /// join its per-day snow depth into each DayForecast.
    func asDays(hourly: HourlyForecast? = nil) -> [DayForecast] {
        let snowDepthByDate =  hourly?.dailySnowDepthsCm()  ?? [:]
        return time.indices.map { i in
            let date = time[i]
            return DayForecast(
                date: date,
                temperatureMax: temperature2mMax[safe: i] ?? .nan,
                temperatureMin: temperature2mMin[safe: i] ?? .nan,
                precipitationSum: precipitationSum?[safe: i],
                precipitationProbabilityMax: precipitationProbabilityMax?[safe: i],
                snowfallSum: snowfallSum?[safe: i],
                windspeedMax: windspeed10mMax[safe: i] ?? .nan,
                windgustsMax: windgusts10mMax?[safe: i],
                weathercode: weathercode[safe: i] ?? -1,
                uvIndexMax: uvIndexMax?[safe: i],
                snowDepthCm: snowDepthByDate[date]
            )
        }
    }
}

extension HourlyForecast {
    /// Reduces the hourly snow_depth array to one value per calendar day, sampled
    /// at a fixed local hour (noon) — a single hourly reading has to stand in for
    /// "the day" somehow, and noon avoids the depth reading right at a midnight
    /// boundary. Keyed by date string ("yyyy-MM-dd") so it can be joined against
    /// DailyForecast.time. Converts meters → centimeters.
    func dailySnowDepthsCm(atHour hour: Int = 12) -> [String: Double] {
        guard let snowDepth else { return [:] }
        var result: [String: Double] = [:]
        for (index, timestamp) in time.enumerated() {
            guard let tIndex = timestamp.firstIndex(of: "T"),
                  Int(timestamp[timestamp.index(after: tIndex)...].prefix(2)) == hour,
                  let depth = snowDepth[safe: index] else { continue }
            result[String(timestamp[timestamp.startIndex..<tIndex])] = depth * 100
        }
        return result
    }
}

/// A single day of marine data, zipped from `DailyMarine`.
struct DayMarine: Identifiable {
    var id: String { date }

    let date: String
    let waveHeightMax: Double?
    let wavePeriodMax: Double?
    let swellWaveHeightMax: Double?
    let swellWavePeriodMax: Double?
}

extension DailyMarine {
    func asDays() -> [DayMarine] {
        time.indices.map { i in
            DayMarine(
                date: time[i],
                waveHeightMax: waveHeightMax?[safe: i],
                wavePeriodMax: wavePeriodMax?[safe: i],
                swellWaveHeightMax: swellWaveHeightMax?[safe: i],
                swellWavePeriodMax: swellWavePeriodMax?[safe: i]
            )
        }
    }
}

private extension Array {
    /// Safe indexing so a shorter-than-expected array (API omitted a field for
    /// some days) doesn't crash the zip — returns nil instead.
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

    
