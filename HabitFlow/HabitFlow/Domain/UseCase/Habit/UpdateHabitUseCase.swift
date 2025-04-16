//
//  UpdateHabitUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import Combine

protocol UpdateHabitUseCase {
    func execute(_ habit: HabitModel) -> AnyPublisher<Void, Error>
}

final class DefaultUpdateHabitUseCase: UpdateHabitUseCase {
    private let repository: HabitRepository

    init(repository: HabitRepository) {
        self.repository = repository
    }

    func execute(_ habit: HabitModel) -> AnyPublisher<Void, Error> {
        repository.updateHabit(habit)
    }
}
