//
//  StatisticsChartsRepository.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation
import CoreData

final class StatisticsChartsRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    // MARK: - 1. 완료된 습관 카테고리별 날짜별 카운트
    func fetchTotalCompletedStats() throws -> [TotalCompletedStat] {
        let fetchRequest: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        
        let records = try context.fetch(fetchRequest)
        
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
    
    // MARK: - 관심 카테고리
    func fetchCategoryStats() throws -> [CategoryStat] {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        let result = try context.fetch(request)
        
        let categoryCounts: [HabitCategory: Int] = result.reduce(into: [:]) { counts, entity in
            if let category = entity.habit?.category {
                counts[HabitCategory(rawValue: category)!, default: 0] += 1
            }
        }
        
        let stats = categoryCounts.map { (category, count) in
            CategoryStat(category: category, totalCount: count)
        }
        
        return stats.sorted { $0.totalCount > $1.totalCount }
    }
    
    // MARK: - 베스트 습관
    func fetchBestHabitsWithCategory() throws -> [String: (count: Int, category: HabitCategory)] {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        let result = try context.fetch(request)
        
        var habitCountDict: [String: (count: Int, category: HabitCategory)] = [:]
        
        for record in result {
            guard let title = record.habit?.title,
                  let categoryString = record.habit?.category,
                  let category = HabitCategory(rawValue: categoryString) else {
                continue
            }
            
            if let existing = habitCountDict[title] {
                habitCountDict[title] = (existing.count + 1, category)
            } else {
                habitCountDict[title] = (1, category)
            }
        }
        
        return habitCountDict
    }
    
    // MARK: - 타이머 습관
    func fetchTotalTimeStat() throws -> [TotalTimeStat] {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        let result = try context.fetch(request)
        
        var totalTimeDict: [String: (duration: Int, category: HabitCategory)] = [:]
        
        for record in result {
            guard let title = record.habit?.title,
                  let categoryString = record.habit?.category,
                  let category = HabitCategory(rawValue: categoryString) else {
                continue
            }
            
            let duration = Int(record.duration)
            
            guard duration > 0 else { continue }
            
            if let existing = totalTimeDict[title] {
                totalTimeDict[title] = (existing.duration + duration, category)
            } else {
                totalTimeDict[title] = (duration, category)
            }
        }
        
        let stats = totalTimeDict.map { title, data in
            TotalTimeStat(
                title: title,
                duration: Int(data.duration),
                category: data.category
            )
        }
        
        return stats
    }
    
    // MARK: - 날짜 기반 통계
    func fetchTimePatternStat() throws -> TimePatternStat {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        let records = try context.fetch(request)

        let calendar = Calendar.current

        var weekdayCount: [Weekdays: Int] = [:]
        var timeSlotCount: [TimeSlot: Int] = [:]

        for record in records {
            guard let date = record.date else { continue }

            if let weekday = Weekdays.from(date: date) {
                weekdayCount[weekday, default: 0] += 1
            }

            let hour = calendar.component(.hour, from: date)
            if let slot = TimeSlot.slot(for: hour) {
                timeSlotCount[slot, default: 0] += 1
            }
        }

        let weekdayStats = Weekdays.allCases.map {
            WeekdayStat(weekday: $0, count: weekdayCount[$0, default: 0])
        }

        let timeSlotStats = TimeSlot.allCases.map {
            TimeSlotStat(slot: $0, count: timeSlotCount[$0, default: 0])
        }

        return TimePatternStat(
            weekdayStats: weekdayStats,
            timeSlotStats: timeSlotStats
        )
    }
    
    // MARK: - 통계 요약 카드
    func fetchSummary(for period: Period) throws -> RoutineSummary {
        let dateRange = period.dateRange

        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            dateRange.lowerBound as NSDate,
            dateRange.upperBound as NSDate
        )

        let records = try context.fetch(request)

        var routineIdSet: Set<UUID> = []
        var routineFreq: [String: Int] = [:]
        var weekdayFreq: [Weekdays: Int] = [:]
        var timeSlotFreq: [TimeSlot: Int] = [:]
        var totalDuration: TimeInterval = 0

        for record in records {
            if let id = record.habit?.id {
                routineIdSet.insert(id)
            }

            if let name = record.habit?.title {
                routineFreq[name, default: 0] += 1
            }

            if let date = record.date {
                if let weekday = Weekdays.from(date: date) {
                    weekdayFreq[weekday, default: 0] += 1
                }

                let hour = Calendar.current.component(.hour, from: date)
                if let slot = TimeSlot.slot(for: hour) {
                    timeSlotFreq[slot, default: 0] += 1
                }
            }

            totalDuration += Double(record.duration)
        }
        
        let maxRoutineCount = routineFreq.values.max() ?? 0
        let topRoutineNames = routineFreq
            .filter { $0.value == maxRoutineCount }
            .map { $0.key }

        let topWeekday = weekdayFreq.max { $0.value < $1.value }?.key
        let topTimeSlot = timeSlotFreq.max { $0.value < $1.value }?.key

        return RoutineSummary(
            routineCount: routineIdSet.count,
            totalCount: records.count,
            topRoutineName: topRoutineNames,
            topWeekday: topWeekday,
            topTimeSlot: topTimeSlot,
            totalDuration: Int(totalDuration)
        )
    }
}
