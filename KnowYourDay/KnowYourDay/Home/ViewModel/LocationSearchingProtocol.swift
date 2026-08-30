//
//  LocationSearchingProtocol.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import Foundation

protocol LocationSearchingProtocol {
    func search(query: String) async throws -> [GeocodingResult]
}

protocol CityHistoryRepository {
    @discardableResult
    func recordSearch(_ result: GeocodingResult) throws -> SearchedCity
}

