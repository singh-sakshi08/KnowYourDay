//
//  FullRankingGrid.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//
import SwiftUI

struct FullRankingGrid: View {
    let rankings: [DayRanking]

    private let leadingGap: CGFloat = 30
    private let dayColumnWidth: CGFloat = 44

    var body: some View {
        VStack(spacing: 10) {
            headerRow
            Divider()
            ForEach(rankings, id: \.date) { day in
                dayRow(for: day)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            Text("Day")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .frame(width: dayColumnWidth, alignment: .leading)

            Spacer().frame(width: leadingGap)

            HStack(spacing: 0) {
                ForEach(1...4, id: \.self) { rank in
                    Text("#\(rank)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func dayRow(for day: DayRanking) -> some View {
        HStack(spacing: 0) {
            Text(TopActivityGrid.weekdayLabel(for: day.date))
                .font(.subheadline.bold())
                .frame(width: dayColumnWidth, alignment: .leading)

            Spacer().frame(width: leadingGap)

            HStack(spacing: 0) {
                ForEach(0..<4, id: \.self) { index in
                    if index < day.rankedActivities.count {
                        let activity = day.rankedActivities[index]
                        Image(systemName: activity.iconName)
                            .foregroundStyle(activity.tintColor)
                            .frame(maxWidth: .infinity)
                    } else {
                        Color.clear.frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}
