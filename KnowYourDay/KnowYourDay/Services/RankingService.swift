//
//  RankingService.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//
import Foundation

class RankingSerivce {
    
    // Priority order for non-zero ties (Preference order: Rank 1 -> Rank 4)
    private let nonzeroTiePriority = ["Skiing", "Surfing", "Outdoor", "Indoor"]
    
    // Priority order for zero ties (Safety order: Rank 1 -> Rank 4)
    private let zeroTiePriority = ["Indoor", "Outdoor", "Skiing", "Surfing"]
    
    func getRanking(forecastResponse: ForecastAPIResponse, marineResponse: OpenMeteoMarineResponse) -> [DayRanking] {
        let days = forecastResponse.daily.asDays(hourly: forecastResponse.hourly)
        let marineDays = marineResponse.daily.asDays()
        var allRakings:  [DayRanking] = []
        
        for day in days {
            let marineDay = marineDays.first(where: { $0.date == day.date })
            let outdoorScore = findOutdoorScore(day)
            let skiingScore = findSkiingScore(day)
            let surfingScore = findSurfingScore(day, marineDay)
            let sumOfScores = outdoorScore + skiingScore + surfingScore
            let indoorScore = findIndoorScore(sumOfScores: sumOfScores)
            let activities = [ScoredActivities(name: "Indoor", score: indoorScore),
                              ScoredActivities(name: "Outdoor", score: outdoorScore),
                              ScoredActivities(name: "Surfing", score:surfingScore),
                              ScoredActivities(name: "Skiing", score: skiingScore)
                            ]
            
              let finalRanking = rankActivities(activities)
                print("""
            \(day.date)
            Outdoor: \(outdoorScore)
            Skiing: \(skiingScore)
            Surfing: \(surfingScore)
            Indoor: \(indoorScore)
            """)
            allRakings.append(DayRanking(date: day.date, ranking: finalRanking))
        }
        
        return allRakings
    }
    
    // MARK: - Sorting & Tie-Breaking
    private func rankActivities(_ activities: [ScoredActivities]) -> [String] {
        let sorted = activities.sorted { lhs, rhs in
            // Primary sort: Descending score (highest score first)
            if lhs.score != rhs.score {
                return lhs.score > rhs.score
            }
            
            // Secondary sort: Tie-break based on zero vs. nonzero score
            let priorityList = (lhs.score == 0.0) ? zeroTiePriority : nonzeroTiePriority
            let lhsIndex = priorityList.firstIndex(of: lhs.name) ?? Int.max
            let rhsIndex = priorityList.firstIndex(of: rhs.name) ?? Int.max
            
            return lhsIndex < rhsIndex // Lower index = higher priority
        }
        
        return sorted.map { $0.name }
    }
    
    //MARK: Skiing Score Calculation
    func findSkiingScore(_ day: DayForecast) -> Double {
        let tempMax = day.temperatureMax
        let tempMin = day.temperatureMin
        let wind = max(day.windspeedMax, day.windgustsMax ?? day.windspeedMax)
        let code = day.weathercode
        let snowfall = day.snowfallSum ?? 0.0
        let snowDepth = day.snowDepthCm // cm; nil = no hourly snow_depth data for this day/location

        // Hard disqualifiers — any one zeroes the whole day
        if tempMax > 5 || tempMin < -20 ||
           wind > 60 ||
           [95, 96, 99].contains(code) ||
            (snowDepth.map { $0 < 1.0 } ?? true) { // < 0.01 m — "effectively no snow on the ground"
            return 0.0
        }

        var sum = 0.0

        // Temperature
        if tempMax >= -10 && tempMax <= -1 {
            sum += 1.0
        } else if (tempMax > -1 && tempMax <= 2) || (tempMax < -10 && tempMax >= -20) {
            sum += 0.75
        } else {
            sum += 0.25 // 2 < tempMax <= 5
        }

        // Wind
        if wind < 20 {
            sum += 1.0
        } else if wind <= 40 {
            sum += 0.75
        } else {
            sum += 0.25 // 40 < wind <= 60
        }

        // Weathercode — explicit sets, not a numeric cutoff
        if [0, 1, 2].contains(code) {
            sum += 1.0
        } else if [3, 71].contains(code) {
            sum += 0.75
        } else {
            sum += 0.25 // 73, 75, 77, 85, 86, or any unlisted code
        }

        // New snowfall — 2 tiers only, no standalone Poor
        if snowfall >= 5.0 {
            sum += 1.0
        } else {
            sum += 0.75 // 0–4.99 cm — relies on existing base (see snow_depth below)
        }

        // Existing snow on ground — disqualifier already ran above;
        // these bands only apply once we know it's >= 1cm
        if let snowDepth {
            if snowDepth >= 30.0 {
                sum += 1.0
            } else if snowDepth >= 10.0 {
                sum += 0.75
            } else {
                sum += 0.25 // 1–9.99 cm — barely any base
            }
        } else {
            sum += 0 // no snow_depth data for this day/location — neutral, not penalized
        }

        let weightedAverage = sum / 5
        return weightedAverage
    }
    
