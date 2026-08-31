//
//  KnowYourDayApp.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 29/08/26.
//

import SwiftUI
import SwiftData

@main
struct KnowYourDayApp: App {
    var body: some Scene {
        WindowGroup {
            CitySearchView()
        }.modelContainer(for: SearchedCity.self)
    }
}
