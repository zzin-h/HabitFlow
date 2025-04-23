//
//  FetchCompletedDatesUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation
import Combine

protocol FetchCompletedDatesUseCase {
    func execute() -> AnyPublisher<[Date], Error>
}

final class DefaultFetchCompletedDatesUseCase: FetchCompletedDatesUseCase {
    private let repository: StatisticsChartsRepository

    init(repository: StatisticsChartsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[Date], Error> {
        repository.fetchCompletedDates()
    }
}
