//
//  StatisticsChartsCoreDataStorage.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation
import CoreData

final class StatisticsChartsCoreDataStorage {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    // MARK: - 1. 완료된 습관 카테고리별 날짜별 카운트
    func fetchTotalCompletedStats() throws -> [TotalCompletedStat] {
        let fetchRequest: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        
        let records = try context.fetch(fetchRequest)
        
        // 날짜 기준으로 grouping
        let grouped = Dictionary(grouping: records) { record in
            let date = record.date ?? Date()
            return Calendar.current.startOfDay(for: date)
        }
        
        var result: [TotalCompletedStat] = []
        
        for (date, recordsForDate) in grouped {
            let categoryGroup = Dictionary(grouping: recordsForDate) { record in
                HabitCategory(rawValue: record.habit?.category ?? "") ?? .healthyIt
            }
            
            for (category, recordsForCategory) in categoryGroup {
                let titles = recordsForCategory
                    .compactMap { $0.habit?.title }
                    .joined(separator: ", ")
                
                let stat = TotalCompletedStat(
                    date: date,
                    title: titles,
                    category: category,
                    count: recordsForCategory.count
                )
                result.append(stat)
            }
        }
        
        return result.sorted { $0.date < $1.date }
    }
    
    //    // MARK: - 2. 함께한 일수 및 스트릭 계산
    //    func fetchActiveDaysStat() throws -> ActiveDaysStat {
    //        // TODO: 유니크한 날짜 수 & 연속 달성일 계산
    //        return ActiveDaysStat(
    //            totalDays: 0,
    //            streakDays: 0,
    //            firstStartDate: Date(),
    //            lastActiveDate: Date()
    //        )
    //    }
    //
    //    // MARK: - 3. 카테고리별 완료 비율
    //    func fetchFavoriteCategoryStats(period: Period) throws -> [CategoryStat] {
    //        // TODO: 기간 내 카테고리별 완료 비율 계산
    //        return []
    //    }
    //
    //    // MARK: - 4. 가장 자주 완료한 습관 Top 3
    //    func fetchBestHabitStats(period: Period) throws -> [BestHabitStat] {
    //        // TODO: Top 3 습관 제목 + 카운트 + 기간 ID
    //        return []
    //    }
    //
    //    // MARK: - 5. 습관별 누적 시간
    //    func fetchTotalTimeStats(period: Period) throws -> [TotalTimeStat] {
    //        // TODO: 습관별 총 시간 반환
    //        return []
    //    }
    //
    //    // MARK: - 6. 요일별 + 시간대별 완료 분포
    //    func fetchMostFrequentStats(period: Period) throws -> TimePatternStat {
    //        // TODO: 요일 & 시간대별 통계
    //        return TimePatternStat(
    //            weekdayStats: [],
    //            timeSlotStats: []
    //        )
    //    }
    //
    //    // MARK: - 7. 요약 리포트 (한눈에 보는 통계)
    //    func fetchSummaryReport(period: Period) throws -> SummaryReport {
    //        return SummaryReport(
    //            totalCompleted: 0,
    //            totalTime: 0,
    //            bestHabit: "",
    //            frequentDay: "월요일",
    //            frequentTimeSlot: "08:00 - 10:00"
    //        )
    //    }
}
