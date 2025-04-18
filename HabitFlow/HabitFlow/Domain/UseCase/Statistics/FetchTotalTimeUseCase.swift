//
//  FetchTotalTimeUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import Foundation
import Combine

protocol FetchTotalTimeUseCase {
    func execute() -> AnyPublisher<Int, Error>
}

final class DefaultFetchTotalTimeUseCase: FetchTotalTimeUseCase {
    private let repository: StatisticsRepository

    init(repository: StatisticsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<Int, Error> {
        return repository.fetchTotalTime()
    }
}