    //MARK: Surfing Score Calculation
    func findSurfingScore(_ day: DayForecast, _ marine: DayMarine?) -> Double {
        guard let marine,
                  let waveHeight = marine.waveHeightMax ?? marine.swellWaveHeightMax,
                  let wavePeriod = marine.wavePeriodMax ?? marine.swellWavePeriodMax else {
                return 0.0 // no marine data for this day/location
            }

        let wind = max(day.windspeedMax, day.windgustsMax ?? day.windspeedMax)

            if waveHeight < 0.3 || waveHeight > 4.0 || wind > 50 {
                return 0.0
            }

            var sum = 0.0

            if waveHeight >= 1.0 && waveHeight <= 2.0 {
                sum += 1.0
            } else if (waveHeight >= 0.5 && waveHeight < 1.0) || (waveHeight > 2.0 && waveHeight <= 3.0) {
                sum += 0.75
            } else {
                sum += 0.25
            }

            if wavePeriod > 10 {
                sum += 1.0
            } else if wavePeriod >= 6 {
                sum += 0.75
            } else {
                sum += 0.25
            }

            if wind < 15 {
                sum += 1.0
            } else if wind <= 30 {
                sum += 0.75
            } else {
                sum += 0.25
            }

            let weightedAverage = sum / 3
            return weightedAverage
    }
    
    //MARK: Outdoor Score Calculation
    func findOutdoorScore(_ day: DayForecast) -> Double {
        let tempMax = day.temperatureMax
        let tempMin = day.temperatureMin
        let wind = max(day.windspeedMax, day.windgustsMax ?? day.windspeedMax)
        let code = day.weathercode
        let precip = day.precipitationSum ?? 0.0

        // Hard disqualifiers
        if precip > 10.0 ||
           [95, 96, 99].contains(code) ||
           tempMax > 38 || tempMin < 0 ||
           wind > 50 {
            return 0.0
        }

        var sum = 0.0

        if precip <= 0.5 {
            sum += 1.0
        } else if precip <= 2.0 {
            sum += 0.75
        } else {
            sum += 0.25 // 2–10 mm
        }

        if tempMax >= 15 && tempMax <= 27 {
            sum += 1.0
        } else if (tempMax >= 8 && tempMax < 15) || (tempMax > 27 && tempMax <= 32) {
            sum += 0.75
        } else {
            sum += 0.25 // 0–8 or 32–38
        }

        if wind < 20 {
            sum += 1.0
        } else if wind <= 35 {
            sum += 0.75
        } else {
            sum += 0.25 // 35–50
        }

        if [0, 1, 2].contains(code) {
            sum += 1.0
        } else if [3, 45, 48, 51, 53].contains(code) {
            sum += 0.75
        } else {
            sum += 0.25 // 55–67, 80–82, or unlisted code
        }

        let weightedAverage = sum / 4
        return weightedAverage
    }
    
    //MARK: Indoor Score Calculation
    func findIndoorScore(sumOfScores: Double) -> Double {
        return 1 - (sumOfScores/3)
    }
}





struct ScoredActivities {
    var name: String
    var score: Double
}

//extension ScoredActivities: Comparable {
//    /// Tie-break priority for the three weather-driven activities. There isn't
//    /// one fixed order — it flips depending on whether the tied score is 0
//    /// (a fully disqualified day, where the safe/generic option edges out the
//    /// specialized sports) or non-zero (where the specialized sports are
//    /// prioritized over generic outdoor sightseeing). Listed worst → best,
//    /// matching how `<` is used below.
//    private static func weatherPriority(name: String, score: Double) -> Int? {
//        let order = score == 0.0
//            ? ["Outdoor","Surfing", "Skiing" ]   // disqualified day: Outdoor edges out both sports
//            : ["Surfing", "Skiing", "Outdoor"]   // usable day: Surfing edges out Skiing edges out Outdoor
//        return order.firstIndex(of: name)
//    }
//
//    static func < (lhs: ScoredActivities, rhs: ScoredActivities) -> Bool {
//        if lhs.score == rhs.score {
//            if let l = weatherPriority(name: lhs.name, score: lhs.score),
//               let r = weatherPriority(name: rhs.name, score: rhs.score) {
//                return l < r
//            }
//            // Indoor, or any name that lands here by coincidence — same
//            // alphabetical fallback the original code already had.
//            return lhs.name < rhs.name
//        }
//        return lhs.score < rhs.score
//    }
//}

enum SuitabilityTier: Double {
    case disqualifying = 0.0
    case poor = 0.25
    case marginal = 0.75
    case ideal = 1.0
}

struct DayRanking {
    let date: String
    let ranking: [String]
}
