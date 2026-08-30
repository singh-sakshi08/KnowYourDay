//
//  MockRankingProvider.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import Foundation

struct MockRankingProvider: RankingProviding {
    private let sampleOrderings: [[String]] = [
        ["Skiing", "Outdoor", "Surfing", "Indoor"],
        ["Surfing", "Skiing", "Outdoor", "Indoor"],
        ["Outdoor", "Surfing", "Skiing", "Indoor"],
        ["Indoor", "Outdoor", "Skiing", "Surfing"],
        ["Skiing", "Surfing", "Indoor", "Outdoor"],
        ["Surfing", "Outdoor", "Indoor", "Skiing"],
        ["Outdoor", "Indoor", "Surfing", "Skiing"]
    ]

    func rankings(for city: SearchedCity) async throws -> [DayRanking] {
        try? await Task.sleep(nanoseconds: 400_000_000) // mimic network latency

        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: .now) ?? .now
            return DayRanking(date: formatter.string(from: date), ranking: sampleOrderings[offset])
        }
    }
}
