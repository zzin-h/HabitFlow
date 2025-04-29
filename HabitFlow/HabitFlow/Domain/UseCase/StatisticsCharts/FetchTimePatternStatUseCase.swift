//
//  FetchTimePatternStatUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/29/25.
//

import Combine

protocol FetchTimePatternStatUseCase {
    func execute() -> AnyPublisher<TimePatternStat, Error>
}

final class DefaultFetchTimePatternStatUseCase: FetchTimePatternStatUseCase {
    private let repository: StatisticsChartsRepository

    init(repository: StatisticsChartsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<TimePatternStat, Error> {
        repository.fetchTimePatternStat()
    }
}
