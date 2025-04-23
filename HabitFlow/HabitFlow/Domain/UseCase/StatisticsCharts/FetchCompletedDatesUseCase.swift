//
//  FetchCompletedDatesUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation
import Combine

protocol FetchCompletedDatesUseCase {
    func execute() -> AnyPublisher<Set<Date>, Error>
}

struct DefaultFetchCompletedDatesUseCase: FetchCompletedDatesUseCase {
    let repository: StatisticsChartsRepository

    func execute() -> AnyPublisher<Set<Date>, Error> {
        repository.fetchCompletedDates()
    }
}
