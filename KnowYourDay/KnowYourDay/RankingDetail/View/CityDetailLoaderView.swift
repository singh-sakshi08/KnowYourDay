//
//  CityDetailLoaderView.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//
import SwiftUI
import SwiftData

struct CityDetailLoaderView: View {
    @Query private var cities: [SearchedCity]
    @State private var viewModel: CityDetailViewModel?
    let rankingProvider: RankingProviding

    init(cityId: Int, rankingProvider: RankingProviding) {
        self.rankingProvider = rankingProvider
        _cities = Query(filter: #Predicate<SearchedCity> { $0.id == cityId })
    }

    var body: some View {
        Group {
            if let viewModel {
                CityDetailView(viewModel: viewModel)
            } else if let city = cities.first {
                Color.clear
                    .onAppear {
                        viewModel = CityDetailViewModel(city: city, rankingProvider: rankingProvider)
                    }
            } else {
                ContentUnavailableView("City Not Found", systemImage: "questionmark.circle")
            }
        }
    }
}

