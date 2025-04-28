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

//// 4. 베스트 습관
//struct BestHabitStat: Identifiable {
//    let id = UUID()
//    let habit: HabitModel
//    let count: Int
//}
//
//// 5. 총 시간
//struct TotalTimeStat: Identifiable {
//    let id = UUID()
//    let habit: HabitModel
//    let duration: TimeInterval
//}
//
//// 6. 날짜 기반 통계
//struct TimePatternStat {
//    let weekdayStats: [(weekday: Weekdays, count: Int)]
//    let timeSlotStats: [(slot: String, count: Int)]
//}
//
//// 7. 통계 요약 카드
//struct SummaryReport {
//    let totalCompleted: Int
//    let totalTime: TimeInterval
//    let bestHabit: String
//    let frequentDay: String
//    let frequentTimeSlot: String
//}
