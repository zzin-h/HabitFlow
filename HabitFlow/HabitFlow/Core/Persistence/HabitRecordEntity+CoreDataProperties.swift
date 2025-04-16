//
//  HabitRecordEntity+CoreDataProperties.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//
//

import Foundation
import CoreData


extension HabitRecordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitRecordEntity> {
        return NSFetchRequest<HabitRecordEntity>(entityName: "HabitRecordEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var duration: Int32
    @NSManaged public var habit: HabitEntity?

}

extension HabitRecordEntity : Identifiable {

}
