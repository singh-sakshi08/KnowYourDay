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
        didSet { scheduleSearch(for: searchText) }
    }
    private(set) var searchResults: [GeocodingResult] = []
    private(set) var isSearching = false

    private let locationSearchService: LocationSearchingProtocol
    private var searchTask: Task<Void, Never>?

    init(locationSearchService: LocationSearchingProtocol) {
        self.locationSearchService = locationSearchService
    }

    private func scheduleSearch(for query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 200_000_000) // debounce
            guard !Task.isCancelled else { return }
            isSearching = true
            let results = (try? await locationSearchService.search(query: trimmed)) ?? []
            guard !Task.isCancelled else { return }
            searchResults = results
            isSearching = false
        }
    }

    func clearSearch() {
        searchTask?.cancel()
        searchText = ""
        searchResults = []
        isSearching = false
    }
}
