//
//  FetchHabitRecordsByHabitIdUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation
import Combine

protocol FetchHabitRecordsByHabitIdUseCase {
    func execute(habitId: UUID) -> AnyPublisher<[HabitRecordModel], Error>
}

final class DefaultFetchHabitRecordsByHabitIdUseCase: FetchHabitRecordsByHabitIdUseCase {
    private let repository: HabitRecordRepository

    init(repository: HabitRecordRepository) {
        self.repository = repository
    }

    func execute(habitId: UUID) -> AnyPublisher<[HabitRecordModel], Error> {
        return repository.fetchRecords(for: habitId)
    }
}
