//
//  HabitCoreDataStorage.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import CoreData

final class HabitCoreDataStorage {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }

    func addHabit(_ habit: HabitModel) throws {
        let entity = HabitEntity(context: context)
        entity.id = habit.id
        entity.title = habit.title
        entity.category = habit.category.rawValue
        entity.createdAt = habit.createdAt
        try context.save()
    }

    func fetchAllHabits() throws -> [HabitModel] {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        return try context.fetch(request).map {
            HabitModel(
                id: $0.id ?? UUID(),
                title: $0.title ?? "",
                category: HabitCategory(rawValue: $0.category ?? "") ?? .canDoIt,
                createdAt: $0.createdAt ?? Date()
            )
        }
    }

    func updateHabit(_ habit: HabitModel) throws {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)

        if let entity = try context.fetch(request).first {
            entity.title = habit.title
            entity.category = habit.category.rawValue
            try context.save()
        }
    }

    func deleteHabit(by id: UUID) throws {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        if let entity = try context.fetch(request).first {
            context.delete(entity)
            try context.save()
        }
    }
}
