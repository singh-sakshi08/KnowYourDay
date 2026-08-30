//
//  MockLocationSearchService.swift
//  KnowYourDay
//
//  Temporary stand-in for `OpenMeteoAPI.searchLocations` while Screen 1 is
//  being built. Filters a small fixed set of well-known cities client-side
//  so the search bar has something realistic to show, including a simulated
//  network delay. Delete once the real geocoding call is wired up in
//  `DependencyContainer`.
//

import Foundation

struct MockLocationSearchService: LocationSearchingProtocol {
    private let sample: [GeocodingResult] = [
        GeocodingResult(id: 1, name: "London", latitude: 51.5074, longitude: -0.1278, elevation: 25,
                         featureCode: "PPLC", countryCode: "GB", countryId: 2_635_167, country: "United Kingdom",
                         admin1: "England", admin1Id: nil, admin2: nil, admin2Id: nil, admin3: nil, admin3Id: nil,
                         admin4: nil, admin4Id: nil, timezone: "Europe/London", population: 8_961_989, postcodes: nil),
        GeocodingResult(id: 2, name: "Chamonix-Mont-Blanc", latitude: 45.9237, longitude: 6.8694, elevation: 1035,
                         featureCode: "PPL", countryCode: "FR", countryId: 3_017_382, country: "France",
                         admin1: "Auvergne-Rhône-Alpes", admin1Id: nil, admin2: nil, admin2Id: nil, admin3: nil,
                         admin3Id: nil, admin4: nil, admin4Id: nil, timezone: "Europe/Paris", population: 8677, postcodes: nil),
        GeocodingResult(id: 3, name: "Honolulu", latitude: 21.3069, longitude: -157.8583, elevation: 8,
                         featureCode: "PPLA2", countryCode: "US", countryId: 5_856_195, country: "United States",
                         admin1: "Hawaii", admin1Id: nil, admin2: nil, admin2Id: nil, admin3: nil, admin3Id: nil,
                         admin4: nil, admin4Id: nil, timezone: "Pacific/Honolulu", population: 350_964, postcodes: nil),
        GeocodingResult(id: 4, name: "Bengaluru", latitude: 12.9716, longitude: 77.5946, elevation: 920,
                         featureCode: "PPLA", countryCode: "IN", countryId: 1_277_333, country: "India",
                         admin1: "Karnataka", admin1Id: nil, admin2: nil, admin2Id: nil, admin3: nil, admin3Id: nil,
                         admin4: nil, admin4Id: nil, timezone: "Asia/Kolkata", population: 8_443_675, postcodes: nil),
        GeocodingResult(id: 5, name: "Reykjavik", latitude: 64.1466, longitude: -21.9426, elevation: 25,
                         featureCode: "PPLC", countryCode: "IS", countryId: 2_629_691, country: "Iceland",
                         admin1: nil, admin1Id: nil, admin2: nil, admin2Id: nil, admin3: nil, admin3Id: nil,
                         admin4: nil, admin4Id: nil, timezone: "Atlantic/Reykjavik", population: 128_793, postcodes: nil)
    ]

    func search(query: String) async throws -> [GeocodingResult] {
        guard query.count >= 2 else { return [] }
        try? await Task.sleep(nanoseconds: 250_000_000) // mimic network latency
        return sample.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
