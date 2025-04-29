//
//  FetchTotalTimeStatUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/29/25.
//

import Combine

protocol FetchTotalTimeStatUseCase {
    func execute() -> AnyPublisher<[TotalTimeStat], Error>
}

final class DefaultFetchTotalTimeStatUseCase: FetchTotalTimeStatUseCase {
    private let repository: StatisticsChartsRepository

    init(repository: StatisticsChartsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[TotalTimeStat], Error> {
        return repository.fetchTotalTimeStat()
    }
}
