//
//  CitySearchViewModel.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import Foundation
import Observation

@Observable
final class CitySearchViewModel {
    var searchText: String = "" {
        didSet {
            guard searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            searchTask?.cancel()
            searchResults = []
            hasSearched = false
            isSearching = false
        }
    }
    private(set) var searchResults: [GeocodingResult] = []
    private(set) var isSearching = false
    /// True once the user has submitted a search: distinguishes "typing,
    /// not yet searched" (still shows history) from "searched, no matches".
    private(set) var hasSearched = false

    private let locationSearchService: LocationSearchingProtocol
    private var searchTask: Task<Void, Never>?

    init(locationSearchService: LocationSearchingProtocol) {
        self.locationSearchService = locationSearchService
    }

    /// Called when search is submitted: the only place a network call is triggered.
    func performSearch() {
        searchTask?.cancel()
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            searchResults = []
            hasSearched = false
            return
        }

        hasSearched = true
        searchTask = Task {
            isSearching = true
            defer { isSearching = false }
            do {
                let results = try await locationSearchService.search(query: query)
                guard !Task.isCancelled else { return }
                searchResults = results
            } catch {
                // TEMP DIAGNOSTIC — remove once the root cause is found.
                print("⚠️ searchLocations failed for '\(query)': \(error)")
                guard !Task.isCancelled else { return }
                searchResults = []
            }
        }
    }

    func clearSearch() {
        searchTask?.cancel()
        searchText = ""
        searchResults = []
        hasSearched = false
        isSearching = false
    }
}

