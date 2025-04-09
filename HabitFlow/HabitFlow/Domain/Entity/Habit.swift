//
//  Habit.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

import Foundation

public struct Habit: Equatable, Identifiable {
    public let id: UUID
    public var title: String
    public var category: HabitCategory
    public var frequency: HabitFrequency
    public var createdAt: Date
    public var isArchived: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        category: HabitCategory,
        frequency: HabitFrequency,
        createdAt: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.frequency = frequency
        self.createdAt = createdAt
        self.isArchived = isArchived
    }
}
