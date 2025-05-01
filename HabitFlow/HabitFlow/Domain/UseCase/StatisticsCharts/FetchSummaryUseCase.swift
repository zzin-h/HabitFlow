//
//  FetchSummaryUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/1/25.
//

import Combine

protocol FetchSummaryUseCase {
    func execute() -> AnyPublisher<RoutineSummary, Error>
}

final class DefaultFetchSummaryUseCase: FetchSummaryUseCase {
    private let repository: StatisticsChartsRepository

    init(repository: StatisticsChartsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<RoutineSummary, Error> {
        repository.fetchSummary()
    }
}
