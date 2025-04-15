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

    init(id: UUID, title: String, category: HabitCategory, createdAt: Date) {
        self.id = id
        self.title = title
        self.category = category
        self.createdAt = createdAt
    }

    init(entity: HabitEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.category = HabitCategory(rawValue: entity.category ?? "") ?? .healthyIt
        self.createdAt = entity.createdAt ?? Date()
    }
}
