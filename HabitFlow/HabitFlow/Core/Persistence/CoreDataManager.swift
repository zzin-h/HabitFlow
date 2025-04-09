//
//  CoreDataManager.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "HabitEntity")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData load error: \(error.localizedDescription)")
            }
        }
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
