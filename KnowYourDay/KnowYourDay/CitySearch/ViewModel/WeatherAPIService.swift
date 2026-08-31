//
//  ForecastAPIService.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//
import Foundation

enum OpenMeteoAPI {
    static func fetchForecast(latitude: Double, longitude: Double) async throws -> ForecastAPIResponse {
        guard var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast") else {throw OpenMeteoServiceError.invalidURL}
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "daily", value: [
                "temperature_2m_max", "temperature_2m_min",
                "precipitation_sum", "precipitation_probability_max",
                "snowfall_sum", "windspeed_10m_max", "windgusts_10m_max",
                "weathercode", "uv_index_max"
            ].joined(separator: ",")),
            URLQueryItem(name: "hourly", value: "snow_depth"),
            URLQueryItem(name: "forecast_days", value: "7"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "windspeed_unit", value: "kmh"),
            URLQueryItem(name: "precipitation_unit", value: "mm")
        ]
        
        guard let url = components.url else { throw OpenMeteoServiceError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ForecastAPIResponse.self, from: data)
    }
    
    
    static func fetchMarine(latitude: Double, longitude: Double) async throws -> OpenMeteoMarineResponse {
        guard var components = URLComponents(string: "https://marine-api.open-meteo.com/v1/marine") else {throw OpenMeteoServiceError.invalidURL}
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "daily", value: "wave_height_max,wave_period_max,swell_wave_height_max,swell_wave_period_max"),
            URLQueryItem(name: "forecast_days", value: "7"),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        
        guard let url = components.url else { throw OpenMeteoServiceError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(OpenMeteoMarineResponse.self, from: data)
    }
}

