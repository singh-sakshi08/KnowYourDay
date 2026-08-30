//
//  SwiftDataCityHistoryRepository.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import Foundation
import SwiftData

struct SwiftDataCityHistoryRepository: CityHistoryRepository {
    let modelContext: ModelContext

    @discardableResult
    func recordSearch(_ result: GeocodingResult) throws -> SearchedCity {
        let resultId = result.id
        var descriptor = FetchDescriptor<SearchedCity>(
            predicate: #Predicate { $0.id == resultId }
        )
        descriptor.fetchLimit = 1

        if let existing = try modelContext.fetch(descriptor).first {
            existing.lastSearchedAt = .now
            try modelContext.save()
            return existing
        }

        let city = SearchedCity(geocodingResult: result)
        modelContext.insert(city)
        try modelContext.save()
        return city
    }
}
