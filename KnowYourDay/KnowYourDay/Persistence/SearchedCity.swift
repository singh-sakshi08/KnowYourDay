//
//  SearchedCity.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import Foundation
import SwiftData

@Model
final class SearchedCity {
    @Attribute(.unique) var id: Int
    var name: String
    var admin1: String?
    var country: String?
    var latitude: Double
    var longitude: Double
    var lastSearchedAt: Date

    init(
        id: Int,
        name: String,
        admin1: String?,
        country: String?,
        latitude: Double,
        longitude: Double,
        lastSearchedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.admin1 = admin1
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.lastSearchedAt = lastSearchedAt
    }

    var displayName: String {
        [name, admin1, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

extension SearchedCity {
    convenience init(geocodingResult result: GeocodingResult, lastSearchedAt: Date = .now) {
        self.init(
            id: result.id,
            name: result.name,
            admin1: result.admin1,
            country: result.country,
            latitude: result.latitude,
            longitude: result.longitude,
            lastSearchedAt: lastSearchedAt
        )
    }
}
