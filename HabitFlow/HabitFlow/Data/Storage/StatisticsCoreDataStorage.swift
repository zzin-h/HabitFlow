//
//  StatisticsCoreDataStorage.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import CoreData

final class StatisticsCoreDataStorage {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }

    func fetchTotalCompletedCount() throws -> Int {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        
        let result = try context.fetch(request)
        
        return result.count
    }

    func fetchActiveDays() throws -> (total: Int, streak: Int) {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        
        let result = try context.fetch(request)
        
        let totalActiveDays = result.count
        let streak = calculateStreak(from: result)
        
        return (totalActiveDays, streak)
    }

    func fetchFavoriteCategory() throws -> String {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        
        let result = try context.fetch(request)
        
        let categoryCount: [String: Int] = result.reduce(into: [:]) { counts, entity in
            let category = entity.category ?? ""
            counts[category, default: 0] += 1
        }
        
        return categoryCount.max { $0.value < $1.value }?.key ?? "No category"
    }

    func fetchBestHabit() throws -> String {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        
        let result = try context.fetch(request)
        
        let bestHabit = result.max { ($0.duration) < ($1.duration) }
        
        return bestHabit?.habit?.title ?? "No habit"
    }

    func fetchTotalTime() throws -> Int {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        
        let result = try context.fetch(request)
        
        return result.reduce(0) { $0 + Int($1.duration) }
    }

    private func calculateStreak(from records: [HabitRecordEntity]) -> Int {
        var streak = 0
        var currentStreak = 0
        
        for record in records.sorted(by: { $0.date ?? Date() < $1.date ?? Date() }) {
            if let date = record.date, Calendar.current.isDateInYesterday(date) {
                currentStreak += 1
            } else {
                streak = max(streak, currentStreak)
                currentStreak = 1
            }
        }
        
        return max(streak, currentStreak)
    }
}
