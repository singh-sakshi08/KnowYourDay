//
//  RankingProviding.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import Foundation

protocol RankingProviding {
    func rankings(for city: SearchedCity) async throws -> [DayRanking]
}
