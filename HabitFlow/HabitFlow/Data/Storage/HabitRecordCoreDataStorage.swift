//
//  HabitRecordCoreDataStorage.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import CoreData

final class HabitRecordCoreDataStorage {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }

    func addRecord(habitId: UUID, date: Date, duration: Int32) throws {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habitId as CVarArg)

        guard let habit = try context.fetch(request).first else {
            throw NSError(domain: "Habit not found", code: 404, userInfo: nil)
        }

        let record = HabitRecordEntity(context: context)
        record.id = UUID()
        record.date = date
        record.duration = duration
        record.habit = habit

        try context.save()
    }

    func fetchRecords(for habitId: UUID) throws -> [HabitRecordEntity] {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "habit.id == %@", habitId as CVarArg)
        return try context.fetch(request)
    }

    func fetchAllRecords() throws -> [HabitRecordEntity] {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        return try context.fetch(request)
    }

    func updateRecord(recordId: UUID, newDate: Date, newDuration: Int32) throws {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", recordId as CVarArg)

        guard let record = try context.fetch(request).first else {
            throw NSError(domain: "Record not found", code: 404, userInfo: nil)
        }

        record.date = newDate
        record.duration = newDuration

        try context.save()
    }

    func deleteRecord(by id: UUID) throws {
        let request: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        if let record = try context.fetch(request).first {
            context.delete(record)
            try context.save()
        }
    }
}
