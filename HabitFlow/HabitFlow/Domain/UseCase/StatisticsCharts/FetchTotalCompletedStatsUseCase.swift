//
//  FetchTotalCompletedStatsUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Combine

protocol FetchTotalCompletedStatsUseCase {
    func execute() -> AnyPublisher<[TotalCompletedStat], Error>
}

final class DefaultFetchTotalCompletedStatsUseCase: FetchTotalCompletedStatsUseCase {
    private let repository: StatisticsChartsRepository

    init(repository: StatisticsChartsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[TotalCompletedStat], Error> {
        return repository.fetchTotalCompletedStats()
    }
}
