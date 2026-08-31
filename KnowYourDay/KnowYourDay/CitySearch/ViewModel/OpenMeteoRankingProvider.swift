//
//  OpenMeteoRankingProvider.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import Foundation

struct OpenMeteoRankingProvider: RankingProviding {
    func rankings(for city: SearchedCity) async throws -> [DayRanking] {
        async let forecastTask = try OpenMeteoAPI.fetchForecast(latitude: city.latitude, longitude: city.longitude)
        async let marineTask: OpenMeteoMarineResponse? = try? OpenMeteoAPI.fetchMarine(latitude: city.latitude, longitude: city.longitude)

        let forecastResponse = try await forecastTask
        let marineResponse = await marineTask

        return RankingSerivce().getRanking(
            forecastResponse: forecastResponse,
            marineResponse: marineResponse ?? Self.emptyMarine(latitude: city.latitude, longitude: city.longitude)
        )
    }

    private static func emptyMarine(latitude: Double, longitude: Double) -> OpenMeteoMarineResponse {
        OpenMeteoMarineResponse(
            latitude: latitude,
            longitude: longitude,
            generationtimeMs: 0,
            utcOffsetSeconds: 0,
            timezone: "UTC",
            daily: DailyMarine(time: [], waveHeightMax: nil, wavePeriodMax: nil, swellWaveHeightMax: nil, swellWavePeriodMax: nil),
            dailyUnits: DailyMarineUnits(time: "iso8601", waveHeightMax: nil, wavePeriodMax: nil, swellWaveHeightMax: nil, swellWavePeriodMax: nil)
        )
    }
}
