//
//  CityDetailView.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//
import SwiftUI

struct CityDetailView: View {
    let viewModel: CityDetailViewModel

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                heroSection
                    .frame(height: geo.size.height * 0.4)//setting the top 40% of the screen
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Best Activity Each Day")
                                .font(.headline)
                            TopActivityGrid(rankings: viewModel.rankings)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Full 7-Day Ranking")
                                .font(.headline)
                            FullRankingGrid(rankings: viewModel.rankings)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(viewModel.city.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    @ViewBuilder
    private var heroSection: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let message = viewModel.errorMessage {
            ContentUnavailableView(message, systemImage: "exclamationmark.triangle")
        } else if let today = viewModel.today, let top = today.topActivity {
            TopActivityCard(activity: top, cityName: viewModel.city.name)
        } else {
            ContentUnavailableView("No Data", systemImage: "cloud.slash")
        }
    }
}
