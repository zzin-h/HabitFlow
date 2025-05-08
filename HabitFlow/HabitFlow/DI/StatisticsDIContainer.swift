//
//  StatisticsDIContainer.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import Foundation

final class StatisticsDIContainer {
    
    // MARK: - Repository
    private let statisticsRepository: StatisticsRepository
    
    // MARK: - UseCase
    private let statisticsUseCase: StatisticsUseCase

    // MARK: - Init
    init() {
        self.statisticsRepository = StatisticsRepository()
        self.statisticsUseCase = StatisticsUseCaseImpl(repository: statisticsRepository)
    }

    // MARK: - ViewModel
    func makeStatisticsViewModel() -> StatisticsViewModel {
        return StatisticsViewModel(
            useCase: statisticsUseCase
        )
    }
}
