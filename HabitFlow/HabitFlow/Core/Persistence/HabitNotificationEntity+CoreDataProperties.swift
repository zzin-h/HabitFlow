//
//  HabitNotificationEntity+CoreDataProperties.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/10/25.
//
//

import Foundation
import CoreData


extension HabitNotificationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitNotificationEntity> {
        return NSFetchRequest<HabitNotificationEntity>(entityName: "HabitNotificationEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var time: Date?
    @NSManaged public var habit: HabitEntity?

}

extension HabitNotificationEntity : Identifiable {

}
