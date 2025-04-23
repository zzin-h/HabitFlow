//
//  FetchActiveDaysStatUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Combine

protocol FetchActiveDaysStatUseCase {
    func execute() -> AnyPublisher<ActiveDaysStat, Error>
}

final class DefaultFetchActiveDaysStatUseCase: FetchActiveDaysStatUseCase {
    private let repository: StatisticsChartsRepository

    init(repository: StatisticsChartsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<ActiveDaysStat, Error> {
        repository.fetchActiveDaysStat()
    }
}
