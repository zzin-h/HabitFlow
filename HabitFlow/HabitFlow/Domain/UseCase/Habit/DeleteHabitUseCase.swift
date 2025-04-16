//
//  DeleteHabitUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import Foundation
import Combine

protocol DeleteHabitUseCase {
    func execute(_ id: UUID) -> AnyPublisher<Void, Error>
}

final class DefaultDeleteHabitUseCase: DeleteHabitUseCase {
    private let repository: HabitRepository

    init(repository: HabitRepository) {
        self.repository = repository
    }

    func execute(_ id: UUID) -> AnyPublisher<Void, Error> {
        return repository.deleteHabit(id)
    }
}
