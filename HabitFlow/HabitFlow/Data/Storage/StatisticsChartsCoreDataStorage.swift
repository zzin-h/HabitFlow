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
    
    // MARK: - 2. 함께한 일수 및 스트릭 계산
    func fetchActiveDaysStat() throws -> ActiveDaysStat {
        let fetchRequest: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        let records = try context.fetch(fetchRequest)
        
        let completedDates: Set<Date> = Set(records.compactMap { record in
            guard let date = record.date else { return nil }
            return Calendar.current.startOfDay(for: date)
        })
        
        let sortedDates = completedDates.sorted()
        
        guard let firstDate = sortedDates.first, let lastDate = sortedDates.last else {
            return ActiveDaysStat(totalDays: 0, streakDays: 0, firstStartDate: Date(), lastActiveDate: Date())
        }
        
        let calendar = Calendar.current
        var streak = 1
        var maxStreak = 1
        
        for i in 1..<sortedDates.count {
            let prev = sortedDates[i - 1]
            let current = sortedDates[i]
            if let diff = calendar.dateComponents([.day], from: prev, to: current).day,
               diff == 1 {
                streak += 1
                maxStreak = max(maxStreak, streak)
            } else {
                streak = 1
            }
        }
        
        return ActiveDaysStat(
            totalDays: completedDates.count,
            streakDays: maxStreak,
            firstStartDate: firstDate,
            lastActiveDate: lastDate
        )
    }
    
    // MARK: - 완료된 날짜들 가져오기
    func fetchCompletedDates() throws -> [Date] {
        let fetchRequest: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        fetchRequest.propertiesToFetch = ["date"]
        
        let records = try context.fetch(fetchRequest)
        let dates = records.compactMap { $0.date }
        let uniqueDates = Set(dates.map { Calendar.current.startOfDay(for: $0) })
        return Array(uniqueDates)
    }
}
