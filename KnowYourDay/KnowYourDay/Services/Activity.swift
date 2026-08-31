//
//  Activity.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 30/08/26.
//

import SwiftUI

enum Activity: String, CaseIterable, Identifiable {
    case skiing = "Skiing"
    case surfing = "Surfing"
    case outdoor = "Outdoor"
    case indoor = "Indoor"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .skiing: return "Skiing"
        case .surfing: return "Surfing"
        case .outdoor: return "Outdoor Sightseeing"
        case .indoor: return "Indoor Sightseeing"
        }
    }

    var iconName: String {
        switch self {
        case .skiing: return "figure.skiing.downhill"
        case .surfing: return "figure.surfing"
        case .outdoor: return "sun.max.fill"
        case .indoor: return "building.columns.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .skiing: return .cyan
        case .surfing: return .teal
        case .outdoor: return .orange
        case .indoor: return .purple
        }
    }
}

extension DayRanking {
    var rankedActivities: [Activity] {
        ranking.compactMap { Activity(rawValue: $0) }
    }

    var topActivity: Activity? {
        rankedActivities.first
    }
}
