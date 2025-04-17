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

    private let habitRepository: HabitRepository
    private var cancellables = Set<AnyCancellable>()

    init(habitRepository: HabitRepository) {
        self.habitRepository = habitRepository
    }

    func loadHabits(for date: Date) {
        habitRepository.fetchHabits(for: date)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error fetching habits for date: \(error)")
                    }
                },
                receiveValue: { [weak self] habits in
                    guard let self = self else { return }
                    self.todos = habits
                    self.completed = []
                }
            )
            .store(in: &cancellables)
    }

    func markHabitCompleted(_ habit: HabitModel) {
        habitRepository.updateHabitStatus(habit.id, completedAt: Date())

        let record = HabitRecordModel(
            id: UUID(),
            date: Date(),
            duration: habit.goalMinutes ?? 0,
            habit: habit
        )

        habitRepository.addHabitRecord(record)

        completed.append(habit)
        todos.removeAll { $0.id == habit.id }
    }
}
