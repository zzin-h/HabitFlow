//
//  HabitNotificationRepository.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/10/25.
//

import CoreData
import UserNotifications

final class HabitNotificationRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }

    func addNotification(for habitId: UUID, time: Date) throws {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habitId as CVarArg)

        guard let habit = try context.fetch(request).first else {
            throw NSError(domain: "Habit not found", code: 404, userInfo: nil)
        }

        let notification = HabitNotificationEntity(context: context)
        notification.id = UUID()
        notification.time = time
        notification.habit = habit

        try context.save()
    }

    func fetchNotification(for habitId: UUID) throws -> HabitNotificationEntity? {
        let request: NSFetchRequest<HabitNotificationEntity> = HabitNotificationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "habit.id == %@", habitId as CVarArg)
        return try context.fetch(request).first
    }
    
    func updateNotification(for habitId: UUID, newTime: Date) throws {
        guard let notification = try fetchNotification(for: habitId) else {
            throw NSError(domain: "Notification not found", code: 404, userInfo: nil)
        }

        notification.time = newTime
        try context.save()
    }

    func deleteNotification(for habitId: UUID) throws {
        if let notification = try fetchNotification(for: habitId) {
            context.delete(notification)
            try context.save()
        }
    }
}
