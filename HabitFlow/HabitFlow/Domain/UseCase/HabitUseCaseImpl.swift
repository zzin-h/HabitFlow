//
//  HabitUseCaseImpl.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import Foundation
import Combine

final class HabitUseCaseImpl: HabitUseCase {
    private let repository: HabitRepository

    init(repository: HabitRepository) {
        self.repository = repository
    }

    func fetchHabits() -> AnyPublisher<[HabitModel], Error> {
        return repository.fetchHabits()
    }

    func createHabit(habit: HabitModel) -> AnyPublisher<Void, Error> {
        return repository.saveHabit(habit)
    }

    func deleteHabit(id: UUID) -> AnyPublisher<Void, Error> {
        return repository.deleteHabit(id)
    }
}
