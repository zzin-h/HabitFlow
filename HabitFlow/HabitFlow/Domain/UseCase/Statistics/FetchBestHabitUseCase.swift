//
//  FetchBestHabitUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import Foundation
import Combine

protocol FetchBestHabitUseCase {
    func execute() -> AnyPublisher<String, Error>
}

final class DefaultFetchBestHabitUseCase: FetchBestHabitUseCase {
    private let repository: StatisticsRepository

    init(repository: StatisticsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<String, Error> {
        return repository.fetchBestHabit()
    }
}
