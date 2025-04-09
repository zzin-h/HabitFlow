//
//  HabitEntity+CoreDataProperties.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//
//

import Foundation
import CoreData


extension HabitEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitEntity> {
        return NSFetchRequest<HabitEntity>(entityName: "HabitEntity")
    }

    @NSManaged public var category: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?

}

extension HabitEntity : Identifiable {

}
