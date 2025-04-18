//
//  FetchActiveDaysUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import Foundation
import Combine

protocol FetchActiveDaysUseCase {
    func execute() -> AnyPublisher<(total: Int, streak: Int), Error>
}

final class DefaultFetchActiveDaysUseCase: FetchActiveDaysUseCase {
    private let repository: StatisticsRepository

    init(repository: StatisticsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<(total: Int, streak: Int), Error> {
        return repository.fetchActiveDays()
    }
}
