//
//  HabitNotificationModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/11/25.
//

import Foundation

struct HabitNotificationModel: Identifiable {
    let id: UUID
    let time: Date
    let habit: HabitModel

    init(id: UUID, time: Date, habit: HabitModel) {
        self.id = id
        self.time = time
        self.habit = habit
    }

    init(entity: HabitNotificationEntity) {
        self.id = entity.id ?? UUID()
        self.time = entity.time ?? Date()

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
