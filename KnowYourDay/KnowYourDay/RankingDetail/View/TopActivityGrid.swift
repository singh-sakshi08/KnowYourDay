//
//  TopActivityGrid.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import SwiftUI

struct TopActivityGrid: View {
    let rankings: [DayRanking]
    private static let forecastDaysCount: Int = 7

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: Self.forecastDaysCount)

    private var visibleDays: [DayRanking] {
        Array(rankings.prefix(Self.forecastDaysCount))
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(visibleDays, id: \.date) { day in
                VStack(spacing: 6) {
                    Text(Self.weekdayLabel(for: day.date))
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)

                    if let top = day.topActivity {
                        Image(systemName: top.iconName)
                            .font(.title3)
                            .foregroundStyle(top.tintColor)
                    } else {
                        Image(systemName: "questionmark")
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    static func weekdayLabel(for dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: dateString) else { return dateString }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEE"
        return outputFormatter.string(from: date)
    }
}
