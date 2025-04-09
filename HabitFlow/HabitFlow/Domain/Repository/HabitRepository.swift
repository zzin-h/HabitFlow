//
//  HabitRepository.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

protocol HabitRepository {
    func save(habit: Habit) async throws
}
