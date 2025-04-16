//
//  TodayHabitViewModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation
import Combine

final class TodayHabitViewModel: ObservableObject {
    @Published var todos: [HabitModel] = []
    @Published var completed: [HabitModel] = []

    private var habitRepository: HabitRepository

    init(habitRepository: HabitRepository) {
        self.habitRepository = habitRepository
    }

    func markHabitCompleted(_ habit: HabitModel) {
        habitRepository.updateHabitStatus(habit.id, completedAt: Date())

        let habitRecord = HabitRecordModel(
            id: UUID(),
            date: Date(),
            duration: habit.goalMinutes ?? 0,
            habit: habit
        )

        habitRepository.addHabitRecord(habitRecord)

        completed.append(habit)

        todos.removeAll { $0.id == habit.id }
    }
}
