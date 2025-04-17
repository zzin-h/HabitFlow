//
//  FetchHabitRecordUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation
import Combine

protocol FetchHabitRecordUseCase {
    func execute() -> AnyPublisher<[HabitRecordModel], Error>
}

final class DefaultFetchHabitRecordUseCase: FetchHabitRecordUseCase {
    private let repository: HabitRecordRepository

    init(repository: HabitRecordRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[HabitRecordModel], Error> {
        return repository.fetchAllRecords()
    }
}
