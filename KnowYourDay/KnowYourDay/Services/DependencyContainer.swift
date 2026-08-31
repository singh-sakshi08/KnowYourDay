//
//  DependencyContainer.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import Foundation

struct DependencyContainer {
    let locationSearchService: LocationSearchingProtocol
    let rankingProvider: RankingProviding

    init(
        locationSearchService: LocationSearchingProtocol = OpenMeteoLocationSearchService(),
        rankingProvider: RankingProviding = OpenMeteoRankingProvider()
    ) {
        self.locationSearchService = locationSearchService
        self.rankingProvider = rankingProvider
    }
}
