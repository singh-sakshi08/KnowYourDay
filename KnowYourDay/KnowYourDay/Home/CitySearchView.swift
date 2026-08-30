//
//  CitySearchView.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//
import SwiftUI
import SwiftData

struct CitySearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SearchedCity.lastSearchedAt, order: .reverse) private var history: [SearchedCity]

    @State private var viewModel: CitySearchViewModel
    @State private var path: [Int] = []

    private let rankingProvider: RankingProviding

    init(dependencies: DependencyContainer = DependencyContainer()) {
        _viewModel = State(initialValue: CitySearchViewModel(locationSearchService: dependencies.locationSearchService))
        rankingProvider = dependencies.rankingProvider
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                        searchResultsSection
                    } else {
                        historySection
                    }
                }
                .padding()
            }
            .navigationTitle("Know Your Day")
            .searchable(text: $viewModel.searchText, prompt: "Search for a city")
            .navigationDestination(for: Int.self) { cityId in
                CityDetailLoaderView(cityId: cityId, rankingProvider: rankingProvider)
            }
        }
    }

    @ViewBuilder
    private var searchResultsSection: some View {
        if viewModel.isSearching {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
        } else if viewModel.searchResults.isEmpty {
            Text("No matching cities")
                .foregroundStyle(.secondary)
        } else {
            VStack(spacing: 12) {
                ForEach(viewModel.searchResults) { result in
                    Button {
                        select(result)
                    } label: {
                        CityHistoryCard(
                            name: result.name,
                            subtitle: [result.admin1, result.country].compactMap { $0 }.joined(separator: ", ")
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var historySection: some View {
        Text("Recent Searches")
            .font(.headline)

        if history.isEmpty {
            Text("Search for a city to see its 7-day activity forecast.")
                .foregroundStyle(.secondary)
        } else {
            VStack(spacing: 12) {
                ForEach(history) { city in
                    CityHistoryCard(
                        name: city.name,
                        subtitle: [city.admin1, city.country].compactMap { $0 }.joined(separator: ", "),
                        onDelete: { removeFromHistory(city) }
                    )
                    // Plain tap gesture (not a Button) so it doesn't swallow
                    // taps meant for the nested delete Button above.
                    .contentShape(Rectangle())
                    .onTapGesture { path.append(city.id) }
                }
            }
        }
    }

    private func select(_ result: GeocodingResult) {
        let repository = SwiftDataCityHistoryRepository(modelContext: modelContext)
        if let city = try? repository.recordSearch(result) {
            path.append(city.id)
        }
        viewModel.clearSearch()
    }

    private func removeFromHistory(_ city: SearchedCity) {
        modelContext.delete(city)
        try? modelContext.save()
    }
}

#Preview {
    CitySearchView()
        .modelContainer(for: SearchedCity.self, inMemory: true)
}
