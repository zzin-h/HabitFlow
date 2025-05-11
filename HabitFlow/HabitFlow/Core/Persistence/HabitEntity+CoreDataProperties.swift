//
//  HabitEntity+CoreDataProperties.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/10/25.
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
    @NSManaged public var goalMinutes: Int32
    @NSManaged public var id: UUID?
    @NSManaged public var intervalDays: Int32
    @NSManaged public var routineType: String?
    @NSManaged public var selectedDays: NSObject?
    @NSManaged public var title: String?
    @NSManaged public var records: NSSet?
    @NSManaged public var notifications: HabitNotificationEntity?

}

// MARK: Generated accessors for records
extension HabitEntity {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: HabitRecordEntity)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: HabitRecordEntity)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}

extension HabitEntity : Identifiable {

}
