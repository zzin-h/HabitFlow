//
//  SaveHabitUseCaseImpl.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

final class SaveHabitUseCaseImpl: SaveHabitUseCase {
    private let habitRepository: HabitRepository

    init(habitRepository: HabitRepository) {
        self.habitRepository = habitRepository
    }

    func execute(habit: Habit) async throws {
        // Habit 객체 유효성 검사 예시
        guard !habit.name.isEmpty else {
            throw HabitError.invalidName
        }

        try await habitRepository.save(habit: habit)
    }
}
