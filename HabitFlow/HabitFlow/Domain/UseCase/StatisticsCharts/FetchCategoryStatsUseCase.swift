//
//  FetchCategoryStatsUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/29/25.
//

import Combine

protocol FetchCategoryStatsUseCase {
    func execute() -> AnyPublisher<[CategoryStat], Error>
}

final class DefaultFetchCategoryStatsUseCase: FetchCategoryStatsUseCase {
    private let repository: StatisticsChartsRepository

    init(repository: StatisticsChartsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[CategoryStat], Error> {
        repository.fetchCategoryStats()
    }
}
