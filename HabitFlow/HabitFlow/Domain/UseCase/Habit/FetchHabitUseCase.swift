//
//  FetchHabitUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import Combine

protocol FetchHabitUseCase {
    func execute() -> AnyPublisher<[HabitModel], Error>
}

final class DefaultFetchHabitUseCase: FetchHabitUseCase {
    private let repository: HabitRepository

    init(repository: HabitRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[HabitModel], Error> {
        return repository.fetchHabits()
    }
}
