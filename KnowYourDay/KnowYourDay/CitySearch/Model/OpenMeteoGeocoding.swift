//
//  OpenMeteoGeocoding.swift
//  Codable models for the Open-Meteo Geocoding API.
//
//  Docs: https://open-meteo.com/en/docs/geocoding-api
//  Endpoint: https://geocoding-api.open-meteo.com/v1/search?name={query}&count=10&language=en&format=json
//
//  Use this to turn a user's typed city name into the latitude/longitude
//  your Forecast/Marine calls need.
//

import Foundation

/// Top-level response from `/v1/search`.
/// `results` is nil/absent entirely when there are zero matches — always
/// unwrap with `?? []` rather than assuming a non-empty array.
struct GeocodingResponse: Codable {
    let results: [GeocodingResult]?
    let generationtimeMs: Double

    enum CodingKeys: String, CodingKey {
        case results
        case generationtimeMs = "generationtime_ms"
    }
}

/// A single matched place. Per Open-Meteo's docs, "empty fields are not
/// returned" — e.g. `admin4` is absent if that location has no fourth-level
/// administrative division — so almost everything besides id/name/lat/long
/// is optional here.
struct GeocodingResult: Codable, Identifiable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let elevation: Double?

    /// GeoNames feature code, e.g. "PPLC" (capital city), "PPL" (populated place).
    let featureCode: String?

    let countryCode: String?
    let countryId: Int?
    let country: String?

    /// Administrative hierarchy, broad → narrow (state/province → county → ... ).
    /// Any level can be missing depending on how finely the country subdivides.
    let admin1: String?
    let admin1Id: Int?
    let admin2: String?
    let admin2Id: Int?
    let admin3: String?
    let admin3Id: Int?
    let admin4: String?
    let admin4Id: Int?

    let timezone: String?
    let population: Int?
    let postcodes: [String]?

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, elevation
        case featureCode = "feature_code"
        case countryCode = "country_code"
        case countryId = "country_id"
        case country
        case admin1
        case admin1Id = "admin1_id"
        case admin2
        case admin2Id = "admin2_id"
        case admin3
        case admin3Id = "admin3_id"
        case admin4
        case admin4Id = "admin4_id"
        case timezone
        case population
        case postcodes
    }

    /// Convenience for list/search UI: "Berlin, Berlin, Germany" or
    /// "New York, New York, United States", skipping empty pieces.
    var displayName: String {
        [name, admin1, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

//MARK: OpenMeteoServiceError

enum OpenMeteoServiceError: Error {
    case invalidURL
}

// MARK: - Fetching

extension OpenMeteoAPI {
    /// Searches for places by name. Returns an empty array (not an error)
    /// when there are no matches.
    static func searchLocations(
        name: String,
        count: Int = 10,
        language: String = "en"
    ) async throws -> [GeocodingResult] {
        guard name.count >= 2 else { return [] } // API requires >=2 chars

        guard var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search") else {throw OpenMeteoServiceError.invalidURL}
        components.queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "count", value: "\(count)"),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = components.url else { throw OpenMeteoServiceError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        return decoded.results ?? []
    }
}

