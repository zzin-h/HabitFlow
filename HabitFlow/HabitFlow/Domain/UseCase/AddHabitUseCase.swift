//
//  AddHabitUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import Combine

protocol AddHabitUseCase {
    func execute(_ habit: HabitModel) -> AnyPublisher<Void, Error>
}

final class DefaultAddHabitUseCase: AddHabitUseCase {
    private let repository: HabitRepository

    init(repository: HabitRepository) {
        self.repository = repository
    }

    func execute(_ habit: HabitModel) -> AnyPublisher<Void, Error> {
        return repository.saveHabit(habit)
    }
}
