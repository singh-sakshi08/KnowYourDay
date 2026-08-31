//
//  CityDetailViewModel.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//
import Foundation
import Observation

@Observable
final class CityDetailViewModel {
    let city: SearchedCity
    private let rankingProvider: RankingProviding

    private(set) var rankings: [DayRanking] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(city: SearchedCity, rankingProvider: RankingProviding) {
        self.city = city
        self.rankingProvider = rankingProvider
    }

    var today: DayRanking? { rankings.first }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            rankings = try await rankingProvider.rankings(for: city)
        } catch {
            errorMessage = "Couldn't load the forecast for \(city.name). Pull to try again."
        }
        isLoading = false
    }
}

