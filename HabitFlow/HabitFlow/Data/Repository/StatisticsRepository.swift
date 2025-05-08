//
//  StatisticsRepository.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import CoreData

final class StatisticsRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }

    // MARK: - 완료된 습관 총 개수
    func fetchTotalCompletedCount() throws -> Int {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        let result = try context.fetch(request)
        return result.count
    }

    // MARK: - 함께한 일수 & 연속 일수
    func fetchActiveDays() throws -> (total: Int, streak: Int) {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        let result = try context.fetch(request)

        let uniqueDays: Set<Date> = Set(result.compactMap { $0.date?.startOfDay })
        let totalActiveDays = uniqueDays.count
        let streak = calculateStreak(from: uniqueDays)

        return (totalActiveDays, streak)
    }

    // MARK: - 관심 카테고리
    func fetchFavoriteCategory() throws -> String {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        let result = try context.fetch(request)

        let categoryCount: [String: Int] = result.reduce(into: [:]) { counts, entity in
            let category = entity.category ?? ""
            counts[category, default: 0] += 1
        }

        return categoryCount.max { $0.value < $1.value }?.key ?? "No category"
    }

    // MARK: - 베스트 습관
    func fetchBestHabit() throws -> String {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        let result = try context.fetch(request)

        let grouped = Dictionary(grouping: result.compactMap { $0.habit?.title }) { $0 }
        let mostFrequentHabit = grouped.max { $0.value.count < $1.value.count }

        return mostFrequentHabit?.key ?? "No habit"
    }

    // MARK: - 총 시간
    func fetchTotalTime() throws -> Int {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        let result = try context.fetch(request)

        return result.reduce(0) { $0 + Int($1.duration) }
    }

    // MARK: - 날짜 기반 통계
    func fetchTimeBasedStats() throws -> (mostFrequentDay: String, mostFrequentTime: String) {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        let result = try context.fetch(request)

        let mostFrequentDay = calculateMostFrequentDay(from: result)
        let mostFrequentTime = calculateMostFrequentTime(from: result)

        return (mostFrequentDay, mostFrequentTime)
    }

    // MARK: - Private Helpers
    private func calculateStreak(from uniqueDays: Set<Date>) -> Int {
        guard !uniqueDays.isEmpty else { return 0 }

        let sortedDays = uniqueDays.sorted()
        var streak = 1
        var currentStreak = 1

        for i in 1..<sortedDays.count {
            let prev = sortedDays[i - 1]
            let current = sortedDays[i]

            if Calendar.current.isDate(current, inSameDayAs: prev.addingTimeInterval(86400)) {
                currentStreak += 1
                streak = max(streak, currentStreak)
            } else {
                currentStreak = 1
            }
        }

        return streak
    }

    private func calculateMostFrequentDay(from records: [HabitRecordEntity]) -> String {
        let calendar = Calendar.current
        var dayCount: [String: Int] = [:]

        for record in records {
            if let date = record.date {
                let weekday = calendar.component(.weekday, from: date)
                let dayName = calendar.weekdaySymbols[weekday - 1]
                dayCount[dayName, default: 0] += 1
            }
        }

        return dayCount.max { $0.value < $1.value }?.key ?? "No data"
    }

    private func calculateMostFrequentTime(from records: [HabitRecordEntity]) -> String {
        let calendar = Calendar.current
        var timeSlotCount: [String: Int] = [:]

        for record in records {
            if let date = record.date {
                let hour = calendar.component(.hour, from: date)
                let start = hour / 2 * 2
                let end = start + 2
                let timeSlot = String(format: "%02d:00 - %02d:00", start, end)
                timeSlotCount[timeSlot, default: 0] += 1
            }
        }

        return timeSlotCount.max { $0.value < $1.value }?.key ?? "No data"
    }
}
