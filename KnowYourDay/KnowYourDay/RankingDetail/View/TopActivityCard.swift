//
//  TopActivityCard.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import SwiftUI

struct TopActivityCard: View {
    let activity: Activity
    let cityName: String

    var body: some View {
        VStack(spacing: 12) {
            Text(cityName.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)

            Image(systemName: activity.iconName)
                .font(.system(size: 64))
                .foregroundStyle(activity.tintColor)

            Text(activity.displayName)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("Best pick for today")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(activity.tintColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
