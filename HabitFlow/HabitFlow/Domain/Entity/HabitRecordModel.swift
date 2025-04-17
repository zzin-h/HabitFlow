//
//  HabitRecordModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import Foundation

struct HabitRecordModel: Identifiable {
    let id: UUID
    let date: Date
    let duration: Int
    let habit: HabitModel

    init(id: UUID, date: Date, duration: Int, habit: HabitModel) {
        self.id = id
        self.date = date
        self.duration = duration
        self.habit = habit
    }

    init(entity: HabitRecordEntity) {
        self.id = entity.id ?? UUID()
        self.date = entity.date ?? Date()
        self.duration = Int(entity.duration)

        if let habitEntity = entity.habit {
            self.habit = HabitModel(entity: habitEntity)
        } else {
            self.habit = HabitModel(
                id: UUID(),
                title: "Unknown Habit",
                category: .canDoIt,
                createdAt: Date(),
                routineType: .daily,
                selectedDays: [],
                intervalDays: 0,
                goalMinutes: 0
            )
        }
    }
}
