//
//  StatisticsChartsModelItem.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation

struct TotalCompletedStat: Hashable {
    let date: Date
    let title: String
    let category: HabitCategory
    let count: Int
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
}

//// 3. 관심 카테고리 비율
//struct CategoryStat: Identifiable {
//    let id = UUID()
//    let category: HabitCategory
//    let ratio: Double
//}
//
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
