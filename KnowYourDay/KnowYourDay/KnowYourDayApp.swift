//
//  KnowYourDayApp.swift
//  KnowYourDay
//
//  Created by Sakshi Singh on 29/08/26.
//

import SwiftUI

@main
struct KnowYourDayApp: App {
    var body: some Scene {
        WindowGroup {
            
            let service = RankingSerivce()
            let ranking = service.getRanking(forecastResponse: ExpandedRankingFixture.forecast, marineResponse: ExpandedRankingFixture.marine)
            let _ = print(ranking)
            
            ContentView()
        }
    }
}
