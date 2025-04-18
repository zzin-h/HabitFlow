//
//  FetchTimeBasedStatsUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import Foundation
import Combine

protocol FetchTimeBasedStatsUseCase {
    func execute() -> AnyPublisher<TimeBasedStats, Error>
}

final class DefaultFetchTimeBasedStatsUseCase: FetchTimeBasedStatsUseCase {
    private let repository: StatisticsRepository
    
    init(repository: StatisticsRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<TimeBasedStats, Error> {
        repository.fetchTimeBasedStats()
    }
}
