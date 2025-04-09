//
//  SaveHabitUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

protocol SaveHabitUseCase {
    func execute(habit: Habit) async throws
}
