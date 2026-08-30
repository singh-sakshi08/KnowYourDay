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
        locationSearchService: LocationSearchingProtocol = MockLocationSearchService(),
        rankingProvider: RankingProviding = ExpandedRankingProvider()
    ) {
        self.locationSearchService = locationSearchService
        self.rankingProvider = rankingProvider
    }
}
