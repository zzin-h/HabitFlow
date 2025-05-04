//
//  StatisticsDetailType.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import SwiftUI

enum StatisticsDetailType: Hashable {
    case totalCompleted, activeDays, favoriteCategory, timeBasedStats, bestHabits, totalTime

    static func navView(route: StatisticsDetailType) -> AnyView {
        switch route {
        case .totalCompleted:
            return AnyView(TotalCompletedChartView())
        case .activeDays:
            return AnyView(ActiveDaysChartView())
        case .favoriteCategory:
            return AnyView(FavoriteCategoryChartView())
        case .timeBasedStats:
            return AnyView(MostFrequentChartView())
        case .bestHabits:
            return AnyView(BestHabitChartView())
        case .totalTime:
            return AnyView(TotalTimeChartView())
        }
    }
}
