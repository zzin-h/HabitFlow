//
//  StatisticsChartsModelItem.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation
import SwiftUI

struct TotalCompletedStat: Hashable {
    let date: Date
    let title: String
    let category: HabitCategory
    let count: Int
    
    var color: Color {
        return category.color
    }
}

struct DateCategoryKey: Hashable {
    let date: Date
    let category: HabitCategory
}

struct ChangeStat {
    let isSame: Bool
    let isIncreased: Bool
    let difference: Int
    let percentage: Double
}

struct ActiveDaysStat: Equatable {
    let totalDays: Int
    let streakDays: Int
    let firstStartDate: Date
    let lastActiveDate: Date
}

struct DayCell: Identifiable {
    let id = UUID()
    let date: Date
    let isCompleted: Bool
    let isInCurrentMonth: Bool
}

struct CategoryStat: Identifiable {
    let id = UUID()
    let category: HabitCategory
    let totalCount: Int
    
    var title: String {
        return category.title
    }
    
    var color: Color {
        return category.color
    }
}

struct PieSlice: Identifiable {
    let id = UUID()
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    let title: String
    let value: Double
    let percentage: Double
}

struct BestHabitStat: Identifiable {
    let id = UUID()
    let title: String
    let count: Int
    let category: HabitCategory
}

struct TotalTimeStat: Identifiable {
    let id = UUID()
    let title: String
    let duration: Int
    let category: HabitCategory
}

struct WeekdayStat: Identifiable {
    let id = UUID()
    let weekday: Weekdays
    let count: Int
}

struct TimeSlotStat: Identifiable {
    let id = UUID()
    let slot: TimeSlot
    let count: Int
}

struct TimePatternStat {
    let weekdayStats: [WeekdayStat]
    let timeSlotStats: [TimeSlotStat]
}
//// 7. 통계 요약 카드
//struct SummaryReport {
//    let totalCompleted: Int
//    let totalTime: TimeInterval
//    let bestHabit: String
//    let frequentDay: String
//    let frequentTimeSlot: String
//}
