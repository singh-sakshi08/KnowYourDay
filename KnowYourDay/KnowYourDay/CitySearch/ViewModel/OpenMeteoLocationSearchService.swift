//
//  OpenMeteoLocationSearchService.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import Foundation

struct OpenMeteoLocationSearchService: LocationSearchingProtocol {
    func search(query: String) async throws -> [GeocodingResult] {
        try await OpenMeteoAPI.searchLocations(name: query)
    }
}
