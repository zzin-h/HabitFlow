//
//  HabitModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import Foundation

public struct HabitModel: Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var category: HabitCategory
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        category: HabitCategory,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.createdAt = createdAt
    }
}
