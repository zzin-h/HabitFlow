//
//  HabitModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import Foundation

struct HabitModel: Identifiable {
    let id: UUID
    let title: String
    let category: HabitCategory
    let createdAt: Date
    let routineType: RoutineType
    let selectedDays: [String]?
    let intervalDays: Int?
    let goalMinutes: Int?
    let records: [HabitRecordModel]

    init(
        id: UUID,
        title: String,
        category: HabitCategory,
        createdAt: Date,
        routineType: RoutineType,
        selectedDays: [String]? = nil,
        intervalDays: Int? = nil,
        goalMinutes: Int? = nil,
        records: [HabitRecordModel] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.createdAt = createdAt
        self.routineType = routineType
        self.selectedDays = selectedDays
        self.intervalDays = intervalDays
        self.goalMinutes = goalMinutes
        self.records = records
    }

    init(entity: HabitEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.category = HabitCategory(rawValue: entity.category ?? "") ?? .healthyIt
        self.createdAt = entity.createdAt ?? Date()
        self.routineType = RoutineType(rawValue: entity.routineType ?? "") ?? .daily
        self.selectedDays = entity.selectedDays as? [String]
        self.intervalDays = Int(entity.intervalDays)
        self.goalMinutes = Int(entity.goalMinutes)
        self.records = []
    }
}
